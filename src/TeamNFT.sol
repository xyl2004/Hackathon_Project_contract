// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC721, ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TeamNFT is ERC721, ERC721URIStorage, ReentrancyGuard, Ownable {
    error OnlyFactoryAllowed();
    error SoulboundToken();
    error TeamIsFull();
    error TeamAlreadyInactive();

    address public factory;
    uint256 public _teamIdCounter;

    // 常量
    uint256 public constant MAX_MEMBERS = 5;

    constructor(
        address initialOwner
    ) ERC721("Team NFT", "TEAM") Ownable(initialOwner) {
        factory = initialOwner;
    }

    modifier onlyFactory() {
        if (msg.sender != factory) revert OnlyFactoryAllowed();
        _;
    }

    function mint(
        address to,
        string memory name,
        string memory tokenUri
    ) external onlyFactory nonReentrant returns (uint256) {
        uint256 teamId = _teamIdCounter++;
        _safeMint(to, teamId);
        _setTokenURI(teamId, tokenUri);



        return teamId;
    }


    function burn(uint256 teamId) external onlyFactory nonReentrant {
        _burn(teamId);
    }

    function transferFrom(
        address,
        address,
        uint256
    ) public override(ERC721, IERC721) {
        revert SoulboundToken();
    }

    // Override required functions
    function tokenURI(
        uint256 teamId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(teamId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
