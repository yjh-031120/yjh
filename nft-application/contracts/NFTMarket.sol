// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyNFT.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Market {
    using Address for address payable;

    MyNFT public nftContract;
    
    // Mapping 用于存储 NFT 的价格
    mapping(uint256 => uint256) private _tokenPrices;
    // Mapping 用于标记 NFT 是否在市场上出售
    mapping(uint256 => bool) private _isForSale;

    event NFTListed(uint256 indexed tokenId, uint256 price);
    event NFTDelisted(uint256 indexed tokenId);
    event NFTBought(uint256 indexed tokenId, address indexed buyer, uint256 price);


    constructor(address nftAddress) {
        nftContract = MyNFT(nftAddress);
    }

    // 上架 NFT
    function listNFTForSale(uint256 tokenId, uint256 price) public {
        address owner = nftContract.ownerOf(tokenId);
        require(owner == msg.sender, "Only the owner can list the NFT for sale.");
        require(price > 0, "Price must be greater than 0.");
        
        // 将 NFT 上架
        _tokenPrices[tokenId] = price;
        _isForSale[tokenId] = true;
    }

    // 取消上架 NFT
    function delistNFT(uint256 tokenId) public {
        address owner = nftContract.ownerOf(tokenId);
        require(owner == msg.sender, "Only the owner can remove the NFT from sale.");
        
        _isForSale[tokenId] = false;
        _tokenPrices[tokenId] = 0; // 取消时清除价格

        // Emit event
        emit NFTDelisted(tokenId);
    }

    // 购买 NFT
    function buyNFT(uint256 tokenId) public payable {
        require(_isForSale[tokenId], "This NFT is not for sale.");
        uint256 price = _tokenPrices[tokenId];
        require(msg.value == price, "Incorrect price sent.");

        address owner = nftContract.ownerOf(tokenId);
        address payable seller = payable(owner);
        
        // 转账到卖家账户
        seller.sendValue(price);
        
        // 转移 NFT 到买家
        nftContract.safeTransferFrom(owner, msg.sender, tokenId);

        // 取消销售
        _isForSale[tokenId] = false;
        _tokenPrices[tokenId] = 0;

        // Emit event
        emit NFTBought(tokenId, msg.sender, price);
    }

    // 获取某个 NFT 的价格
    function getPrice(uint256 tokenId) public view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    // 获取某个 NFT 是否在市场上出售
    function isForSale(uint256 tokenId) public view returns (bool) {
        return _isForSale[tokenId];
    }

    // 获取所有正在出售的NFT
    function getNftsForSale() public view returns (uint256[] memory) {
        uint256 totalSupply = nftContract.totalSupply();  
        uint256[] memory nftsOnSale = new uint256[](totalSupply);  

        uint256 index = 0;
        for (uint256 i = 0; i < totalSupply; i++) {
            uint256 tokenId = nftContract.tokenByIndex(i);  
            if (_isForSale[tokenId]) {
                nftsOnSale[index] = tokenId; 
                index++;
            }
        }

        // 将多余的元素清除
        uint256[] memory finalNfts = new uint256[](index);
        for (uint256 i = 0; i < index; i++) {
            finalNfts[i] = nftsOnSale[i];
        }

        return finalNfts;
    }
}
