import Assurance.Crypto.Digest

namespace Assurance.Crypto

def TestDigest := ByteArray

namespace TestDigest

def zeroVal : TestDigest := ByteArray.empty

def toBytesVal (d : TestDigest) : ByteArray := d

def hashBytesVal (ba : ByteArray) : TestDigest := ba

instance : CryptographicDigest TestDigest where
  eq_dec := inferInstance
  zero := zeroVal
  toBytes := toBytesVal
  hashBytes := hashBytesVal

end TestDigest

end Assurance.Crypto
