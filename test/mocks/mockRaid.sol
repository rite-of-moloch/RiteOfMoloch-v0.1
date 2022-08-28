pragma solidity ^0.8.4;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

/// @notice mock token for testing purposes
contract MockRaid is ERC20("RaidToken", "RAID") {
    address raidWhale = address(bytes20("HAS_MAX_RAID"));

    constructor(){
        _mint(msg.sender, type(uint256).max / 2 );
    }
}