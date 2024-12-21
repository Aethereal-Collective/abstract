# Deploy and Verify a Smart Contract on the Abstract Testnet

## Prerequisites
To deploy a smart contract, ensure that you have sufficient gas fees on the Abstract Testnet. You can acquire testnet gas:

- **Faucet**: Get free gas from the [Abstract Testnet Faucet](https://faucet.triangleplatform.com/abstract/testnet).
- **Bridge**: Transfer funds from the Sepolia testnet using the [Official Bridge](https://portal.testnet.abs.xyz/bridge/).

You can deploy from a local terminal (like Ubuntu) or through a Virtual IDE such as [GitHub Codespaces](https://github.com/codespaces).

## Installation Steps
There are two ways to install the necessary tools. Choose one of the following methods:

### Method 1: Using `curl`
   ```bash
   curl -sSL -o abstract.sh https://raw.githubusercontent.com/Aethereal-Collective/abstract/refs/heads/main/abstract.sh && chmod +x abstract.sh && ./abstract.sh
  ```
### Method 2: Using `wget`
  ```bash
  wget https://raw.githubusercontent.com/Aethereal-Collective/abstract/refs/heads/main/abstract.sh && chmod +x abstract.sh && ./abstract.sh
  ```

# Important Configuration Info

While running the script, you may encounter a prompt asking for the type of project to create:

```bash
? What do you want to do? … 
  Create a JavaScript project
▸ Create a TypeScript project
  Create a TypeScript project (with Viem)
  Create an empty hardhat.config.js
  Quit
```

### What You Need to Do:
1. Choose **"Create a TypeScript project"**
2. Press **Enter** three times to finalize the setup.

---
