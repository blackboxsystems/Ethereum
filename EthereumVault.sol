pragma solidity ^0.4.18;

/*  EthereumVault - Lock funds with a hash of some secret data.  
|   |_______
|  /|       1. createLock - generate a lock off-chain
|/__|____ / | 
|   |    |  |
|  (0)___|  2. lockVault - set the lock and send along some ether to store in the vault.
|  /  \  | /
|_______ 3. unlockVault - input the secret that maps to the lock and recover the funds 
*/

contract Owned {
    // contract owner
    address public owner;
    
    // mapping of approved accounts
    mapping(address => bool) public approved;

    // only owner modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // only approved, external accounts modifier
    modifier onlyApprovedExternal {
        // tx.origin is always the originator of a transaction,
        // msg.sender can be an intermediate contract calling into another
        require(approved[msg.sender] && tx.origin == msg.sender);
        _;
    }
    
    // Constructor function
    function Owned() public {
        // set and approve the owner
        owner = msg.sender;
        approved[msg.sender] = true;
    }

    /// @dev transferOwnership - assign a new owner to contract
    /// @param _newOwner address of new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        approved[_newOwner] = true;
    }
    
    /// @dev approve - approve a trusted account to use the contract
    /// @param _account address of new owner
    function approve(address _account) public onlyOwner {
        approved[_account] = true;
    }
    
    /// @dev disapprove - invalidate a prior approved account
    /// @param _account address of account to remove
    function disapprove(address _account) public onlyOwner {
        delete approved[_account];
    }
    
    /// @dev kill - destroy the contract
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
    
}

// main contract
contract EthereumVault is Owned {
    
    uint public m_pending;          // number of locked vaults
    enum Algorithm {keccak, sha}    // hash algorithm
    
    struct Vault {
        bool pending;   // pending state
        uint value;     // amount of locked ether
    }
    
    // mapping of vaults
    mapping(bytes32 => Vault) public vaults;
    // mapping of used locks
    mapping(bytes32 => bool) public used;
    
    /// @dev createLock - function to generate a lock off-chain
    /// @param _seed secret used to derive the lock
    /// @param _algorithm hash algorithm type
    function createLock(
        string _seed, 
        Algorithm _algorithm
    ) public view returns(bytes32 lock, bool valid) {
        lock = dhash(_seed, _algorithm);
        // protect reuse
        valid = !used[lock];
    }
    
    /// @dev lockVault - set a lock (hash) to verify later
    /// @param _lock hash of the secret seed
    function lockVault(
        bytes32 _lock
    ) public payable onlyApprovedExternal {
        require(!used[_lock]);
        vaults[_lock].pending = true;
        vaults[_lock].value = msg.value;
        used[_lock] = true;
        m_pending++;
    }
    
    /// @dev unlockVault - unlock a vault with the seed used to compute the lock
    /// @param _seed secret used to derive the lock
    /// @param _algorithm hash algorithm
    function unlockVault(
        string _seed, 
        Algorithm _algorithm
    ) public onlyApprovedExternal {
        bytes32 key = dhash(_seed, _algorithm);
        // verify state
        require(vaults[key].pending);
        // retrieve the value
        uint amount = vaults[key].value;
        // free up storage
        delete vaults[key];
        if (amount > 0) msg.sender.transfer(amount);
        m_pending--;
    }
    
    /// @dev changeLock - securely change a lock by simultaneously providing
    ///                 the seed for an existing lock and a new lock derived 
    ///                 from a new seed.
    /// @param _seed secret to hash
    /// @param _algorithm hash algorithm type
    function changeLock(
        string _seed, 
        Algorithm _algorithm, 
        bytes32 _newLock
    ) public onlyApprovedExternal {
        bytes32 key = dhash(_seed, _algorithm);
        // verify current and next state
        require(vaults[key].pending && !used[_newLock]);
        vaults[_newLock].pending = true;
        vaults[_newLock].value = vaults[key].value;
        used[_newLock] = true;
        delete vaults[key];
    }
    
    /// @dev dhash - internal double hash function
    /// @param _seed secret to hash
    /// @param _algorithm hash algorithm type
    function dhash(
        string _seed, 
        Algorithm _algorithm
    ) internal pure returns(bytes32) {
        if (_algorithm == Algorithm.keccak) {
            return keccak256(keccak256(_seed), bytes(_seed).length);
        } else { 
            return sha256(sha256(_seed), bytes(_seed).length);
        }
    }
    
    // reject sent ether
    function() public payable {
        require(msg.value == 0);
    }
    
}
