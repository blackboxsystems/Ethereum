# Secure Wallet
        A smart contract that handles ERC20 compatible tokens and ether with owner access control.  
    Contract functionality can be secured further with a basic commitment scheme using a hash that only permits 
    the owner to execute functions/value transfers provided that they prove they know the value (pre-image) that creates
    the hash.  Once the secret is exposed to prove the committed hash, the contract will execute and a new key is needed 
    to ensure a locked contract state.  

    It is important to consider a possible scenario where the owner provides the valid secret but the contract fails 
    due to some exception unrelated to the user input.  More research is needed to see the if a secret could be exposed 
    without fully executing the contract whereby the key is vulnerable to attack.

    In terms of practicality, the use of a commitment scheme to further restrict access to funds is basically an extra
    security measure against a user's private key being compromised.  Quantum computers will eventually be able to 
    effectively factor asymmetric key pairs.  It is not unrealistic to consider the possibility of quantum computers being
    used to break account security on a blockchain that uses such algorithms.  Blockchains secure enormous amounts of value
    which, in itself, provides an incentive to utilize such technology for these purposes.  Furthermore, if accounts can be
    compromised and controlled, decentralization becomes irrelavent because trust is broken at the most fundamental level.
