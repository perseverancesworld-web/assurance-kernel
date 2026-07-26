import Lake
open Lake DSL

package «assurance-kernel» where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

@[default_target]
lean_lib Assurance where
  roots := #[`Assurance]
