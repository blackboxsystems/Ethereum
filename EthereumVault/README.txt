Contracts using hash based computations

EthereumVault - Lock funds with the hash of some secret data.  Unlock and release the funds by providing
the secret (pre-image) used to derive the hash.  Storing ether in this contract is optional.  We can simply 
use it to verify the integrity of some underlying data, without exposing the underlying data itself if implemented.

Basic Procedure:
  1. A secret is chosen and hashed off-chain using the createLock() function.
  2. An amount of ether can be sent along with the hash via the lockVault() function.  
  3. To unlock and release the funds, the unlockVault() function is executed with the seed to compute the lock.
