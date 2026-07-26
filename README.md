# Assurance Kernel

Formally verified Lean 4 foundation for **QUANTAURA-Core**.

## Status (v26.2)

| Guarantee | Status |
|-----------|--------|
| Certified state model | Complete |
| Transition algebra | Complete |
| Trust Controller + safety | Complete |
| Invariant gates | Formalized |
| Signed scoring certificates + immutability | Complete |
| Logical vs observed time | Separated |
| Event identity + deduplication | Complete |
| Unique canonical head | Theorem |
| Consensus Determinism (permutation + dedup) | Stated |
| Concrete physics / Hermitian model | Future |
| Lean ↔ Python refinement | Future |

## Capstone Property

```
Resolve(E) = Resolve(π(E))
Resolve(E) = Resolve(Deduplicate(E))
```

Given identical authenticated events, identical scoring policy, identical verifier and identical serialization, every compliant replica computes the identical canonical head.

## Building

```bash
lake build
```

## License

To be determined by the author.
