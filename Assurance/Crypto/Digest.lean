/-
  Single source of truth for the cryptographic digest interface.
-/

namespace Assurance.Crypto

class CryptographicDigest (Digest : Type) where
  eq_dec : DecidableEq Digest
  zero : Digest
  toBytes : Digest → ByteArray
  hashBytes : ByteArray → Digest

export CryptographicDigest (zero toBytes hashBytes)

/-- Deterministic lexicographic comparison of byte arrays (no LT instance required). -/
def bytesLt (a b : ByteArray) : Bool :=
  go 0
where
  go (i : Nat) : Bool :=
    if h : i < a.size then
      if h' : i < b.size then
        let x := a.get ⟨i, h⟩
        let y := b.get ⟨i, h'⟩
        if x < y then true
        else if y < x then false
        else go (i + 1)
      else false  -- a is longer prefix of equal bytes → a > b
    else
      i < b.size  -- a is proper prefix of b → a < b

end Assurance.Crypto
