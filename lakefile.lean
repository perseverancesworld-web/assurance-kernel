import Lake
open Lake DSL

package «assurance-kernel» where
  -- add package configuration options here

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

@[default_target]
lean_lib AssuranceKernel where
  roots := #[`AssuranceKernel]

lean_lib Assurance where
  roots := #[
    `Assurance.Models.DegradationRules,
    `Assurance.Crypto.Digest,
    `Assurance.Ledger.Certified,
    `Assurance.Proofs.ReceiptChain,
    `Assurance.Execution.Transition,
    `Assurance.Tests.Regression
  ]
