# Secure Wallet
        A smart contract that handles ERC20 compatible tokens and ether with owner access control.  
    Contract functionality can be secured further with a basic commitment scheme using a hash that only permits 
    the owner to execute functions/value transfers provided that they prove they know the key (pre-image) that creates
    the hash (image).  Once the key is exposed to verify the hash in the locked script and execute the contract, 
    a new hash must be provided from a new, unknown key in order to ensure a locked contract state.
    
        In terms of practicality, the use of a commitment scheme to further restrict access to funds is used here as an extra
    security measure if a user's private key is compromised.  Quantum computers will eventually be able to 
    effectively factor asymmetric key pairs.  It is not unrealistic to consider the possibility of quantum computers being
    used to break account security on a blockchain that uses such algorithms.  Blockchains secure enormous amounts of value
    and provides an incentive to break the underlying security of blockchain protocols.  If asymmetric keys can be
    compromised and controlled decentralization becomes irrelavent because trust is broken at the most fundamental level.
    
        We need the ability for wallet contracts to pay for gas so that a signed transaction can signal an embedded fee
    to miners.  This way private keys dont need to have any associated funds stored on the blockchain to pay for 
    fees to execute signed transactions.
