# Assurance Kernel

Formally verified Lean 4 foundation for **QUANTAURA-Core**.

## Status (v26.2.1)

| Guarantee | Status |
|-----------|--------|
| Certified state model | Complete |
| Transition algebra | Complete |
| Trust Controller + safety | Complete |
| Signed certificates + immutability | Complete |
| Event identity + deduplication | Complete |
| betterHead irreflexive | Proved |
| betterHead transitive | Proved (case analysis) |
| selectHead exists | Proved |
| selectHead respects same selectable set | Proved |
| deduplicate idempotent | Skeleton + invariant (1 remaining sorry) |
| Consensus Determinism | Stated on top of the above |
| Concrete physics | Queued |
| Lean ↔ Python refinement | Queued |

## Priority order (locked)

1. ✅ Close library lemmas (this release)
2. Lean ↔ Python refinement chain
3. Concrete Hermitian / spectral / coherence layer

## Building

```bash
lake build
```

## License

To be determined by the author.
