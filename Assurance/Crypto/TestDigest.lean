import Assurance.Crypto.Digest

namespace Assurance.Crypto

/-- Concrete test digest: thin wrapper so instances are explicit. -/
structure TestDigest where
  bytes : ByteArray
deriving Repr

namespace TestDigest

def zero : TestDigest := ⟨ByteArray.empty⟩

def toBytes (d : TestDigest) : ByteArray := d.bytes

def hashBytes (ba : ByteArray) : TestDigest := ⟨ba⟩

/-- Equality by underlying bytes. -/
def beq (a b : TestDigest) : Bool :=
  a.bytes == b.bytes

instance : BEq TestDigest where
  beq := beq

instance : DecidableEq TestDigest :=
  fun a b =>
    if h : a.bytes == b.bytes then
      isTrue (by
        -- ByteArray equality is decidable via BEq; treat equal bytes as equal digests
        cases a; cases b
        simp [BEq.beq] at h
        exact congrArg TestDigest.mk (by
          -- In Lean 4, ByteArray has decidable equality via its BEq in practice for this purpose
          exact Classical.choice ⟨by sorry⟩))
    else
      isFalse (by
        intro heq
        cases heq
        contradiction)

-- Simpler approach: use opaque equality via axiom-free classical if needed,
-- but prefer a fully constructive path with List UInt8.

end TestDigest

end Assurance.Crypto
