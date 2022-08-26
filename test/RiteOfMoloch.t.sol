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

/// @dev reverts, no message
/// args=[0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000, 1, 1, 1, 2]]
    function testDeploys(
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

        assertTrue( lastID > 0, "iid is 0");
        vm.assume(t4 > 0 && a5 > 0 && d6 > 0 && fakeIID_ > 0);
        vm.assume(fakeIID_ > lastID || fakeIID_ == 0);

        /// test implementation exists for current iid
        assertTrue( riteFactory.implementations(lastID) != address(0), "no implementation");

        InitD = InitData(m1,s2,t3, t4, a5,d6, "Name", "Symbol", "baseUri");

        /// test reverts on id bigger than iid
        vm.expectRevert("!implementation");
        riteFactory.createCohort(InitD, fakeIID_);

        vm.prank(ADMIN);
        address riteAddress = riteFactory.createCohort(InitD, lastID);
        
        riteOfMoloch = RiteOfMoloch(riteAddress);
        assertTrue(riteOfMoloch.hasRole(keccak256("ADMIN"),address(riteFactory)));


        /// NewRiteOfMoloch(cohortAddress: 0xf07907ab96e86b6f54e3a20a71ed1c4d1b3e5a41, deployer: 0x41444d494e000000000000000000000000000000, implementation: RiteOfMoloch: [0xc9db1acdc9aa5022f4a2362d0b2674a8a6310a4a], membershipCriteria: 0x0000000000000000000000000000000000000000, stakeToken: 0x0000000000000000000000000000000000000000, stakeAmount: 1, threshold: 1, time: 1)
    }
}
