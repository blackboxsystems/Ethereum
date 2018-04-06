pragma solidity ^0.4.18;

// Owned contract
contract Owned {
    
    // contract owner
    address public owner; 
    
    // only owner modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // Constructor function
    function Owned() public {
        owner = msg.sender;
    }
    
    /// @dev transferOwnership - assign a new owner to contract
    /// @param _newOwner address of new owner
    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    /// @dev kill - destroys the contract
    function kill() internal {
        selfdestruct(owner);
    }
}

// data storage contract
contract BackupStorage is Owned {
    
    // index of data entry
    uint index;

    // data model
    struct Data {
        string protocol;    // protocol for data
        bytes data;         // raw bytes
    }
    
    // mapping of data entries
    mapping(uint => Data) public entries;
    
    /// @dev store - store new data
    /// @param _protocol arbitrary protocol for data
    /// @param _data raw bytes
    function store(string _protocol, bytes _data) public onlyOwner {
        Data storage entry = entries[index];    // init a new entry
        entry.protocol = _protocol;             // store protocol at index
        entry.data = _data;                     // store data at index
        index++;                                // increment index for next entry
    }
    
    /// @dev edit - edit an existing entry
    /// @param _index index of entry to edit
    /// @param _protocol arbitrary protocol for data
    /// @param _data raw bytes
    function edit(uint _index, string _protocol, bytes _data) public onlyOwner {
        require(_index < index);                // check range of index
        Data storage entry = entries[_index];
        if (_data.length > 0) entry.data = _data;
        if (bytes(_protocol).length > 0) entry.protocol = _protocol;
    }
    
    /// @dev erase - delete an entry, or destroy the entire contract
    /// @param _index index of entry
    /// @param _destroy kill the contract
    function erase(uint _index, bool _destroy) public onlyOwner {
        if (_destroy) kill();               // kill contract
        else delete entries[_index];        // delete an entry
    }
    
    function() public payable {
        require(msg.value > 0);
    }
    
}
