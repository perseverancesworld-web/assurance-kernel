import Lake
open Lake DSL

package «assurance-kernel» where

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

@[default_target]
lean_lib Assurance where
  -- Minimal core for CI green. Expand after foundation builds.
  globs := #[.submodules `Assurance.Crypto, .submodules `Assurance.Models, .submodules `Assurance.Trust]
