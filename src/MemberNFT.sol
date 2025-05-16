// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC721,ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MemberNFT is ERC721, ERC721URIStorage, ReentrancyGuard, Ownable {
    error MemberNFT__OnlyFactoryAllowed();
    error MemberNFT__SoulboundToken();
    error MemberNFT__MemberAlreadyInactive();

    address public factory;
    mapping(uint256 => uint256) public memberToTeam;
    uint256 private _memberIdCounter;
    // 添加事件
    event MemberMinted(
        address indexed member,
        uint256 indexed tokenId,
        uint256 indexed teamId,
        string name,
        uint256 role,
        string tokenURI
    );

    constructor(
        address initialOwner
    ) ERC721("Member NFT", "MEMBER") Ownable(initialOwner) {
        factory = initialOwner;
    }

    modifier onlyFactory() {
        if (msg.sender != factory) revert MemberNFT__OnlyFactoryAllowed();
        _;
    }

    function mint(
        address to,
        uint256 teamId,
        string memory name,
        uint256 role,
        string memory tokenUri
    ) external onlyFactory nonReentrant returns (uint256) {
        uint256 memberId = _memberIdCounter++;
        _safeMint(to, memberId);
        _setTokenURI(memberId, tokenUri);

        memberToTeam[memberId] = teamId;

        // 触发事件
        emit MemberMinted(to, memberId, teamId, name, role, tokenUri);

        return memberId;
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public override(ERC721, IERC721) {
        revert MemberNFT__SoulboundToken();
    }

    // Override required functions
    function tokenURI(
        uint256 memberId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(memberId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // 添加更新tokenURI的函数
    function updateTokenURI(uint256 memberId, string memory newTokenURI) external onlyFactory {
        _setTokenURI(memberId, newTokenURI);
    }
}
