// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RiteOfMoloch.sol";
import "../src/RiteOfMolochFactory.sol";
import "../src/InitializationData.sol";

import "./mocks/mockRaid.sol";
import "./mocks/MolochStooge.sol";


    // @parseb
    /// @notice (gnosis fork) testing
contract RiteOfMolochTest is Test, InitializationData {

    address ADMIN = address(bytes20("ADMIN"));
    address OPERATOR = address(bytes20("OPERATOR"));
    address MEMBER = address(bytes20("MEMBER"));
    address raidWhale = address(bytes20("HAS_MAX_RAID"));
    
    RiteOfMolochFactory riteFactory;
    RiteOfMoloch riteOfMoloch;
    MockRaid raidToken;
    MolochDAO Moloch;
    MolochStooge fakeMoloch;

    InitData InitD;
    address s3DaoAddress = 0x7BdE8f8A3D59b42d0d8fab3a46E9f42E8e3c2dE8;


    address deployer_address = 0x87002DEbA8A7a0194870CfE2309F6C018Ad01AE8;
    address ROM_live = 0x67f22Aa92dC5Bc8840073F0B9251AF679a99ab57;
    address ROM_factory_live = 0xBb7353efB505D63408D1C762A5C3A1636E9Ca003;

    /// deployment transaction url https://blockscout.com/xdai/mainnet/tx/0xe8123d8b9b4e563bcd1bc8e91f48f6a43087edb787ad96fdd2af693037e7638a/logs
   /// https://blockscout.com/xdai/mainnet/address/0x67f22Aa92dC5Bc8840073F0B9251AF679a99ab57/read-contract#address-tabs ROM V

    function setUp() public {
        /// gnosis fork at current block
        vm.createSelectFork(vm.envString("gnosis_rpc"), 23964321);

        // vm.startPrank(ADMIN);
        // riteFactory = new RiteOfMolochFactory();
        // raidToken = new MockRaid();

        // //moloch = MolochDAO(s3DaoAddress);
        // fakeMoloch = new MolochStooge();

        // raidToken.transfer(raidWhale, raidToken.balanceOf(ADMIN));
        // vm.stopPrank();
        // vm.startPrank(raidWhale);
        // uint amt = type(uint256).max / 20;
        // raidToken.transfer(ADMIN, amt);
        // raidToken.transfer(OPERATOR, amt);
        // raidToken.transfer(MEMBER, amt);
        // vm.stopPrank();

    }

    function testSGHasRole() public{
        /// has admin role
        riteOfMoloch = RiteOfMoloch(ROM_live);
        assertFalse(riteOfMoloch.hasRole(keccak256("ADMIN"), deployer_address));
        assertFalse(riteOfMoloch.hasRole(keccak256("OPERATOR"), deployer_address));

    }

    function testSGcanChangeURI() public {
        riteOfMoloch = RiteOfMoloch(ROM_live);
        string memory prevUri = riteOfMoloch.tokenURI(1);
        console.log("Prev. URI : ", prevUri );
        vm.startPrank(deployer_address);
        
        vm.expectRevert("AccessControl: account 0x87002deba8a7a0194870cfe2309f6c018ad01ae8 is missing role 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42");
        riteOfMoloch.setBaseURI("http://NewUri.rg");
        
        assertFalse(bytes(prevUri).length != bytes(riteOfMoloch.tokenURI(1)).length);

        // riteOfMoloch.grantRole()


        vm.stopPrank();
    }

    

}