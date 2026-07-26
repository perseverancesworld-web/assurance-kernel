namespace Assurance.Crypto

/-- Digest interface. DecidableEq is a parameter (not a field) so
    instances synthesize cleanly for Nat-backed test digests. -/
class CryptographicDigest (Digest : Type) [DecidableEq Digest] where
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
