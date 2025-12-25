# $PRE Token Specification

## Overview

$PRE is the official utility token for the Pregame ecosystem, designed to enhance user engagement through blockchain-based rewards and in-app purchases. The token launches on **Base** (Coinbase's Layer 2) for optimal user experience and mainstream adoption.

---

## Token Details

| Attribute | Value |
|-----------|-------|
| **Name** | Pregame Token |
| **Symbol** | $PRE |
| **Blockchain** | Base (Ethereum L2) |
| **Standard** | ERC-20 |
| **Total Supply** | 500,000,000 (500M) |
| **Decimals** | 18 |
| **Contract** | TBD (not yet deployed) |

---

## Why Base?

Base was selected over Polygon based on 2025 market analysis:

1. **Coinbase Integration** - Seamless fiat-to-crypto onramp for mainstream users
2. **ETH for Gas** - Users don't need a separate gas token (unlike POL on Polygon)
3. **#1 L2 by Activity** - 20.8M monthly active users, $5.1B TVL
4. **Institutional Adoption** - JPMorgan, major DeFi protocols on Base
5. **Lower Friction** - Better UX for sports fans who aren't crypto-native
6. **Cost Efficient** - Sub-cent transaction fees

---

## Tokenomics

### Distribution

| Allocation | Percentage | Amount | Vesting |
|------------|------------|--------|---------|
| **Rewards Pool** | 50% | 250M | 5-10 year distribution |
| **Company Reserve** | 20% | 100M | 4-year vest, 1-year cliff |
| **Liquidity** | 15% | 75M | Immediate for DEX pools |
| **Team & Advisors** | 10% | 50M | 4-year vest, 1-year cliff |
| **Initial Airdrop** | 5% | 25M | Immediate to early users |

### Token Sinks (Deflationary Mechanisms)

- Premium feature purchases (partial burn)
- Exclusive content access
- Tournament entry fees
- NFT minting fees

### Inflation Control

- Fixed maximum supply (no additional minting after initial distribution)
- Rewards pool depletes over time
- Burn mechanisms reduce circulating supply

---

## Use Cases

### Earning $PRE

| Action | Reward | Frequency |
|--------|--------|-----------|
| **Correct Prediction** | 10 $PRE | Per match |
| **Exact Score Prediction** | 50 $PRE | Per match |
| **Daily Check-in** | 5 $PRE | Daily |
| **Refer a Friend** | 100 $PRE | Per referral |
| **Win Weekly Leaderboard** | 500 $PRE | Weekly |
| **Win Tournament Bracket** | 5,000 $PRE | Per tournament |
| **Complete Profile** | 25 $PRE | One-time |
| **Connect Social** | 10 $PRE | Per platform |

### Spending $PRE

| Feature | Cost | Description |
|---------|------|-------------|
| **AI Match Insights** | 5 $PRE | Unlock AI prediction for a match |
| **Premium Stats Pack** | 50 $PRE | Advanced team/player statistics |
| **Ad-Free Week** | 25 $PRE | Remove ads for 7 days |
| **Tournament Entry** | 100 $PRE | Enter premium bracket pools |
| **Exclusive Content** | 20 $PRE | Behind-the-scenes, interviews |
| **Profile Badge** | 10 $PRE | Cosmetic profile customization |
| **NFT Moment** | 200 $PRE | Mint World Cup moment NFT |

### Staking & Loyalty Tiers

| Tier | Stake Required | Benefits |
|------|----------------|----------|
| **Fan** | 0 $PRE | Basic features |
| **Super Fan** | 1,000 $PRE | 10% bonus rewards, priority support |
| **VIP Fan** | 10,000 $PRE | 25% bonus rewards, exclusive content, early access |
| **Legend** | 100,000 $PRE | 50% bonus rewards, governance voting, NFT airdrops |

---

## Technical Architecture

### Smart Contract (ERC-20)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PregameToken is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    uint256 public constant MAX_SUPPLY = 500_000_000 * 10**18;

    constructor(address initialOwner)
        ERC20("Pregame Token", "PRE")
        Ownable(initialOwner)
        ERC20Permit("Pregame Token")
    {
        _mint(initialOwner, MAX_SUPPLY);
    }
}
```

### Base Network Configuration

```
Network Name: Base Mainnet
Chain ID: 8453
RPC URL: https://mainnet.base.org
Block Explorer: https://basescan.org
Currency: ETH

