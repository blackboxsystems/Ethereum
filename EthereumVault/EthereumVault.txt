pragma solidity ^0.4.18;


contract Owned {
    // contract owner
    address public owner = msg.sender;

    // only owner modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    /// @dev changeOwner - assign a new owner to contract
    /// @param _newOwner address of new owner
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    /// @dev kill - fail-safe destroy
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
    
}


contract EthereumVault is Owned {
    enum Algorithm {keccak, sha}
    
    struct Vault {
        bool locked;
        uint value;
    }
    
    // mappings
    mapping(bytes32 => Vault) public vaults;
    mapping(bytes32 => bool) used;
    
    // events 
    event LockedVault(bytes32 lock, uint value);
    event UnlockedVault(bytes32 key, uint value);
    event ChangedLock(bytes32 key, bytes32 newLock);
    event Deposit(bytes32 lock, uint value);

    /// @dev createLock - function to generate a lock off-chain
    /// @param _seed secret used to derive the lock
    /// @param _algorithm hash algorithm type
    function createLock(
        string _seed, 
        Algorithm _algorithm
    ) public view returns(bytes32 lock, bool valid) {
        lock = digest(_seed, _algorithm);
        // check reuse
        valid = !used[lock];
    }
    
    /// @dev lockVault - send some ether with a lock to verify & release later
    /// @param _lock hash of the secret seed
    function lockVault(
        bytes32 _lock
    ) public payable onlyOwner {
        require(!used[_lock]);
        vaults[_lock].locked = true;
        vaults[_lock].value = msg.value;
        used[_lock] = true;
        LockedVault(_lock, msg.value);
    }
    
    /// @dev unlockVault - unlock a vault to release funds
    /// @param _seed secret used to derive the lock
    /// @param _algorithm hash algorithm
    function unlockVault(
        string _seed, 
        Algorithm _algorithm
    ) public onlyOwner {
        bytes32 key = digest(_seed, _algorithm);
        // verify state
        require(vaults[key].locked);
        // retrieve the value
        uint amount = vaults[key].value;
        // free storage
        delete vaults[key];
        if (amount > 0) require(msg.sender.send(amount));
        UnlockedVault(key, amount);
    }
    
    /// @dev changeLock - securely change a lock by simultaneously providing
    ///                 the seed for an existing lock and a new lock derived 
    ///                 from a new seed.
    /// @param _seed value that hashes to the current lock
    /// @param _algorithm hash algorithm type
    /// @param _newLock the new lock
    function changeLock(
        string _seed, 
        Algorithm _algorithm, 
        bytes32 _newLock
    ) public onlyOwner {
        bytes32 key = digest(_seed, _algorithm);
        // verify current and next state
        require(vaults[key].locked && !used[_newLock]);
        vaults[_newLock].locked = true;
        vaults[_newLock].value = vaults[key].value;
        used[_newLock] = true;
        // free storage
        delete vaults[key];
        ChangedLock(key, _newLock);
    }
    
    /// @dev deposit - allow deposits to a lock
    /// @param _lock hash of seed
    function deposit(
        bytes32 _lock
    ) public payable {
        require(vaults[_lock].locked);
        vaults[_lock].value += msg.value;
        Deposit(_lock, msg.value);
    }
    
    /// @dev digest - internal double hash function
    /// @param _seed secret to hash
    /// @param _algorithm hash algorithm type
    function digest(
        string _seed, 
        Algorithm _algorithm
    ) internal pure returns(bytes32) {
        return  _algorithm == Algorithm.keccak ? 
                keccak256(keccak256(_seed), bytes(_seed).length) :
                sha256(sha256(_seed), bytes(_seed).length);
    }
    
    // reject ether
    function() public payable {
        require(msg.value == 0);
    }
    
}
