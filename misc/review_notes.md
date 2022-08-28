## Smart Contract Review Notes

### Unclear
- The tests in the original repository imply the the deployer gains `ADMIN` and `OPERATOR` roles on deployment. This is unclear at the moment as those roles seem to be assigned to the factory and not the address initiating the transaction. ( see @dev statements of `testDeploys()` in `RiteOfMoloch.t.sol`)

- case: initiate is member, but has not yet called `claimStake()` is not accounted for exclusion from non-slashable category `if (block.timestamp > deadline && _staked[initiate] > 0)` 

- week specified but not enforced
```
// enforce that the minimum time is greater than 1 week
require(newMaxTime > 0, "Minimum duration must be greater than 0!"); 
```

### Suggestions
- Insufficient 0-value checks. This might be a feature. Unclear, however it does go against general good practice.

### Concerns
- A new RiteOfMoloch instance can be successfully initialized with `InitData.threshold = 0`.
In such an state `isMember(anyAddress_)` results in a unnaccounted for EVM Error due to the fact that `InitData.membershipCriteria` is 0. Any call to dao will have same result. The same applies for `InitData.stakingAsset`: can be zero and transfersFrom address(0) will error.
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
### Critical
- griefing race attack (tbc)