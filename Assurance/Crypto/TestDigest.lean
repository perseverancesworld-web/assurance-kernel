import Assurance.Crypto.Digest

namespace Assurance.Crypto

/-- Reducible alias so Nat instances (OfNat, HMod, …) apply. -/
abbrev TestDigest := Nat

namespace TestDigest

def zero : TestDigest := (0 : Nat)

def toBytes (d : TestDigest) : ByteArray :=
  let n : Nat := d
  ByteArray.mk #[
    UInt8.ofNat (n % 256),
    UInt8.ofNat ((n / 256) % 256),
    UInt8.ofNat ((n / 65536) % 256),
    UInt8.ofNat ((n / 16777216) % 256)
  ]

def hashBytes (ba : ByteArray) : TestDigest :=
  let rec go (i : Nat) (acc : Nat) : Nat :=
    if hlt : i < ba.size then
      let b := (ba.get ⟨i, hlt⟩).toNat
      go (i + 1) ((acc * 31 + b) % 1000000007)
    else
      acc
  go 0 1

instance : CryptographicDigest TestDigest where
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

end TestDigest

end Assurance.Crypto
