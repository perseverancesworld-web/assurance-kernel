import Lake
open Lake DSL

package «assurance-kernel» where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

@[default_target]
lean_lib AssuranceKernel where
  roots := #[`Assurance]

lean_lib Assurance where
  roots := #[
    `Assurance.Models.DegradationRules,
    `Assurance.Crypto.Digest,
    `Assurance.Crypto.TestDigest,
    `Assurance.Crypto.SHA256,
    `Assurance.Crypto.Blake3,
    `Assurance.Ledger.Certified,
    `Assurance.Proofs.ReceiptChain,
    `Assurance.Execution.Transition,
    `Assurance.Trust.Controller,
    `Assurance.Invariants.Gates,
    `Assurance.DAG.Node,
    `Assurance.DAG.PermutationInvariance,
    `Assurance.Protocol.Stack,
    `Assurance.Tests.Regression,
    `Assurance.Tests.Smoke,
    `Assurance.Tests.Rejection
  ]
