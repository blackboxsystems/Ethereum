pragma solidity ^0.4.18;

// import Owned contract
contract Mortal is Owned {
    
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
    
}
