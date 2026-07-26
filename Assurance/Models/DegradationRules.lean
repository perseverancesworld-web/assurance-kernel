import Mathlib.Data.Finset.Basic
import Assurance.Crypto.Digest

open Assurance.Crypto

variable {Digest : Type} [CryptographicDigest Digest]

def encodeNatBE (n : Nat) : ByteArray :=
  ByteArray.mk #[
    UInt8.ofNat ((n >>> 56) &&& 0xff),
    UInt8.ofNat ((n >>> 48) &&& 0xff),
    UInt8.ofNat ((n >>> 40) &&& 0xff),
    UInt8.ofNat ((n >>> 32) &&& 0xff),
    UInt8.ofNat ((n >>> 24) &&& 0xff),
    UInt8.ofNat ((n >>> 16) &&& 0xff),
    UInt8.ofNat ((n >>>  8) &&& 0xff),
    UInt8.ofNat ( n         &&& 0xff)
  ]

inductive AssuranceState
  | failed | degraded | challenged | active
deriving DecidableEq, Repr

inductive RecoverableState
  | degraded | challenged | active
deriving DecidableEq, Repr

def recoverableToAssurance : RecoverableState → AssuranceState
  | .degraded   => .degraded
  | .challenged => .challenged
  | .active     => .active

def recoveryRank : AssuranceState → Nat
  | .failed     => 0
  | .degraded   => 1
  | .challenged => 2
  | .active     => 3

inductive AuditorStatus
  | active | expired | revoked
deriving DecidableEq, Repr

structure AuditorIdentity where
  id : Nat
  status : AuditorStatus
  credentialExpiry : Nat

structure SystemState (Digest : Type) [CryptographicDigest Digest] where
  assurance : AssuranceState
  authority : Fin 10001
  currentTime : Nat
  meshId : String
  evidenceScore : Nat
  continuityScore : Nat

def serializeSystemState (s : SystemState Digest) : ByteArray :=
  encodeNatBE s.authority.val ++
  encodeNatBE s.currentTime ++
  encodeNatBE s.evidenceScore ++
  encodeNatBE s.continuityScore

structure KernelInvariant (s : SystemState Digest) : Prop where
  authoritySafe : s.authority.val ≤ 10000
  failedCannotExpand : s.assurance = AssuranceState.failed → s.authority.val = 0

structure CertifiedState (Digest : Type) [CryptographicDigest Digest] where
  state : SystemState Digest
  invariant : KernelInvariant state

theorem authority_bounded (s : SystemState Digest) (h : KernelInvariant s) :
    s.authority.val ≤ 10000 :=
  h.authoritySafe

theorem failed_cannot_expand (s : SystemState Digest) (h : KernelInvariant s)
    (hfail : s.assurance = AssuranceState.failed) :
    s.authority.val = 0 :=
  h.failedCannotExpand hfail
