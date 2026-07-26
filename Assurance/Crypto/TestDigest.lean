import Assurance.Crypto.Digest

namespace Assurance.Crypto

/-- Pure-Lean test digest: a natural number.
    Fully decidable; suitable for CI and formal development. -/
def TestDigest := Nat

namespace TestDigest

def zero : TestDigest := 0

/-- Encode Nat as little-endian bytes (minimal). -/
def toBytes (d : TestDigest) : ByteArray :=
  ByteArray.mk #[
    UInt8.ofNat (d &&& 0xff),
    UInt8.ofNat ((d >>> 8) &&& 0xff),
    UInt8.ofNat ((d >>> 16) &&& 0xff),
    UInt8.ofNat ((d >>> 24) &&& 0xff)
  ]

/-- Deterministic mix of input bytes into a Nat. -/
def hashBytes (ba : ByteArray) : TestDigest :=
  Id.run do
    let mut h : Nat := 0xcbf29ce484222325
    for b in ba do
      h := (h * 0x100000001b3) ^^^ b.toNat
    pure h

instance : CryptographicDigest TestDigest where
  eq_dec := inferInstance  -- Nat has DecidableEq
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

end TestDigest

end Assurance.Crypto
