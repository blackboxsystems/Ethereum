pragma solidity ^0.4.21;

// SecureWallet - A smart contract that handles sent tokens and ether with 
// owner access control with optional one-time key rotation 
// that locks contract functionality.

// ERC20 interface
contract ERC20Token {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Owned {
    address public owner = msg.sender;
    bool public locked;
    bytes32 private key;
    
    // mapping of used keys
    mapping(bytes32 => bool) used;
    
    // require seed (pre-image) and new key modifier
    modifier authorize(string secret, bytes32 newKey) {
        if (locked) {
            require(digest(secret) == key && !used[newKey]);
            key = newKey;
            // track used keys
            if (newKey != 0) used[newKey] = true;
	    else locked = false;
        }
        _;
    }
    
    // only when unlocked modifier
    modifier onlyWhenUnlocked {
        require(!locked);
        _;
    }
    
    // only when locked modifier
    modifier onlyWhenLocked {
        require(locked);
        _;
    }
    
    // only owner modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // MARK public view functions
    
    /// @dev createKey - create key off-chain
    /// @param _seed secret used to create the key (back this up!!!)
    function createKey(
        string _seed
    ) public pure returns(bytes32) {
        return digest(_seed);
    }
    
    // MARK public functions

    /// @dev changeOwner - change ownership of the contract
    /// @param _newOwner new owner address
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new seed
    function changeOwner(
        address _newOwner,
        string _seed, 
        bytes32 _newKey
    ) public onlyOwner authorize(_seed, _newKey) {
        owner = _newOwner;
    }
 
    /// @dev lock - lock the contract and functions with a key
    /// @param _key computed key via createKey function
    function lock(
        bytes32 _key
    ) public onlyOwner onlyWhenUnlocked {
        require(_key != 0 && !used[_key]);
	used[_key] = true;
        locked = true;
        key = _key;
    }
    
    /// @dev changeKey - change the key that locks contract functionality
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new seed
    function changeKey(
        string _seed, 
        bytes32 _newKey
    ) public onlyOwner onlyWhenLocked authorize(_seed, _newKey) returns(bool) {
        require(_newKey != 0);
        return true;
    }

    /// @dev unlock - unlock the contract with the seed for the current key
    /// @param _seed secret for current key to unlock
    function unlock(
        string _seed
    ) public onlyOwner onlyWhenLocked authorize(_seed, 0) returns(bool) {
        return true;
    }
    
    function kill(
        string _seed
    ) public onlyOwner authorize(_seed, 0) {
        selfdestruct(owner);
    }
    
    // MARK internal functions
    
    /// @dev digest - internal hash function
    /// @param _seed secret to compute the key
    function digest(
        string _seed
    ) internal pure returns(bytes32) {
        return keccak256(keccak256(_seed), bytes(_seed).length);
    }
}

contract SecureWallet is Owned {
    uint public sweepGasLimit = 25000; // gas limit to prevent out of gas exceptions
    uint index;                        // registered token index
    
    // registered tokens
    mapping(uint => address) tokens;
    
    // events
    event RegisterToken(uint id, address _token);
    event UnregisterToken(address _token);
    event Approved(address _token, address _tokenOwner, address _spender, uint _value);
    event TransferToken(address _token, address _from, address _to, uint value);
    
    // accept ether sent to contract
    function() public payable {
        require(msg.value > 0);
    }
    
    // MARK public view functions
    
    /// @dev tokenBalance - constanct lookup of contract's token balance 
    /// @param _tokenId index of registered token
    function tokenBalance(
        uint _tokenId
    ) public view returns(address tokenAddress, uint balance) {
        ERC20Token token = ERC20Token(tokens[_tokenId]);
        return (tokens[_tokenId], token.balanceOf(this));
    }
    
    // MARK public functions
    
    /// @dev changeSweepGasLimit - change the gas limit to break out of out of gas exceptions 
    /// @param _limit gas limit to set for sweep function
    function changeSweepGasLimit(uint _limit) public onlyOwner {
        sweepGasLimit = _limit;
    }
    
    /// @dev registerToken - register a token that the contract owns 
    /// @param _token address of token contract
    function registerToken(address _token) public onlyOwner {
        tokens[index] = _token;
        emit RegisterToken(index, _token);
        index++;
    }
    
    /// @dev unregisterToken - unregister a token assigned to the contract 
    /// @param _tokenId index of registered token address
    function unregisterToken(uint _tokenId) public onlyOwner {
        emit UnregisterToken(tokens[_tokenId]);
        delete tokens[_tokenId];
    }

    /// @dev approve - approve a spender to spend tokens on behalf of the contract
    /// @param _tokenId index of registered token address
    /// @param _spender address of spender
    /// @param _value approved amount for spender to spend
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new secret seed
    function approve(
        uint _tokenId,
        address _spender,
        uint _value,
        string _seed,
        bytes32 _newKey
    ) public onlyOwner authorize(_seed, _newKey) {
        ERC20Token token = ERC20Token(tokens[_tokenId]);
        // call token contract's approve function
        emit Approved(tokens[_tokenId], this, _spender, _value);
        require(token.approve(_spender, _value));
    }

    /// @dev transferToken - transfer tokens from contract
    /// @param _tokenId index of registered token address
    /// @param _to address of token recipient, defaults to owner
    /// @param _value token amount to send to the recipient, defaults to contract token balance
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new secret seed
    function transferToken(
        uint _tokenId,
        address _to, 
        uint _value,
        string _seed,
        bytes32 _newKey
    ) public onlyOwner authorize(_seed, _newKey) {
        if (_to == 0) _to = owner;
        // get token balance
        ERC20Token token = ERC20Token(tokens[_tokenId]);
        uint balance = token.balanceOf(this);
        // check value to send
        if (_value > balance || _value == 0) _value = balance;
        require(_value > 0);
        // transfer
        emit TransferToken(token, this, _to, _value);
        require(token.transfer(_to, _value));
    }
    
    /// @dev transferEther - transfer ether from contract to a recipient
    /// @param _to address of token recipient, defaults to owner
    /// @param _value amount of ether to withdraw, defaults to contract balance
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new secret seed
    function transferEther(
        address _to, 
        uint _value,
        string _seed,
        bytes32 _newKey
    ) public onlyOwner authorize(_seed, _newKey) {
        // default to owner
        if (_to == 0) _to = owner;
        uint balance = address(this).balance;
        // check value to send
        if (_value > balance || _value == 0) _value = balance;
        require(_value > 0);
        require(_to.send(_value));
    }
    
    /// @dev sweep - withdraw all tokens and ether from contract to a recipient
    /// @param _to address of token recipient
    /// @param _allTokens flag to sweep all tokens
    /// @param _allEther flag to sweep all ether
    /// @param _seed secret for current key to unlock
    /// @param _newKey new key computed from a new secret seed
    function sweep(
        address _to,
        bool _allTokens,
        bool _allEther,
        string _seed,
        bytes32 _newKey
    ) public onlyOwner authorize(_seed, _newKey) {
        require(_allTokens || _allEther);
        if (_to == 0) _to = owner;
        uint amount = 0;
        if (_allTokens) {
            // iterate through tokens to transfer
            for (uint i = 0; i < index; i++) {
                if (tokens[i] != 0) {
                    ERC20Token token = ERC20Token(tokens[i]);
                    amount = token.balanceOf(this);
                    if (amount > 0) {
                        // transfer tokens
                        emit TransferToken(token, this, _to, amount);
                        require(token.transfer(_to, amount));
                    }
                    // break out if we will fail on out of gas
                    if (gasleft() <= sweepGasLimit) break;
                }
            }
        }
        // send ether if applicable
        if (_allEther) {
            uint balance = address(this).balance;
            if (balance > 0) require(_to.send(balance));
        }
    }

}
