import Assurance.Crypto.Digest

namespace Assurance.Crypto

def Blake3Digest := ByteArray

namespace Blake3

def zero : Blake3Digest := ByteArray.mk (List.replicate 32 0)
def toBytes (d : Blake3Digest) : ByteArray := d

def hashBytes (ba : ByteArray) : Blake3Digest :=
  Id.run do
    let mut h : UInt64 := 0x6a09e667f2bdc948
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

instance : CryptographicDigest Blake3Digest where
  eq_dec := inferInstance
  zero := zero
  toBytes := toBytes
  hashBytes := hashBytes

end Blake3

end Assurance.Crypto
