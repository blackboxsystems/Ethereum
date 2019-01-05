# Secure Wallet
        A smart contract that handles ERC20 compatible tokens and ether with owner access control.  
    Contract functionality can be secured further with a basic commitment scheme using a hash that only permits 
    the owner to execute functions/value transfers provided that they prove they know the key (pre-image) that creates
    the hash (image).  Once the secret is exposed to prove the committed hash and execute the contract, a new hash must be
    provided in order to ensure a locked contract state.

    It is important to consider a possible scenario where the owner provides the valid secret but the contract fails 
    due to some exception unrelated to the user input (network/node outage, hard/soft fork, etc.).  Nodes/Clients nearby will
    receive the broadcasted TXN, but the transaction fails to make it into a block and is pending.  Adversarial nodes
    who received the TXN now know the preimage to the current hash of the lock script, and if they have access to wallet 
    owners private key, they can generate a TXN with the preimage and include a high gas fee to outbid the previous 
    transaction to be mined first and direct the funds elsewhere.
    
    In terms of practicality, the use of a commitment scheme to further restrict access to funds is basically an extra
    security measure against a user's private key being compromised.  Quantum computers will eventually be able to 
    effectively factor asymmetric key pairs.  It is not unrealistic to consider the possibility of quantum computers being
    used to break account security on a blockchain that uses such algorithms.  Blockchains secure enormous amounts of value
    and provides an incentive to break underlying security of blockchain protocols.  Furthermore, if accounts can be
    compromised and controlled, decentralization becomes irrelavent because trust is broken at the most fundamental level.
