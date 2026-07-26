# Assurance Kernel

Formally verified Lean 4 foundation for QUANTAURA-Core.

## CI strategy (temporary)

Lake currently builds only the **minimal core**:

- `Assurance.Crypto` — digest interface + adapters
- `Assurance.Models` — state + authority bounds
- `Assurance.Trust` — trust controller + safety

DAG / Protocol / full transition algebra modules remain in the tree but are excluded from the default Lake root until the foundation is green. They will be re-enabled incrementally.

## Building

```bash
lake build
```

## License

To be determined by the author.
