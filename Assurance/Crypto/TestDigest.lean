import Assurance.Crypto.Digest

namespace Assurance.Crypto

def TestDigest := ByteArray

namespace TestDigest

def zero : TestDigest := ByteArray.mk (List.replicate 32 0)

def toBytes (d : TestDigest) : ByteArray := d

def hashBytes (ba : ByteArray) : TestDigest :=
  Id.run do
    let mut h : UInt64 := 0xcbf29ce484222325
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

instance : CryptographicDigest TestDigest where
  eq_dec := inferInstance
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

end TestDigest

end Assurance.Crypto
