## Smart Contract Review Notes


- The tests in the original repository imply the the deployer gains `ADMIN` and `OPERATOR` roles on deployment. This is unclear at the moment as those roles seem to be assigned to the factory and not the address initiating the transaction. ( see @dev statements of `testDeploys()` in `RiteOfMoloch.t.sol`)
- Insufficient 0-value checks. This might be a feature. Unclear, however it does go against general good practice.
- A new RiteOfMoloch instance can be successfully initialized with `InitData.threshold = 0`.
In such an state `isMember(anyAddress_)` results in a unnaccounted for EVM Error due to the fact that `InitData.membershipCriteria` is 0. Any call to dao will have same result.




