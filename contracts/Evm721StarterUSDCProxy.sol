pragma solidity ^0.8.9;

import "./Evm721StarterUSDCTokenStorage.sol";

contract Evm721StarterUSDCProxy is Evm721StarterUSDCTokenStorage {
    address private _implementation;
    address private _owner;

    event Upgraded(address indexed implementation);

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        require(newImplementation != address(0), "Cannot upgrade to an invalid address");
        require(newImplementation != _implementation, "Cannot upgrade to the same implementation");
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    function implementation() external view returns (address) {
        return _implementation;
    }

    fallback() external payable {
        address implementation = _implementation;
        require(implementation != address(0), "Implementation address not set");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), implementation, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }
}