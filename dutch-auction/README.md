# Dutch Auction Smart Contract

This project implements a Dutch Auction using the Clarity language on the Stacks blockchain.

## 🛠 Features

- Owner starts the auction with initial price, reserve price, decrement rate, start and end block.
- The price decreases over time based on block height.
- First buyer to call `buy` at or above the current price wins.

## 📦 Setup

### 1. Install Clarinet

```bash
npm install -g @hirosystems/clarinet
```

### 2. Clone the project and run tests

```bash
git clone <your-repo-url>
cd dutch-auction
clarinet check
clarinet test
```

### 3. Files

- `contracts/dutch-auction.clar` – Main Clarity contract.
- `Clarinet.toml` – Project config.
- `README.md` – Project description and usage.

## 🚀 Deploying

Use Clarinet or the Stacks CLI to deploy the contract to a testnet or mainnet.
