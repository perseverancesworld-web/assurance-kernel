import Assurance.Crypto.Digest

open Assurance.Crypto

namespace Assurance.Models

inductive AssuranceState where
  | failed | degraded | challenged | active
deriving DecidableEq, Repr

inductive RecoverableState where
  | degraded | challenged | active
deriving DecidableEq, Repr

def recoverableToAssurance : RecoverableState → AssuranceState
  | .degraded => .degraded
  | .challenged => .challenged
  | .active => .active

def recoveryRank : AssuranceState → Nat
  | .failed => 0
  | .degraded => 1
  | .challenged => 2
  | .active => 3

structure SystemState (Digest : Type) [DecidableEq Digest] [CryptographicDigest Digest] where
  assurance : AssuranceState
  authority : Nat          -- bounded by invariant, not Fin (avoids Mathlib)
  currentTime : Nat
  meshId : String
  evidenceScore : Nat
  continuityScore : Nat

def authorityBound : Nat := 10000

structure KernelInvariant (Digest : Type) [DecidableEq Digest] [CryptographicDigest Digest]
    (s : SystemState Digest) : Prop where
  authoritySafe : s.authority ≤ authorityBound
  failedCannotExpand : s.assurance = .failed → s.authority = 0

structure CertifiedState (Digest : Type) [DecidableEq Digest] [CryptographicDigest Digest] where
  state : SystemState Digest
  invariant : KernelInvariant Digest state

theorem authority_bounded {Digest : Type} [DecidableEq Digest] [CryptographicDigest Digest]
    (s : SystemState Digest) (h : KernelInvariant Digest s) :
    s.authority ≤ authorityBound :=
  h.authoritySafe

theorem failed_lock {Digest : Type} [DecidableEq Digest] [CryptographicDigest Digest]
    (s : SystemState Digest) (h : KernelInvariant Digest s)
    (hf : s.assurance = .failed) :
    s.authority = 0 :=
  h.failedCannotExpand hf

end Assurance.Models
