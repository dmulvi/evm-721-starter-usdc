pragma solidity ^0.8.9;

import "./Evm721StarterUSDCTokenStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Evm721StarterUSDCImplementation is Evm721StarterUSDCTokenStorage, Ownable {
    using Strings for uint256;

    event Mint(uint256 tokenId);

    // EIP-712 constants
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 public constant TX_TYPEHASH = keccak256("Transaction(address from,uint256 nonce)");
    bytes32 public immutable DOMAIN_SEPARATOR;

    constructor(address _usdcAddress, address _crossmint, string memory _clientId) {
        usdc = IERC20(_usdcAddress);
        crossmintAddress = _crossmint;
        clientId = _clientId;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256("Evm721StarterUSDC"),
            keccak256("1"),
            chainId,
            address(this)
        ));
    }

    // ERRORS & MODIFIERS

    error NotCrossmint();

    // MODIFIERS

    modifier isAvailable(uint256 _quantity) {
        require(nextId.current() + _quantity <= MAX_SUPPLY, "Not enough tokens left for quantity");
        _;
    }

    modifier isCrossmint() {
        if (msg.sender != crossmintAddress && msg.sender != owner()) {
            revert NotCrossmint();
        }
        _;
    }

    modifier isValidMinterSignature(bytes memory signature) {
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(TX_TYPEHASH, msg.sender, nonce))
        ));

        address recoveredAddress = ecrecover(digest, uint8(signature[0]), bytes32(signature[1]), bytes32(signature[2]));

        require(recoveredAddress == crossmintAddress, "Invalid minter signature");
        _;
    }

    modifier isValidClientId(string memory _clientId) {
        require(keccak256(abi.encodePacked(_clientId)) == keccak256(abi.encodePacked(clientId)), "Invalid client ID");
        _;
    }

    // PUBLIC

    function mintWithPrice(address _to, uint256 _price, uint256 _quantity)
        external
        isCrossmint
        isAvailable(_quantity)
    {
        usdc.transferFrom(msg.sender, address(this), _price * _quantity);
        mintInternal(_to, _quantity);
    }

    function mintWithPriceAndClientId(address _to, uint256 _price, uint256 _quantity, string memory _clientId)
        external
        isCrossmint
        isAvailable(_quantity)
        isValidClientId(_clientId)
    {
        usdc.transferFrom(msg.sender, address(this), _price * _quantity);
        mintInternal(_to, _quantity);
    }

    function mintWithPriceAndSignature(
        address _to,
        uint256 _price,
        uint256 _quantity,
        bytes memory signature
    )
        external
        isCrossmint
        isAvailable(_quantity)
        isValidMinterSignature(signature)
    {
        usdc.transferFrom(msg.sender, address(this), _price * _quantity);
        mintInternal(_to, _quantity);
        nonce++; // The nonce is incremented here
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

    function setCrossMintAddress(address newCrossMintAddress) public onlyOwner {
        _crossmintAddress = newCrossMintAddress;
    }

    function setClientId(string memory _clientId) external onlyOwner {
        clientId = _clientId;
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