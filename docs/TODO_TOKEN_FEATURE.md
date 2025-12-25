# TODO: $PRE Token Feature Implementation

## Status: DISABLED - Pending Legal Review

The $PRE token feature has been implemented but is currently **disabled** pending legal review of gambling/securities regulations.

## Legal Considerations Before Enabling

1. **Gambling Regulations**
   - Prediction rewards may be classified as gambling
   - Review laws in target jurisdictions (US state-by-state, EU, etc.)
   - Consider geo-blocking high-risk regions

2. **Securities Law (Howey Test)**
   - If tokens are tradeable and users expect profit, may be a security
   - Current design is earn-only (safer)
   - May need legal opinion if adding token sales or exchange listing

3. **Money Transmission**
   - If tokens can convert to fiat, licensing may be required
   - Consider keeping tokens non-transferable initially

4. **Recommended Actions**
   - Consult crypto/gaming attorney before enabling
   - Draft comprehensive Terms of Service
   - Consider "play for fun" mode without real value

---

## Implemented Features (Ready to Enable)

### Token Infrastructure
- **Blockchain**: Base (Coinbase L2)
- **Token**: ERC-20 $PRE token
- **Network**: Testnet (Base Sepolia) for development

### Files Implemented
```
lib/features/token/
├── domain/entities/token_entities.dart    # Core entities
├── data/
│   ├── services/
│   │   ├── base_blockchain_service.dart   # RPC interaction
│   │   └── token_service.dart             # Token operations
│   └── repositories/token_repository.dart # Local storage
├── presentation/
│   ├── bloc/token_cubit.dart              # State management
│   ├── widgets/
│   │   ├── wallet_connect_widget.dart     # Wallet connection UI
│   │   ├── token_balance_widget.dart      # Balance display
│   │   └── transaction_history_widget.dart # Transaction list
│   └── pages/token_wallet_page.dart       # Main wallet page
└── token.dart                              # Feature export

lib/config/token_config.dart               # Token configuration
docs/PRE_TOKEN_SPECIFICATION.md            # Full specification
```

### Token Rewards Configuration
| Action | Reward |
|--------|--------|
| Correct prediction (winner) | 10 PRE |
| Exact score prediction | 50 PRE |
| Daily check-in | 5 PRE |
| Referral | 100 PRE |
| Weekly leaderboard win | 500 PRE |
| Tournament bracket win | 5,000 PRE |

### Staking Tiers
| Tier | Min Stake | Bonus |
|------|-----------|-------|
| Fan | 0 | 1.0x |
| Super Fan | 1,000 PRE | 1.1x |
| VIP Fan | 10,000 PRE | 1.25x |
| Legend | 100,000 PRE | 1.5x |

---

## How to Re-Enable

### Step 1: Update injection_container.dart
```dart
// Uncomment in _registerWorldCupServices():
print('🔧 DI STEP 10: Token Services');
try {
  _registerTokenServices();
  print('✅ DI STEP 10: Token Services - SUCCESS');
} catch (e) {
  print('⚠️ DI STEP 10: Token Services - FAILED: $e');
}

// Also uncomment the import:
import 'features/token/token.dart';
```

### Step 2: Update main_navigation_screen.dart
In `_WorldCupFeatureWrapperState`:
```dart
// Add field:
late final TokenCubit _tokenCubit;

// In initState():
_tokenCubit = di.sl<TokenCubit>()..init();
_predictionsCubit.setTokenCubit(_tokenCubit);

// In dispose():
_tokenCubit.close();

// In build() providers list:
BlocProvider<TokenCubit>.value(value: _tokenCubit),
```

### Step 3: Update world_cup_home_screen.dart
Add wallet button to app bar actions (see git history for implementation).

### Step 4: Update predictions_cubit.dart
Uncomment token imports and reward logic (see git history).

---

## Future Enhancements

- [ ] Smart contract deployment on Base mainnet
- [ ] Wallet integration (Coinbase Wallet SDK)
- [ ] Token staking mechanism
- [ ] NFT moments for big predictions
- [ ] Leaderboard rewards system
- [ ] Referral tracking
- [ ] Exchange listing (requires legal clearance)

---

## Contact

For questions about the token implementation, review the code or contact the development team.

*Last Updated: December 2024*
