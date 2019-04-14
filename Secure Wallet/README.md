# Secure Wallet
        A smart contract that handles ERC20 compatible tokens and ether with owner access control.  
    Contract functionality can be secured further with a basic commitment scheme using a hash that only permits 
    the owner to execute functions/value transfers provided that they prove they know the key (pre-image) that creates
    the hash (image).  Once the key is exposed to verify the hash in the locked script and execute the contract, 
    a new hash must be provided from a new, unknown key in order to ensure a locked contract state.
    
        In terms of practicality, the use of a commitment scheme to further restrict access to funds is 
    used here as an extra security measure if a user's private key is compromised.  Private blockchains with 
    trusted human interaction can deploy biometrics or 2FA to supply the commit/reveal key material on top 
    of the computer/machine holding the signing key.
    
        Furthermore, quantum computers will eventually break current asymmetric algorithms.  If asymmetric keys can be 
    factored decentralization becomes irrelavent because trust is broken at the most fundamental level.
    
        Accounts associated to asym key pairs can still be drained of funds(gas) which need to fuel signed contract  
    transactions for commit/reveal schemes. We need the ability for wallet contracts to pay for gas so that a signed
    transaction can signal an embedded fee to miners/node operators.  Private keys would not need to control any ETH to pay 
    for fees on signed contract transactions.
