import Lake
open Lake DSL

package «assurance-kernel» where
  -- zero external deps for CI isolation

@[default_target]
lean_lib Assurance where
  globs := #[.submodules `Assurance.Crypto, .submodules `Assurance.Trust]
