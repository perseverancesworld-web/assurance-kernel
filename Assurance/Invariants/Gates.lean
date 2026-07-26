namespace Assurance.Invariants

inductive GateResult where
  | pass
  | fail (reason : String)
deriving DecidableEq, Repr

def GateResult.isOk : GateResult → Bool
  | .pass => true
  | .fail _ => false

def checkProvenance {Digest : Type} [DecidableEq Digest]
    (expected supplied : Option Digest) : GateResult :=
  if expected = supplied then .pass
  else .fail "Provenance: parent hash mismatch"

structure InvariantVerdict where
  provenance : GateResult
  hermiticity : GateResult
  spectral : GateResult
  coherence : GateResult
deriving Repr

def InvariantVerdict.allPass (v : InvariantVerdict) : Bool :=
  v.provenance.isOk && v.hermiticity.isOk && v.spectral.isOk && v.coherence.isOk

end Assurance.Invariants
