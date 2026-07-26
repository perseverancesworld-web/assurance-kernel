import Assurance.Crypto.Digest
import Assurance.Trust.Controller

open Assurance.Crypto

namespace Assurance.DAG

inductive NodeStatus where
  | proposed | verified | accepted | superseded | quarantined | rejected
deriving DecidableEq, Repr

structure CertifiedNode (Digest : Type) where
  id : Digest
  parentId : Option Digest
  stateHash : Digest
  score : Nat
  status : NodeStatus
  trustAtPlacement : Assurance.Trust.TrustState
  logicalTime : Nat

def isSelectable {Digest : Type} (n : CertifiedNode Digest) : Bool :=
  match n.status with
  | .verified | .accepted => true
  | _ => false

def betterHead {Digest : Type} [CryptographicDigest Digest]
    (a b : CertifiedNode Digest) : Bool :=
  if a.score > b.score then true
  else if a.score < b.score then false
  else bytesLt (toBytes a.stateHash) (toBytes b.stateHash)

def selectHead {Digest : Type} [CryptographicDigest Digest]
    (candidates : List (CertifiedNode Digest)) : Option (CertifiedNode Digest) :=
  let selectable := candidates.filter isSelectable
  match selectable with
  | [] => none
  | hd :: tl => some (tl.foldl (fun best n => if betterHead n best then n else best) hd)

end Assurance.DAG
