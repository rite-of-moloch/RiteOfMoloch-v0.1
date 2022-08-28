// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RiteOfMoloch.sol";
import "../src/RiteOfMolochFactory.sol";
import "../src/InitializationData.sol";

import "./mocks/mockRaid.sol";
// import "../../Moloch.sol";

// @parseb
/// @notice tests (local) deployment roles and 0 values 
contract RiteOfMolochTest is Test, InitializationData {

    address ADMIN = address(bytes20("ADMIN"));
    address OPERATOR = address(bytes20("OPERATOR"));
    address MEMBER = address(bytes20("MEMBER"));
    address raidWhale = address(bytes20("HAS_MAX_RAID"));
    
    RiteOfMolochFactory riteFactory;
    RiteOfMoloch riteOfMoloch;
    MockRaid raidToken;
    MolochDAO Moloch;

    InitData InitD;
    address s3DaoAddress = 0x7BdE8f8A3D59b42d0d8fab3a46E9f42E8e3c2dE8;


    function setUp() public {

        vm.startPrank(ADMIN);
        riteFactory = new RiteOfMolochFactory();
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
        assertTrue(riteAddress !=  address(0), "!created");
        
        riteOfMoloch = RiteOfMoloch(riteAddress);
        assertTrue(riteOfMoloch.hasRole(keccak256("ADMIN"),address(riteFactory)));
        
        /// @note these don't look right

        /// @dev ADMIN (deployer) has 0x00 Role
        assertTrue(riteOfMoloch.hasRole(riteOfMoloch.DEFAULT_ADMIN_ROLE(),ADMIN)); 

        /// @dev Factory has operator role in instance | is msg.sender
        assertTrue(riteOfMoloch.hasRole(keccak256("OPERATOR"),address(riteFactory))); 

        /// @dev Factory has operator role | is msg.sender
        assertTrue(riteFactory.hasRole(riteFactory.DEFAULT_ADMIN_ROLE(),ADMIN)); 
        
        /// @dev Factory dones NOT have deployer as ADMIN | is msg.sender !
        assertFalse(riteFactory.hasRole(keccak256("OPERATOR"),ADMIN));

        /// @dev Factory dones NOT have deployer as OPERATOR | is msg.sender !
        assertFalse(riteFactory.hasRole(keccak256("OPERATOR"),ADMIN)); 

        /// @dev ADMIN (deployer) does NOT have operator role | is NOT msg.sender !
        assertFalse(riteOfMoloch.hasRole(keccak256("OPERATOR"),ADMIN));
        
        /// example: NewRiteOfMoloch(cohortAddress: 0xf07907ab96e86b6f54e3a20a71ed1c4d1b3e5a41, deployer: 0x41444d494e000000000000000000000000000000, implementation: RiteOfMoloch: [0xc9db1acdc9aa5022f4a2362d0b2674a8a6310a4a], membershipCriteria: 0x0000000000000000000000000000000000000000, stakeToken: 0x0000000000000000000000000000000000000000, stakeAmount: 1, threshold: 1, time: 1)
    }

    function newRite(
        address m1,
        address s2,
        address t3,
        uint t4, 
        uint a5,
        uint d6
    ) public returns( RiteOfMoloch ) {
        InitD = InitData(m1,s2,t3, t4, a5,d6, "Name", "Symbol", "baseUri");
        uint lastID = riteFactory.iid();
        riteOfMoloch = RiteOfMoloch( riteFactory.createCohort(InitD, lastID));
    }

        //const member = "0xdf1064632754674acb1b804f2c65849d016eaf9d";


    // function getMoloch() public returns ( MolochDAO Moloch) {
    //     Moloch = MolochDAO(s3DaoAddress);
    // }




    //     struct InitData {
    //     address membershipCriteria; - when this is 0 Moloch(0).members error reachable
    //     address stakingAsset; - when this is 0 .transferFrom(...) error reachable
    //     address treasury;
    //     uint256 threshold; - when this is 0, everyone is a member.
    //     uint256 assetAmount;
    //     uint256 duration;
    //     string name;
    //     string symbol;
    //     string baseUri;
    // }

    function testZeroValues1() public {
        address at;

        vm.expectRevert("Minimum stake must be greater than zero!");
        InitD = InitData(address(0), address(0), address(0),0,0,0,"name","symbol","uri");  
        at= riteFactory.createCohort(InitD, 1);
        
        vm.expectRevert("Minimum duration must be greater than 0!");    
        InitD = InitData(address(0), address(0), address(0),0,1,0,"name","symbol","uri");  
        at = riteFactory.createCohort(InitD, 1);
        
        //////// Instance 1 :  0 0 0 0 1 1 - - -
        /// @note makes minimumShare =0, which in turn makes everyone a member since _checkMember will always be true in this state.
        InitD = InitData(address(0), address(0), address(0),0,1,1,"name","symbol","uri");  
        at = riteFactory.createCohort(InitD, 1);
        assertTrue(at != address(0));
        riteOfMoloch = RiteOfMoloch(at);

        //// @note threasury is address(0)
        assertTrue(riteOfMoloch.treasury() == address(0), "threasury not equal 0");

        vm.startPrank(address(32423523), address(32423523));

        vm.expectRevert(); /// "EvmError: Revert" @note bug: calls Moloch(address(0)).members(msg.sender); 
        riteOfMoloch.isMember(address(306761337));
        
        assertTrue(address(32423523).code.length == 0, 'Address is contract' );
        
        vm.expectRevert();  ///0x0000…0000::transferFrom 
        riteOfMoloch.joinInitiation(address(32423523));
        vm.stopPrank();
    }


}
