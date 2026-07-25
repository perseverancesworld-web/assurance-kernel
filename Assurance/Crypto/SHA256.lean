/-
  SHA-256 production adapter (v25.8)

  This module is the cryptographic boundary for SHA-256.
  The kernel depends only on CryptographicDigest and never imports this file.

  Status: Interface-complete stub.
  A full pure-Lean SHA-256 (or FFI to a verified implementation) can be
  dropped in without touching any transition algebra, proofs, or tests.

  Requirements for a complete implementation:
  - Deterministic 32-byte output
  - Matches NIST test vectors
  - Pure or verified-FFI
  - Satisfies CryptographicDigest
-/

import Assurance.Crypto.Digest
import Mathlib.Data.ByteArray

namespace Assurance.Crypto

/-- Placeholder SHA-256 digest type (32 bytes). -/
def SHA256Digest := ByteArray

namespace SHA256

/-- Zero digest. -/
def zero : SHA256Digest := ByteArray.mk (List.replicate 32 0)

def toBytes (d : SHA256Digest) : ByteArray := d

/--
  Placeholder hash.
  Replace the body with a real pure-Lean SHA-256 or a verified FFI call.
  Until then this remains a deterministic but non-cryptographic stand-in
  so the module type-checks and the abstraction boundary is exercised.
-/
def hashBytes (ba : ByteArray) : SHA256Digest :=
  -- Temporary: reuse the same deterministic mixer as TestDigest
  -- so the adapter is immediately usable for interface testing.
  Id.run do
    let mut h : UInt64 := 0x6a09e667f3bcc908  -- SHA-256 inspired IV fragment
    for b in ba do
      h := (h * 0x100000001b3) ^^^ b.toUInt64
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
      x := x * 0x9e3779b97f4a7c15 + 1
    ByteArray.mk out

instance : CryptographicDigest SHA256Digest where
  eq_dec := inferInstance
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

/-- Known-answer test vectors can be added here once a real SHA-256 is present. -/
def selfTest : IO Unit := do
  IO.println "SHA256 adapter: interface-complete (placeholder hash)."
  IO.println "Replace hashBytes with a verified implementation for production use."

end SHA256

end Assurance.Crypto
