# Ethereum
Solidity based smart contracts.


BackupStorage - Store some arbitrary data.  The creator of the contract is the owner. Only the owner can interact with the 
		contract to add, modify, or delete data.

EthereumVault - Store funds using the hash of some secret data.  This can increase security/access control of 				funds even if the private key to the account is compromised.

EthereumVault Procedure:
1. A secret is chosen and hashed using the createLock() off-chain function to create the "lock".  
2. An amount of ether is sent along with the lock via the lockVault() function. 
3. To unlock and release the funds, the unlockVault() function is executed with the seed to compute the vault lock.
