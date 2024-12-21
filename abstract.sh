#!/bin/bash

curl -s https://raw.githubusercontent.com/aethjuice/aethjuice/main/logo.sh | bash
sleep 3

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN="\033[0;36m"


show() {
    case $2 in
        "error")
            echo -e "${RED}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${YELLOW}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

install_dependencies() {
    clear
    show "Installing Node.js..." "progress"

    if ! command -v nvm &>/dev/null; then
        show "NVM not found. Installing NVM..." "progress"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        if [ $? -ne 0 ]; then
            show "Failed to install NVM." "error"
            exit 1
        fi
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    else
        show "NVM is already installed. Loading NVM..." "progress"
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi

    NODE_VERSION=${1:-"node"}
    show "Installing Node.js version: ${NODE_VERSION}..." "progress"
    nvm install "$NODE_VERSION"
    if [ $? -ne 0 ]; then
        show "Failed to install Node.js version ${NODE_VERSION}." "error"
        exit 1
    fi
    clear
    show "Initializing Hardhat project..." "progress"
    npx hardhat init --yes
    clear
    show "Installing package. . ." "progress"
    npm install -D @matterlabs/hardhat-zksync @matterlabs/zksync-contracts zksync-ethers@6 ethers@6

    show "All dependencies installation completed."
}

compilation() {
    show "Updating the Hardhat configuration..." "progress"
    cat <<EOL > hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";
import "@matterlabs/hardhat-zksync";

const config: HardhatUserConfig = {
  zksolc: {
    version: "latest",
    settings: {
      enableEraVMExtensions: false,
    },
  },
  defaultNetwork: "abstractTestnet",
  networks: {
    abstractTestnet: {
      url: "https://api.testnet.abs.xyz",
      ethNetwork: "sepolia",
      zksync: true,
      verifyURL: "https://api-explorer-verify.testnet.abs.xyz/contract_verification",
    },
  },
  solidity: {
    version: "0.8.24",
  },
};

export default config;
EOL
    mv contracts/Lock.sol contracts/HelloAbstract.sol
    cat <<EOL > contracts/HelloAbstract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract HelloAbstract {
    function sayHello() public pure virtual returns (string memory) {
        return "Heyya! This smart contract has been deployed with assistance from aethereal.";
    }
}
EOL

    npx hardhat clean
    npx hardhat compile --network abstractTestnet
}

setup_wallet() {
    read -p "Enter your wallet private key (without 0x): " DEPLOYER_PRIVATE_KEY
    mkdir -p deploy
    cat <<EOL > deploy/deploy.ts
import { Wallet } from "zksync-ethers";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { Deployer } from "@matterlabs/hardhat-zksync";

export default async function (hre: HardhatRuntimeEnvironment) {
  const wallet = new Wallet("$DEPLOYER_PRIVATE_KEY");
  const deployer = new Deployer(hre, wallet);
  const artifact = await deployer.loadArtifact("HelloAbstract");

  const tokenContract = await deployer.deploy(artifact);
  console.log(\`Your deployed contract address : \${await tokenContract.getAddress()}\`);
}
EOL
}

deploy_contracts() {
    read -p "How many contracts would you like to deploy? " CONTRACT_COUNT
    > contracts.txt

    for ((i = 1; i <= CONTRACT_COUNT; i++)); do
        show "Deploying contract #$i..." "progress"
        npx hardhat deploy-zksync --script deploy.ts
        show "Contract #$i deployed successfully"
        echo "------------------------------------"
        read -p "Please enter the deployed contract address for contract #$i : " CONTRACT_ADDRESS
        echo "$CONTRACT_ADDRESS" >> contracts.txt
    done
}

verify_contracts() {
    while IFS= read -r CONTRACT_ADDRESS; do
        show "Verifying smart contract at address: $CONTRACT_ADDRESS..." "progress"
        npx hardhat verify --network abstractTestnet "$CONTRACT_ADDRESS"
    done < contracts.txt
}

menu() {
    echo -e "${CYAN}1) Install Dependencies${NORMAL}"
    echo -e "${CYAN}2) Modify configuration & compile${NORMAL}"
    echo -e "${CYAN}3) Wallet setup${NORMAL}"
    echo -e "${CYAN}4) Deploy contract${NORMAL}"
    echo -e "${CYAN}5) Verify contracts${NORMAL}"
    echo -e "${CYAN}6) Exit${NORMAL}"

    read -p "Enter your choice: " CHOICE

    case $CHOICE in
        1) install_dependencies ;;
        2) compilation ;;
        3) setup_wallet ;;
        4) deploy_contracts ;;
        5) verify_contracts ;;
        6) show "Exiting..." "progress"; exit 0 ;;
        *) show "Invalid choice. Please try again." "error" ;;
    esac
}

while true; do
    menu
done
