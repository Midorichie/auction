# Dutch Auction Smart Contract

This project implements a Dutch Auction using Clarity on the Stacks blockchain.

## Features

### Dutch Auction (`dutch-auction.clar`)
- Starts at a high price and decreases over time.
- Buyer can purchase at the current price before the auction ends.
- Tracks ownership, timing, pricing, and restricts unauthorized access.

### Bid History (`bid-history.clar`)
- Keeps a record of each bid (auction ID + bidder + price + block).
- Useful for auditing and verifying auction activity.

## Setup

### Install Clarinet

```bash
npm install -g @hirosystems/clarinet
```

### Run locally

```bash
clarinet check
clarinet console
```

## Project Structure

- `contracts/dutch-auction.clar` – Main auction logic.
- `contracts/bid-history.clar` – Tracks bidder history.
- `Clarinet.toml` – Project setup.
- `README.md` – Guide and documentation.
