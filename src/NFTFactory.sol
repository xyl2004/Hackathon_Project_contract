// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {TeamNFT} from "./TeamNFT.sol";
import {MemberNFT} from "./MemberNFT.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AutomationCompatible} from "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract NFTFactory is ReentrancyGuard, Ownable, AutomationCompatible {
    // NFT合约实例
    TeamNFT public teamNFT;
    MemberNFT public memberNFT;

    // 创建队伍所需的质押金额
    uint256 public constant STAKE_AMOUNT = 0.1 ether;

    // 队伍质押记录
    mapping(uint256 => uint256) public teamStakes;
    
    // 活动结束时间
    uint256 public activityEndTime;
    
    // 存储每个队伍的所有成员ID
    mapping(uint256 => uint256[]) public teamMemberIds;
    
    // 错误
    error IncorrectStakeAmount();
    error UnauthorizedCaptain();
    error NoStakeFound();
    error StakeReturnFailed();
    error TeamNotReadyForDissolution();
    error InvalidArrayLength();

    // 事件
    event TeamCreated(
        address indexed captain,
        uint256 indexed teamId,
        string name,
        string tokenURI
    );
    event MemberAdded(
        address indexed member,
        uint256 indexed teamId,
        string name,
        uint256 role,
        uint256 memberId,
        string tokenURI
    );
 
    event TeamURIsUpdated(
        uint256 indexed memberId,
        string tokenURI
    );
    
    event TeamDissolved(
        uint256 indexed teamId,
        address indexed captain,
        uint256 returnedAmount
    );
    
    event ActivityEnded(
        uint256 timestamp,
        uint256 teamsCount
    );

    constructor(uint256 activityDuration) Ownable(msg.sender) {
        teamNFT = new TeamNFT(address(this));
        memberNFT = new MemberNFT(address(this));
        activityEndTime = block.timestamp + activityDuration;
    }

    // 创建新队伍
    function createTeam(
        string memory teamName,
        string memory teamURI,
        string memory memberName,
        string memory memberURI,
        uint256 role
    ) external payable nonReentrant returns (uint256) {    
        if (msg.value != STAKE_AMOUNT) {
            revert IncorrectStakeAmount();
        }

        uint256 teamId = teamNFT.mint(msg.sender, teamName, teamURI);
        teamStakes[teamId] = msg.value;

        emit TeamCreated(msg.sender, teamId, teamName, teamURI);

        // 添加队长的成员NFT
        _addMember(msg.sender, teamId, memberName, role, memberURI);

        return teamId;
    }
// 添加队伍成员NFT
    function addMember(
        uint256 teamId,
        address member,
        string memory memberName,
        uint256 role,
        string memory memberURI
    ) external nonReentrant {
        _addMember(member, teamId, memberName, role, memberURI);
    }

    
    function _addMember(
        address member,
        uint256 teamId,
        string memory name,
        uint256 role,
        string memory tokenURI
    ) internal {
        
        if (teamNFT.ownerOf(teamId) != msg.sender) {
            revert UnauthorizedCaptain();
        }

        uint256 memberId = memberNFT.mint(member, teamId, name, role, tokenURI);
 
        teamMemberIds[teamId].push(memberId);
        emit MemberAdded(member, teamId, name, role, memberId, tokenURI);
    }

   

    // 批量更新队伍成员的tokenURI
    function updateTeamMemberURIs(
        uint256 teamId,
        string[] memory newTokenURIs
    ) external nonReentrant onlyOwner {
        uint256[] memory memberIds = teamMemberIds[teamId];
        
        // 检查tokenURI数组长度是否与成员数量一致
        if (newTokenURIs.length != memberIds.length) {
            revert InvalidArrayLength();
        }
        
        // 批量更新每个成员的tokenURI
        for (uint256 i = 0; i < memberIds.length; i++) {
            memberNFT.updateTokenURI(memberIds[i], newTokenURIs[i]);
            emit TeamURIsUpdated(memberIds[i], newTokenURIs[i]);
        }
        
        // 触发事件
       
    }
    
    // 获取队伍所有成员ID
    function getTeamMemberIds(uint256 teamId) external view returns (uint256[] memory) {
        return teamMemberIds[teamId];
    }
    
    // 更新活动结束时间（仅限管理员）
    function updateActivityEndTime(uint256 newEndTime) external onlyOwner {
        activityEndTime = newEndTime;
    }
    
    /**
     * @dev Chainlink Automation检查是否需要触发upkeep
     * @return upkeepNeeded 是否需要执行upkeep
     * @return performData 执行upkeep时需要的数据
     */
    function checkUpkeep(bytes calldata /* checkData */)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        // 检查活动是否已结束
        upkeepNeeded = block.timestamp >= activityEndTime;
        
        // 如果活动已结束，但没有需要清理的队伍，也不需要执行upkeep
        if (upkeepNeeded) {
            uint256 currentTeamCount = teamNFT._teamIdCounter();
            bool hasTeamsToDissolve = false;
            
            // 检查是否有需要解散的队伍
            for (uint256 i = 0; i < currentTeamCount; i++) {
                // 尝试获取队伍所有者，如果能获取到则意味着该队伍存在
                try teamNFT.ownerOf(i) returns (address) {
                    hasTeamsToDissolve = true;
                    break;
                } catch {
                    // 队伍不存在或已被销毁，继续检查下一个
                    continue;
                }
            }
            
            // 只有当活动结束且有队伍需要解散时才需要执行upkeep
            upkeepNeeded = hasTeamsToDissolve;
        }
        
        return (upkeepNeeded, "0x0");
    }
    
    function performUpkeep(bytes calldata /* performData */) external override {
       // 确保活动已结束
        if (block.timestamp < activityEndTime) {
            return;
        }
        
        uint256 currentTeamCount = teamNFT._teamIdCounter();
        uint256 dissolvedTeamsCount = 0;
        
        // 处理所有存在的队伍
        for (uint256 i = 0; i < currentTeamCount; i++) {
            address teamOwner;
            
            // 尝试获取队伍所有者
            try teamNFT.ownerOf(i) returns (address owner) {
                teamOwner = owner;
            } catch {
                // 队伍不存在或已被销毁，跳过
                continue;
            }
            
            // 获取质押金额
            uint256 stakeAmount = teamStakes[i];
            if (stakeAmount == 0) {
                continue;
            }
            
            // 销毁队伍NFT
            teamNFT.burn(i);
            dissolvedTeamsCount++;
            
            // 退还质押金额给队伍所有者
            (bool success, ) = teamOwner.call{value: stakeAmount}("");
            if (!success) {
                // 如果转账失败，我们可以选择记录失败或采取其他措施
                // 在这里我们选择继续处理其他队伍
                continue;
            }
            
            // 清除质押记录
            teamStakes[i] = 0;
            
            // 触发团队解散事件
            emit TeamDissolved(i, teamOwner, stakeAmount);
        }
        
        // 如果有队伍被解散，触发活动结束事件
        if (dissolvedTeamsCount > 0) {
            emit ActivityEnded(block.timestamp, dissolvedTeamsCount);
        }
    }

    // 接收ETH的回退函数
    receive() external payable {}
}
