/-
  Cryptographic digest typeclass (abstract boundary).
  Concrete instances live in sibling modules.
-/

import Mathlib.Data.ByteArray

namespace Assurance.Crypto

/-- Abstract cryptographic digest interface used by the kernel. -/
class CryptographicDigest (Digest : Type) where
  eq_dec : DecidableEq Digest
  zero : Digest
  toBytes : Digest → ByteArray
  hashBytes : ByteArray → Digest

end Assurance.Crypto
