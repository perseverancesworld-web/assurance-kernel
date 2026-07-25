/-
  Pure-Lean deterministic test digest.
  Zero external dependencies. Suitable for CI and formal completeness.
  Production digests (SHA-256, BLAKE3) will live in separate adapters.
-/

import Assurance.Crypto.Digest
import Mathlib.Data.ByteArray

namespace Assurance.Crypto

/-- Simple deterministic 32-byte digest represented as ByteArray. -/
def TestDigest := ByteArray

namespace TestDigest

/-- Trivial zero digest. -/
def zero : TestDigest := ByteArray.mk (List.replicate 32 0)

/-- Identity projection (already bytes). -/
def toBytes (d : TestDigest) : ByteArray := d

/-- Deterministic pure-Lean hash.
    Multiplicative rolling hash reduced into 32 bytes.
    Not cryptographically secure — intended only for testing and CI. -/
def hashBytes (ba : ByteArray) : TestDigest :=
  Id.run do
    let mut h : UInt64 := 0xcbf29ce484222325  -- FNV offset basis
    for b in ba do
      h := (h * 0x100000001b3) ^^^ b.toUInt64
    -- Expand the 64-bit state into a deterministic 32-byte array
    let mut out : Array UInt8 := #[]
    let mut x := h
    for _ in [:4] do
      out := out.push (UInt8.ofNat (x.toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 8).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 16).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 24).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 32).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 40).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 48).toNat &&& 0xff))
      out := out.push (UInt8.ofNat ((x >>> 56).toNat &&& 0xff))
      x := x * 0x9e3779b97f4a7c15 + 1  -- further mixing
    ByteArray.mk out

instance : CryptographicDigest TestDigest where
  eq_dec := inferInstance
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

end TestDigest

end Assurance.Crypto
