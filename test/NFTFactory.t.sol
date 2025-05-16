// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {NFTFactory} from "../src/NFTFactory.sol";
import {TeamNFT} from "../src/TeamNFT.sol";
import {MemberNFT} from "../src/MemberNFT.sol";

contract NFTFactoryTest is Test {
    NFTFactory public factory;
    address public owner;
    address public captain;
    address public member1;
    address public member2;
    
    uint256 public teamId;
    uint256 public constant STAKE_AMOUNT = 0.1 ether;
    uint256 public constant ACTIVITY_DURATION = 30 days;
    
    // Base64 encoded JSON metadata for team and members
    string public teamTokenURI = "data:application/json;base64,eyJuYW1lIjoiVGVzdCBUZWFtIiwiZGVzY3JpcHRpb24iOiJBIHRlc3QgdGVhbSIsImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpSUhCeVpYTmxjblpsUVhOd1pXTjBVbUYwYVc4OUluaE5hVzVaVFdsdUlHMWxaWFFpSUhacFpYZENiM2c5SWpBZ01DQXpOVEFnTXpVd0lqNDhjM1I1YkdVK0xtSmhjMlVnZXlCbWFXeHNPaUIzYUdsMFpYTWdmVHd2YzNSNWJHVStQSEpsWm05eWRDQnBaRDBpWW1GelpTSWdabTl1ZEMxbVlXMXBiSGs5SW5ObGNtbG1JaUJtYjI1MExYTnBlbVU5SWpJMElqNVVaWE4wSUZSbFlXMDhMM0psWm05eWRENDhkR1Y0ZENCemRIbHNaVDBpWm1sc2JEb2dJM2RvYVhSbE95SWdabWxzYkMxeWRXeGxQU0psZG1WdWIyUmtJajQ4TDNSbGVIUStQQzkzY21sblpqND0ifQ==";
    string public member1TokenURI = "data:application/json;base64,eyJuYW1lIjoiTWVtYmVyIDEiLCJkZXNjcmlwdGlvbiI6IlRlYW0gbWVtYmVyIG51bWJlciAxIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQm1jbVZsYzNSaGRHVWdmVHd2YzNSNWJHVStQSEpsWm05eWRDQnBaRDBpWW1GelpTSWdabTl1ZEMxbVlXMXBiSGs5SW5ObGNtbG1JaUJtYjI1MExYTnBlbVU5SWpJMElqNU5aVzFpWlhJZ01Ud3ZjbVZtYjNKMFBqeDBaWGgwSUhOMGVXeGxQU0ptYVd4c09pQWpabkpsWlhOMFlYUmxPeUlnWm1sc2JDMXlkV3hsUFNKbGRtVnViMlJrSWo0OEwzUmxlSFErUEM5M2NtbG5aajQ9In0=";
    string public member2TokenURI = "data:application/json;base64,eyJuYW1lIjoiTWVtYmVyIDIiLCJkZXNjcmlwdGlvbiI6IlRlYW0gbWVtYmVyIG51bWJlciAyIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQmliSFZsSUgwOEwzTjBlV3hsUGp4eVpXWnZjblFnYVdROUltSmhjMlVpSUdadmJuUXRabUZ0YVd4NVBTSnpaWEpwWmlJZ1ptOXVkQzF6YVhwbFBTSXlOQ0krVFdWdFltVnlJREknZFNCVWVXMThMM0psWm05eWRENDhkR1Y0ZENCemRIbHNaVDBpWm1sc2JEb2dJMmR2YkdRN0lpQm1hV3hzTFhKMWJHVTlJbVYyWlc1dlpHUWlQand2ZEdWNGRENDhMM2R5YVdkbVBnPT0ifQ==";
    string public captainTokenURI = "data:application/json;base64,eyJuYW1lIjoiQ2FwdGFpbiIsImRlc2NyaXB0aW9uIjoiVGVhbSBjYXB0YWluIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQnlaV1FnZlR3dmMzUjViR1UrUEhKbFptOXlkQ0JwWkQwaVltRnpaU0lnWm05dWRDMW1ZVzFwYkhsOUluTmxjbWxtSWlCbWIyNTBMWE5wZW1VOUlqSTBJajVEWVhCMFlXbHVQQzl5WldadmNuUStQSFJsZUhRZ2MzUjViR1U5SW1acGJHdzZJQ055WldRN0lpQm1hV3hzTFhKMWJHVTlJbVYyWlc1dlpHUWlQand2ZEdWNGRENDhMM2R5YVdkbVBnPT0ifQ==";
    
    // New updated tokenURIs for test
    string public newMember1TokenURI = "data:application/json;base64,eyJuYW1lIjoiTWVtYmVyIDEgVXBkYXRlZCIsImRlc2NyaXB0aW9uIjoiVXBkYXRlZCBtZW1iZXIgMSBpbmZvIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQm5jbVZsYmlCOVBDOXpkSGxzWlQ0OGNtVm1iM0owSUdsa1BTSmlZWE5sSWlCbWIyNTBMV1poYldsc2VUMGljMlZ5YVdZaUlHWnZiblF0YzJsNlpUMGlNalFpUGsxbGJXSmxjaUF4SUZWd1pHRjBaV1E4TDNKbFptOXlkRDQ4ZEdWNGRDQnpkSGxzWlQwaVptbHNiRG9nSTJkeVpXVnVPeUlnWm1sc2JDMXlkV3hsUFNKbGRtVnViMlJrSWo0OEwzUmxlSFErUEM5M2NtbG5aajQ9In0=";
    string public newMember2TokenURI = "data:application/json;base64,eyJuYW1lIjoiTWVtYmVyIDIgVXBkYXRlZCIsImRlc2NyaXB0aW9uIjoiVXBkYXRlZCBtZW1iZXIgMiBpbmZvIiwiaW1hZ2UiOiJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSEJ5WlhObGNuWmxRWE53WldOMFVtRjBhVzg5SW5oTmFXNVpUV2x1SUcxbFpYUWlJSFpwWlhkQ2IzZzlJakFnTUNBek5UQWdNelV3SWo0OGMzUjViR1UrTG1KaGMyVWdleUJtYVd4c09pQm5iMnhrSUgwOEwzTjBlV3hsUGp4eVpXWnZjblFnYVdROUltSmhjMlVpSUdadmJuUXRabUZ0YVd4NVBTSnpaWEpwWmlJZ1ptOXVkQzF6YVhwbFBTSXlOQ0krVFdWdFltVnlJREknZFNCVWVXMThMM0psWm05eWRENDhkR1Y0ZENCemRIbHNaVDBpWm1sc2JEb2dJMmR2YkdRN0lpQm1hV3hzTFhKMWJHVTlJbVYyWlc1dlpHUWlQand2ZEdWNGRENDhMM2R5YVdkbVBnPT0ifQ==";
    string public newCaptainTokenURI = "data:application/json;base64,eyJuYW1lIjoiQ2FwdGFpbiBVcGRhdGVkIiwiZGVzY3JpcHRpb24iOiJVcGRhdGVkIGNhcHRhaW4gaW5mbyIsImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpSUhCeVpYTmxjblpsUVhOd1pXTjBVbUYwYVc4OUluaE5hVzVaVFdsdUlHMWxaWFFpSUhacFpYZENiM2c5SWpBZ01DQXpOVEFnTXpVd0lqNDhjM1I1YkdVK0xtSmhjMlVnZXlCbWFXeHNPaUJ3ZFhKd2JHVWdmVHd2YzNSNWJHVStQSEpsWm05eWRDQnBaRDBpWW1GelpTSWdabTl1ZEMxbVlXMXBiSGs5SW5ObGNtbG1JaUJtYjI1MExYTnBlbVU5SWpJMElqNURZWEIwWVdsdUlGVndaR0YwWldROEwzSmxabTl5ZEQ0OGRHVjRkQ0J6ZEhsc1pUMGlabWxzYkRvZ0kzQjFjbkJzWlRzaUlHWnBiR3d0Y25Wc1pUMGlaWFpsYm05a1pDSStQQzkwWlhoMFBqd3ZkM0pwWjJZKyJ9";

    function setUp() public {
        owner = address(this);
        captain = makeAddr("captain");
        member1 = makeAddr("member1");
        member2 = makeAddr("member2");
        
        // Initial funds
        vm.deal(captain, 1 ether);
        vm.deal(member1, 1 ether);
        vm.deal(member2, 1 ether);
        
        // Deploy factory contract with 30 days activity duration
        factory = new NFTFactory(ACTIVITY_DURATION);
    }
    
    function test_CreateTeam() public {
        // Captain creates team
        vm.startPrank(captain);
        teamId = factory.createTeam{value: STAKE_AMOUNT}("Test Team", teamTokenURI);
        vm.stopPrank();
        
        // Verify team created successfully
        TeamNFT teamNFT = factory.teamNFT();
        assertEq(teamNFT.ownerOf(teamId), captain);
        
        // Check team ID counter
        assertEq(teamId, 0); // First team ID should be 0
    }
    
    function test_AddMember() public {
        // Create team first
        test_CreateTeam();
        
        // Captain adds members
        vm.startPrank(captain);
        factory.addMember(member1, teamId, "Member 1", 1, member1TokenURI);
        factory.addMember(member2, teamId, "Member 2", 2, member2TokenURI);
        vm.stopPrank();
        
        // Verify members added successfully
        MemberNFT memberNFT = factory.memberNFT();
        uint256[] memory memberIds = factory.getTeamMemberIds(teamId);
        
        assertEq(memberIds.length, 2);
        assertEq(memberNFT.ownerOf(memberIds[0]), member1);
        assertEq(memberNFT.ownerOf(memberIds[1]), member2);
        
        // Verify member team association
        assertEq(memberNFT.memberToTeam(memberIds[0]), teamId);
        assertEq(memberNFT.memberToTeam(memberIds[1]), teamId);
        
        // Verify tokenURIs
        assertEq(memberNFT.tokenURI(memberIds[0]), member1TokenURI);
        assertEq(memberNFT.tokenURI(memberIds[1]), member2TokenURI);
    }
    
    function test_AddMemberNFTself() public {
        // Create team first
        test_CreateTeam();
        
        // Captain adds himself as member
        vm.startPrank(captain);
        factory.addMemberNFTself(teamId, "Captain", 0, captainTokenURI);
        vm.stopPrank();
        
        // Verify captain's member NFT added successfully
        MemberNFT memberNFT = factory.memberNFT();
        uint256[] memory memberIds = factory.getTeamMemberIds(teamId);
        
        assertEq(memberIds.length, 1);
        assertEq(memberNFT.ownerOf(memberIds[0]), captain);
        
        // Verify captain's member NFT team association
        assertEq(memberNFT.memberToTeam(memberIds[0]), teamId);
        
        // Verify tokenURI
        assertEq(memberNFT.tokenURI(memberIds[0]), captainTokenURI);
    }
    
    function test_UpdateTeamMemberURIs() public {
        // Create team and add members first
        test_CreateTeam();
        
        vm.startPrank(captain);
        factory.addMember(member1, teamId, "Member 1", 1, member1TokenURI);
        factory.addMember(member2, teamId, "Member 2", 2, member2TokenURI);
        factory.addMemberNFTself(teamId, "Captain", 0, captainTokenURI);
        vm.stopPrank();
        
        uint256[] memory memberIds = factory.getTeamMemberIds(teamId);
        assertEq(memberIds.length, 3);
        
        // Prepare new tokenURI array
        string[] memory newTokenURIs = new string[](3);
        newTokenURIs[0] = newMember1TokenURI;
        newTokenURIs[1] = newMember2TokenURI;
        newTokenURIs[2] = newCaptainTokenURI;
        
        // Update tokenURIs as contract owner
        vm.startPrank(owner);
        factory.updateTeamMemberURIs(teamId, "Test Team", newTokenURIs);
        vm.stopPrank();
        
        // Verify update successful
        MemberNFT memberNFT = factory.memberNFT();
        assertEq(memberNFT.tokenURI(memberIds[0]), newMember1TokenURI);
        assertEq(memberNFT.tokenURI(memberIds[1]), newMember2TokenURI);
        assertEq(memberNFT.tokenURI(memberIds[2]), newCaptainTokenURI);
    }
    
    function test_GetTeamMemberIds() public {
        // Create team and add members first
        test_CreateTeam();
        
        // Initially should have no member IDs
        uint256[] memory emptyIds = factory.getTeamMemberIds(teamId);
        assertEq(emptyIds.length, 0);
        
        // Add members
        vm.startPrank(captain);
        factory.addMember(member1, teamId, "Member 1", 1, member1TokenURI);
        factory.addMember(member2, teamId, "Member 2", 2, member2TokenURI);
        vm.stopPrank();
        
        // Verify getTeamMemberIds returns correct member IDs
        uint256[] memory memberIds = factory.getTeamMemberIds(teamId);
        assertEq(memberIds.length, 2);
        
        // Verify returned IDs correspond to correct owners
        MemberNFT memberNFT = factory.memberNFT();
        assertEq(memberNFT.ownerOf(memberIds[0]), member1);
        assertEq(memberNFT.ownerOf(memberIds[1]), member2);
    }
    
    function test_RevertWhen_UnauthorizedMemberAdd() public {
        // Create team first
        test_CreateTeam();
        
        // Non-captain tries to add member, should fail
        vm.startPrank(member1);
        vm.expectRevert();
        factory.addMember(member2, teamId, "Member 2", 2, member2TokenURI);
        vm.stopPrank();
    }
    
    function test_RevertWhen_UnauthorizedUpdateURI() public {
        // Create team and add member first
        test_CreateTeam();
        
        vm.startPrank(captain);
        factory.addMember(member1, teamId, "Member 1", 1, member1TokenURI);
        vm.stopPrank();
        
        string[] memory newTokenURIs = new string[](1);
        newTokenURIs[0] = newMember1TokenURI;
        
        // Non-owner tries to update tokenURI, should fail
        vm.startPrank(captain);
        vm.expectRevert();
        factory.updateTeamMemberURIs(teamId, "Test Team", newTokenURIs);
        vm.stopPrank();
    }
    
    function test_RevertWhen_InvalidArrayLength() public {
        // Create team and add member first
        test_CreateTeam();
        
        vm.startPrank(captain);
        factory.addMember(member1, teamId, "Member 1", 1, member1TokenURI);
        vm.stopPrank();
        
        // Prepare tokenURI array with mismatched length
        string[] memory newTokenURIs = new string[](2);
        newTokenURIs[0] = newMember1TokenURI;
        newTokenURIs[1] = newMember2TokenURI;
        
        // Update as contract owner but with mismatched array length, should fail
        vm.startPrank(owner);
        vm.expectRevert();
        factory.updateTeamMemberURIs(teamId, "Test Team", newTokenURIs);
        vm.stopPrank();
    }
    
    function test_UpdateActivityEndTime() public {
        // 获取原始结束时间
        uint256 originalEndTime = factory.activityEndTime();
        
        // 设置新的活动结束时间（提前结束）
        uint256 newEndTime = originalEndTime - 10 days;
        
        vm.startPrank(owner);
        factory.updateActivityEndTime(newEndTime);
        vm.stopPrank();
        
        // 验证结束时间已更新
        assertEq(factory.activityEndTime(), newEndTime);
    }
    
    
    function test_CheckUpkeep_NoTeams() public {
        // 前进时间，到活动结束时间
        vm.warp(block.timestamp + ACTIVITY_DURATION);
        
        // 检查upkeep状态 - 不应该需要执行，因为没有队伍
        (bool upkeepNeeded, ) = factory.checkUpkeep("");
        assertFalse(upkeepNeeded);
    }
    
    function test_CheckUpkeep_WithTeams() public {
        // 创建一个新队伍
        test_CreateTeam();
        
        // 前进时间，到活动结束时间
        vm.warp(block.timestamp + ACTIVITY_DURATION);
        
        // 检查upkeep状态 - 应该需要执行，因为活动已结束且有队伍
        (bool upkeepNeeded, ) = factory.checkUpkeep("");
        assertTrue(upkeepNeeded);
    }
    
    function test_PerformUpkeep() public {
        // 创建一个新队伍
        test_CreateTeam();
        
        // 记录队长初始余额
        uint256 captainInitialBalance = captain.balance;
        
        // 前进时间，到活动结束时间
        vm.warp(block.timestamp + ACTIVITY_DURATION);
        
        // 获取需要处理的数据
        (bool upkeepNeeded, ) = factory.checkUpkeep("");
        assertTrue(upkeepNeeded);
        
        // 执行upkeep
        factory.performUpkeep("");
        
        // 验证队伍NFT已被销毁
        TeamNFT teamNFT = factory.teamNFT();
        vm.expectRevert();
        teamNFT.ownerOf(teamId);
        
        // 验证质押金额已退还
        assertEq(factory.teamStakes(teamId), 0);
        assertEq(captain.balance, captainInitialBalance + STAKE_AMOUNT);
    }
    
    function test_MultipleTeamsCleanup() public {
        // 创建两个队伍
        vm.startPrank(captain);
        uint256 team1Id = factory.createTeam{value: STAKE_AMOUNT}("Team 1", teamTokenURI);
        vm.stopPrank();
        
        address captain2 = makeAddr("captain2");
        vm.deal(captain2, 1 ether);
        
        vm.startPrank(captain2);
        uint256 team2Id = factory.createTeam{value: STAKE_AMOUNT}("Team 2", teamTokenURI);
        vm.stopPrank();
        
        // 记录队长初始余额
        uint256 captain1InitialBalance = captain.balance;
        uint256 captain2InitialBalance = captain2.balance;
        
        // 前进时间，到活动结束时间
        vm.warp(block.timestamp + ACTIVITY_DURATION);
        
        // 检查upkeep状态
        (bool upkeepNeeded, ) = factory.checkUpkeep("");
        assertTrue(upkeepNeeded);
        
        // 执行upkeep
        factory.performUpkeep("");
        
        // 验证队伍NFT已被销毁
        TeamNFT teamNFT = factory.teamNFT();
        
        vm.expectRevert();
        teamNFT.ownerOf(team1Id);
        
        vm.expectRevert();
        teamNFT.ownerOf(team2Id);
        
        // 验证质押金额已退还给各自的队长
        assertEq(factory.teamStakes(team1Id), 0);
        assertEq(factory.teamStakes(team2Id), 0);
        assertEq(captain.balance, captain1InitialBalance + STAKE_AMOUNT);
        assertEq(captain2.balance, captain2InitialBalance + STAKE_AMOUNT);
    }
} 