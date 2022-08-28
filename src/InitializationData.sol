// SPDX-License-Identifier: MIT
// @author st4rgard3n, bitbeckers, MrDeadce11 / Raid Guild
pragma solidity ^0.8.4;

/// @dev why contract? @todo
contract InitializationData {
    /// @todo correct natspec
    // object is used to initialize new cohorts
    // daoAddress_ the contract address read from in order to ascertain cohort completion
    // tokenAddress_ the contract address for the asset which is staked into the cohort contract
    // treasury_ the address which receives tokens when initiates are slashed
    // shareThreshold_ the minimum amount of criteria which constitutes membership ---  @note confusing
    // minStake_ the minimum amount of staking asset required to join the cohort
    // name_ the name for the cohort's soul bound tokens
    // symbol_ the ticker symbol for cohort's soul bound token
    // baseURI_ the uniform resource identifier for accessing soul bound token metadata
    struct InitData {
        address membershipCriteria; // 0xfe1084bc16427e5eb7f13fc19bcd4e641f7d571f - Moloch
        address stakingAsset; // 0x18e9262e68cc6c6004db93105cc7c001bb103e49,
        address treasury; // 0xfe1084bc16427e5eb7f13fc19bcd4e641f7d571f
        uint256 threshold; // 100
        uint256 assetAmount; // 5000000000000000000000
        uint256 duration; // 15780000
        string name; // "Rite of Moloch - Cohort V",
        string symbol;  //  "ROM"
        string baseUri; // "https://ipfs.io/ipfs/Qmd286K6pohQcTKYqnS1YhWrCiS4gz7Xi34sdwMe9USZ7u"
    }



}
