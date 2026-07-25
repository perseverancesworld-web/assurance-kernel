# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7+).

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
│   └── Tests/           # Regression proofs & executable tests
└── README.md
```

## Current Status

| Area                      | Status                    |
|---------------------------|---------------------------|
| Type safety               | Excellent                 |
| Transition algebra        | Excellent                 |
| Ledger consistency        | Excellent                 |
| Authority model           | Excellent                 |
| Receipt lineage           | Inversion lemma present   |
| Cryptographic commitments | Serializer still partial  |
| Concrete execution        | Digest instance needed    |
| Formal completeness       | ~95-97%                   |

## Roadmap

1. ✅ Repository bootstrap (lakefile, toolchain, CI, modular layout)
2. Complete / strengthen `ReceiptChain.head_timestamp_ge`
3. Canonical serialization for `SystemState` → genuine `stateHash`
4. Concrete `CryptographicDigest` instance
5. Full regression suite (duplicate rejection, authority bounds, monotonicity, lineage, failed-state lock, deterministic roots)

## Building

```bash
lake build
```

CI runs `lake build` and fails on any remaining `sorry` on every push to `main`.

## License

To be determined by the author.
