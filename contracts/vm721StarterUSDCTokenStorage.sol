pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Evm721StarterUSDCTokenStorage is ERC721 {
    using Counters for Counters.Counter;

    Counters.Counter internal nextId;

    IERC20 public usdc;
    address public crossmintAddress;
    uint256 public nonce;
    string public clientId;

    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public price;

    string public baseUri;

    constructor() ERC721("EVM 721 Starter USDC", "USDCXMPL") {}
}