# Minimal MultiSig Wallet

A secure, expert-level implementation of a multi-signature wallet. This contract requires multiple authorized owners to approve a transaction before it can be executed on-chain.



## Core Logic
1. **Submit**: An owner submits a transaction (target, value, data).
2. **Confirm**: Other owners call `confirmTransaction`.
3. **Execute**: Once the `required` threshold is met, anyone can call `executeTransaction`.

## Security Features
* **Threshold Protection**: Logic prevents the threshold from exceeding the number of owners.
* **Reentrancy Guards**: Secure execution patterns to prevent state manipulation.
* **Non-Duplicate Voting**: Integrated checks to ensure an owner cannot vote twice on the same proposal.

## Setup
1. `npm install`
2. Define owners and threshold in `deploy.js`.
3. Deploy via Hardhat or Remix.
