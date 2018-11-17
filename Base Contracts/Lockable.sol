pragma solidity ^0.4.18;


// import Owned contract
contract Lockable is Owned {
    bool public locked;
    bool public compliant;

    modifier onlyWhenUnlocked() {
        require(!locked);
        _;
    }
    
    modifier onlyAfterTime(uint time) {
        require(now >= time);
        _;
    }
    
    modifier onlyAfterBlock(uint number) {
        require(block.number >= number);
        _;
    }
    
    // if restricted, functions with this 
    // modifier can't be executed by other contracts
    modifier onlyExternalAccounts {
        if (compliant) require(tx.origin == msg.sender);
        _;
    }

    function lock() public onlyOwner {
        locked = true;
    }

    function unlock() public onlyOwner {
        locked = false;
    }

    function restrict() public onlyOwner {
        compliant = true;
    }

    function unrestrict() public onlyOwner {
        compliant = false;
    }
    
}
