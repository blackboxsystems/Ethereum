pragma solidity ^0.4.18;


// import Owned contract
contract Permissioned is Owned {
    mapping(address => bool) public approved;

    modifier onlyApproved(address _addr) {
        require(approved[_addr]);
        _;
    }
    
    function approve(address _addr) public onlyOwner {
        approved[_addr] = true;
    }
    
    function disapprove(address _addr) public onlyOwner {
        delete approved[_addr];
    }
    
}
