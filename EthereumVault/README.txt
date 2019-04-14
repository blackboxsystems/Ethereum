### Commit-Reveal Locked Vault

```
Basic Procedure:
  1. A secret is chosen and derived off-chain using the createLock() function.
  2. An optional amount of ether can be sent along with the hash via the lockVault() function to make a "claim".
  3. To unlock and release the funds (claim), the unlockVault() function is executed with the seed to compute the lock.
             
```
