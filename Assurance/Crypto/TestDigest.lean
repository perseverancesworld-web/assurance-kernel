import Assurance.Crypto.Digest

namespace Assurance.Crypto

def TestDigest := Nat

namespace TestDigest

def zero : TestDigest := 0

def toBytes (d : TestDigest) : ByteArray :=
  ByteArray.mk #[
    UInt8.ofNat (d % 256),
    UInt8.ofNat ((d / 256) % 256),
    UInt8.ofNat ((d / 65536) % 256),
    UInt8.ofNat ((d / 16777216) % 256)
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
