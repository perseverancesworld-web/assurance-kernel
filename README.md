# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7.3).

## Repository Layout

```
assurance-kernel/
├── lakefile.lean
├── lean-toolchain
├── .github/workflows/lean.yml
├── Assurance/
│   ├── Models/          # Core state, actions, invariants, transition algebra
│   ├── Crypto/          # Digest interface & concrete instances
│   ├── Ledger/          # Certified ledger & uniqueness
│   ├── Proofs/          # ReceiptChain inversion & transport lemmas
│   ├── Execution/       # Higher-level transition composition
│   └── Tests/           # Regression theorems
└── README.md
```

## Status (v25.7.3)

| Area                      | Status                          |
|---------------------------|---------------------------------|
| Type safety               | Excellent                       |
| Transition algebra        | Excellent                       |
| Ledger consistency        | Excellent                       |
| Authority model           | Excellent                       |
| Receipt lineage           | `head_timestamp_ge` present     |
| State commitment          | Canonical serializer + stateHash |
| Cryptographic commitments | Deterministic chaining          |
| Concrete digest           | Still abstract (next)           |
| Regression suite          | Core theorems added             |
| Formal completeness       | ~97%                            |

## Building & CI

```bash
lake build
```

CI runs on every push to `main` and fails if any `sorry` remains in the sources.

## Roadmap remaining

1. ✅ Repository bootstrap + modular layout
2. ✅ `ReceiptChain.head_timestamp_ge` + genuine stateHash
3. ✅ Initial regression theorems
4. Concrete `CryptographicDigest` instance (SHA-256 / Blake3 or test digest)
5. Full executable regression suite + stronger inversion lemmas

## License

To be determined by the author.
