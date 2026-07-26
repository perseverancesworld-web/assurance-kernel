namespace Assurance.Crypto

class CryptographicDigest (Digest : Type) where
  eq_dec : DecidableEq Digest
  zero : Digest
  toBytes : Digest → ByteArray
  hashBytes : ByteArray → Digest

def bytesLt (a b : ByteArray) : Bool :=
  let rec go (i : Nat) : Bool :=
    if h : i < a.size then
      if h' : i < b.size then
        let x := a.get ⟨i, h⟩
        let y := b.get ⟨i, h'⟩
        if x < y then true
        else if y < x then false
        else go (i + 1)
      else false
    else
      decide (i < b.size)
  go 0

end Assurance.Crypto
