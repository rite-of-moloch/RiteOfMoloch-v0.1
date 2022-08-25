// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RiteOfMoloch.sol";
import "../src/RiteOfMolochFactory.sol";
import "../src/InitializationData.sol";

import "./mocks/mockRaid.sol";


contract RiteOfMolochTest is Test, InitializationData {

    // address s3DaoAddress = 0x7BdE8f8A3D59b42d0d8fab3a46E9f42E8e3c2dE8;
    // address raidTokenAddress = 0x18E9262e68Cc6c6004dB93105cc7c001BB103e49;
    // address member = 0xdF1064632754674Acb1b804F2C65849D016eaF9d;
    // address whaleWallet = 0x1e9c89aFf77215F3AD26bFfe0C50d4FdEBa6a352;

    address ADMIN = address(bytes20("ADMIN"));
    address OPERATOR = address(bytes20("OPERATOR"));
    address MEMBER = address(bytes20("MEMBER"));
    address raidWhale = address(bytes20("HAS_MAX_RAID"));

    RiteOfMolochFactory riteFactory;
    RiteOfMoloch riteOfMoloch;
    MockRaid raidToken;

    InitData InitD;

    function setUp() public {

        vm.startPrank(ADMIN);
        riteFactory = new RiteOfMolochFactory();
        // riteOfMoloch = new RiteOfMoloch();
        raidToken = new MockRaid();
        raidToken.transfer(raidWhale, raidToken.balanceOf(ADMIN));
        vm.stopPrank();
        vm.startPrank(raidWhale);
        uint amt = type(uint256).max / 20;
        raidToken.transfer(ADMIN, amt);
        raidToken.transfer(OPERATOR, amt);
        raidToken.transfer(MEMBER, amt);
        vm.stopPrank();
        
    }

    /// @notice fuzz rand initialization variables
    // function _initializationDataFuzz(
    //     address m1, address s2, address t3, 
    //     uint t4, uint a5, uint d6,
    //  string calldata n7, string calldata s8, string calldata b9) {
    //     initD = InitData(m1,s2,t3, t4, a5,a6,n7,s8,b9);
    // }

    function testSetsDeployerAsAdmin(
        address m1,
        address s2,
        address t3,
        uint t4, 
        uint a5,
        uint d6,
        uint fakeIID_) 
     public 
     {  
        uint lastID = riteFactory.iid();
        vm.assume(t4*a5*d6*fakeIID_ > 0);
        vm.assume(fakeIID_ > lastID || fakeIID_ == 0);

        InitD = InitData(m1,s2,t3, t4, a5,d6, "Name", "Symbol", "basUri");

        vm.expectRevert("!implementation");
        riteFactory.createCohort(InitD, fakeIID_);

        
        riteFactory.createCohort(InitD, lastID);
        assertTrue(riteOfMoloch.hasRole(keccak256("ADMIN"),ADMIN));
    }
}
