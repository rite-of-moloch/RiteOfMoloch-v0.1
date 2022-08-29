pragma solidity ^0.8.13;

/// /parseb
/// @notice mock moloch; returns static, singular Member on members storage view function
contract MolochStooge {

        struct Member {
        address delegateKey; // the key responsible for submitting proposals and voting - defaults to member address unless updated
        uint256 shares; // the # of voting shares assigned to this member
        uint256 loot; // the loot amount available to this member (combined with shares on ragequit)
        bool exists; // always true once a member has been created
        uint256 highestIndexYesVote; // highest proposal index # on which the member voted YES
        uint256 jailed; // set to proposalIndex of a passing guild kick proposal for this member, prevents voting on and sponsoring proposals
    }

    function members(address memberAddress) external view returns (Member memory member) {
        member = Member(memberAddress, 10000000000000, 34523, true, 99, 0 );
    }



}