Network Name: Base Sepolia (Testnet)
Chain ID: 84532
RPC URL: https://sepolia.base.org
Block Explorer: https://sepolia.basescan.org
Currency: ETH
```

### Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Pregame World Cup App                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Token Cubit │  │ Wallet Cubit│  │ Transaction Cubit   │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
│         │                │                     │             │
│  ┌──────┴────────────────┴─────────────────────┴──────────┐ │
│  │                    Token Service                        │ │
│  └──────────────────────────┬──────────────────────────────┘ │
│                             │                                │
│  ┌──────────────────────────┴──────────────────────────────┐ │
│  │                  Base Blockchain Service                 │ │
│  └──────────────────────────┬──────────────────────────────┘ │
└─────────────────────────────┼───────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │   Base Network    │
                    │   (Coinbase L2)   │
                    └───────────────────┘
```

---

## Wallet Integration

### Supported Wallets

1. **Coinbase Wallet** (Recommended) - Native Base support, easy onramp
2. **MetaMask** - Most popular, requires Base network add
3. **Rainbow** - Mobile-first, good UX
4. **WalletConnect** - Universal protocol for any compatible wallet

### Connection Flow

1. User taps "Connect Wallet"
2. App presents wallet options (Coinbase Wallet recommended)
3. User approves connection in wallet app
4. App receives wallet address
5. App queries $PRE balance from Base
6. User can now earn/spend $PRE

### Gasless Transactions (Future)

Using ERC-4337 Account Abstraction and Paymasters:
- Pregame sponsors gas fees for users
- Users transact without holding ETH
- Improves UX for non-crypto-native users

---

## Security Considerations

### Smart Contract

- [ ] OpenZeppelin contracts (battle-tested)
- [ ] Professional security audit before mainnet
- [ ] Multi-sig ownership (Gnosis Safe)
- [ ] Timelock for admin functions
- [ ] No mint function after deployment

### App Security

- Private keys never leave user's wallet
- Read-only access by default
- Transaction signing requires user approval
- No custody of user funds

---

## Compliance Framework

### Token Classification

$PRE is designed as a **utility token**, NOT a security:

- No investment language or profit promises
- Pure utility: access to app features only
- No revenue sharing or equity claims
- No ICO or fundraising sale

### Regulatory Strategy

1. **Third-Party Processors** - Use Coinbase Commerce, MoonPay (they handle KYC)
2. **Utility Positioning** - Clear terms of service, no investment language
3. **Legal Review** - Securities attorney sign-off before launch
4. **Geo-Restrictions** - Block restricted jurisdictions if needed

### Tax Considerations

- Users may owe income tax on earned $PRE
- Capital gains on token sales
- App provides transaction history for tax reporting

---

## Implementation Phases

### Phase 1: Infrastructure (Current)
- [x] Token specification document
- [ ] Flutter Base integration service
- [ ] Wallet connection UI
- [ ] Balance display widgets
- [ ] Local transaction tracking

### Phase 2: Testnet Launch
- [ ] Deploy contract to Base Sepolia
- [ ] Integrate testnet tokens in app
- [ ] Test earning/spending flows
- [ ] Security audit

### Phase 3: Mainnet Launch
- [ ] Deploy contract to Base Mainnet
- [ ] Initial token distribution
- [ ] DEX liquidity (Uniswap on Base)
- [ ] Public announcement

### Phase 4: Advanced Features
- [ ] Staking smart contract
- [ ] Governance voting
- [ ] NFT marketplace
- [ ] Gasless transactions

---

## API Reference

### Token Service Methods

```dart
// Get user's $PRE balance
Future<BigInt> getBalance(String walletAddress);

// Get transaction history
Future<List<TokenTransaction>> getTransactions(String walletAddress);

// Estimate gas for transfer
Future<BigInt> estimateTransferGas(String to, BigInt amount);

// Sign and send transfer (requires wallet)
Future<String> transfer(String to, BigInt amount);

// Get token metadata
Future<TokenMetadata> getTokenInfo();
```

### Events

```dart
// Balance changed
Stream<BigInt> onBalanceChanged(String walletAddress);

// New transaction
Stream<TokenTransaction> onTransaction(String walletAddress);

// Wallet connected/disconnected
Stream<WalletConnectionState> onWalletStateChanged();
```

---

## Resources

### Base Documentation
- [Base Docs](https://docs.base.org/)
- [Base Bridge](https://bridge.base.org/)
- [BaseScan Explorer](https://basescan.org/)

### Development Tools
- [Hardhat](https://hardhat.org/) - Smart contract development
- [OpenZeppelin](https://openzeppelin.com/contracts/) - Secure contract templates
- [Web3dart](https://pub.dev/packages/web3dart) - Flutter Ethereum library
- [WalletConnect](https://walletconnect.com/) - Wallet integration

### Testnet Faucets
- [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet)
- [Alchemy Sepolia Faucet](https://sepoliafaucet.com/)

---

## Changelog

### v1.0.0 (2025-12-23)
- Initial specification
- Base blockchain selected over Polygon
- Tokenomics defined
- Use cases documented
- Technical architecture planned
