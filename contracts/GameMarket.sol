// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameMarket is ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_ITEMS_PER_TYPE = 100;

    mapping(uint256 => uint256) public itemPrices;
    mapping(uint256 => uint256) public itemQuantities;

    constructor() ERC721("GameItem", "GIT") {
        nextTokenId = 1;
    }

    modifier onlyAdmin() {
        require(owner() == _msgSender(), "Not the admin");
        _;
    }

    function mint(uint256 quantity, uint256 price) external onlyAdmin {
        require(nextTokenId.add(quantity) <= MAX_SUPPLY, "Exceeds max supply");
        uint256 tokenId = nextTokenId;
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, tokenId);
            itemQuantities[tokenId] = itemQuantities[tokenId].add(1);
            itemPrices[tokenId] = price;
            tokenId = tokenId.add(1);
        }
        nextTokenId = tokenId;
    }

    function setItemPrice(uint256 tokenId, uint256 price) external onlyAdmin {
        require(_exists(tokenId), "Token does not exist");
        itemPrices[tokenId] = price;
    }

    function buy(uint256 tokenId, uint256 quantity) external payable {
        require(_exists(tokenId), "Token does not exist");
        require(itemQuantities[tokenId] >= quantity, "Not enough items available");
        require(msg.value == itemPrices[tokenId].mul(quantity), "Incorrect payment");

        for (uint256 i = 0; i < quantity; i++) {
            itemQuantities[tokenId] = itemQuantities[tokenId].sub(1);
            _transfer(ownerOf(tokenId), msg.sender, tokenId);
        }
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}