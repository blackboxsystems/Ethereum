# Ethereum
Solidity based smart contracts.


BackupStorage - Store some arbitrary data.  The creator of the contract is the owner. Only the owner
			        can interact with the contract to add, modify, or delete data.

EthereumVault -  Store funds using the hash of some secret data.  This can allow secure storage 
			        and access control of stored funds.  When the contract is first created, the creator is the owner.  
              The owner has the ability to approve other trusted accounts who can interact with the contract
              to store and retrieve funds.  The security model concept for this contract type is based around 
              forcing an adversary to know BOTH the private key for the owner account, or another account approved
              by the owner, and the secret that can unlock funds in the contract.

EthereumVault Procedure:
1. A secret is chosen and hashed using the createLock() off-chain function to create the "lock".  
2. An amount of ether is sent along with the lock via the lockVault() function, which only approved 
   accounts can execute.  
3. To unlock and release the funds, the unlockVault() function can be executed by any approved account which inputs the 
   correct secret that maps to the valid lock for those funds.
