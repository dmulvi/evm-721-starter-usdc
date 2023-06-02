// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Evm721StarterUSDC is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    event Mint(uint256 tokenId);

    Counters.Counter internal nextId;

    IERC20 public usdc;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public price = 10 * 10 ** 6; // 10 USDC (because usdc is a 6 decimal ERC20 token)
    string public baseUri = "https://bafkreifyb5jetemu2qf2pbid7246kvsumzsqim5z3jabr5zrb3fukh35ki.ipfs.nftstorage.link";

    constructor(address _usdcAddress) payable ERC721("EVM 721 Starter USDC", "USDCXMPL") {
        usdc = IERC20(_usdcAddress);
    }

    // MODIFIERS

    modifier isAvailable(uint256 _quantity) {
        require(nextId.current() + _quantity <= MAX_SUPPLY, "Not enough tokens left for quantity");
        _;
    }

    // PUBLIC

    function mint(address _to, uint256 _quantity) 
        external  
        isAvailable(_quantity) 
    {
        usdc.transferFrom(msg.sender, address(this), price * _quantity);

        mintInternal(_to, _quantity);
    }


    // INTERNAL

    function mintInternal(address _to, uint256 _quantity) internal {
        for (uint256 i = 0; i < _quantity; i++) {
            uint256 tokenId = nextId.current();
            nextId.increment();

            _safeMint(_to, tokenId);

            emit Mint(tokenId);
        }
    }   

    // ADMIN

    /**
     * uint256 _newPrice - this price must include 6 decimal points
     * for example: 10 USDC == 10_000_000
     */
    function setPrice(uint256 _newPrice) external onlyOwner {
        price = _newPrice;
    }

    function setUri(string calldata _newUri) external onlyOwner {
        baseUri = _newUri;
    }

    function setUsdcAddress(IERC20 _usdc) public onlyOwner {
        usdc = _usdc;
    }

    function withdraw() public onlyOwner {
        usdc.transfer(msg.sender, usdc.balanceOf(address(this)));
    }

    // VIEW

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        // same uri for all NFTs, logic looks wrong but is intended to use the _tokenId
        // argument to avoid compiler warnings about it not being used
        // for a standard 721 where each NFT is unique this function will def need to be changed
        return
            bytes(baseUri).length > 0
                ? baseUri // this will always be the intended return
                : string(abi.encodePacked(baseUri, _tokenId.toString(), ".json")); 
    }
}