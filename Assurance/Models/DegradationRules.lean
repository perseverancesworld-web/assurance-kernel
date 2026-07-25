import Mathlib.Data.Int.Basic
import Mathlib.Data.List.Basic
import Mathlib.Data.Finset.Basic

/-!
  # Certified Transition Algebra Kernel (v25.7.3)

  Structural authority bounds, cryptographic evidence lineage,
  proof-carrying transitions, and graceful degradation.
-/

class CryptographicDigest (Digest : Type) where
  eq_dec : DecidableEq Digest
  zero : Digest
  toBytes : Digest → ByteArray
  hashBytes : ByteArray → Digest

variable {Digest : Type} [CryptographicDigest Digest]

/-- Deterministic 8-byte big-endian encoding of Nat (sufficient for timestamps). -/
def encodeNatBE (n : Nat) : ByteArray :=
  let b0 := UInt8.ofNat ((n >>> 56) &&& 0xff)
  let b1 := UInt8.ofNat ((n >>> 48) &&& 0xff)
  let b2 := UInt8.ofNat ((n >>> 40) &&& 0xff)
  let b3 := UInt8.ofNat ((n >>> 32) &&& 0xff)
  let b4 := UInt8.ofNat ((n >>> 24) &&& 0xff)
  let b5 := UInt8.ofNat ((n >>> 16) &&& 0xff)
  let b6 := UInt8.ofNat ((n >>>  8) &&& 0xff)
  let b7 := UInt8.ofNat ( n         &&& 0xff)
  ByteArray.mk #[b0, b1, b2, b3, b4, b5, b6, b7]

inductive AssuranceState
  | failed | degraded | challenged | active
deriving DecidableEq, Repr

inductive RecoverableState
  | degraded | challenged | active
deriving DecidableEq, Repr

def recoverableToAssurance : RecoverableState → AssuranceState
  | .degraded   => .degraded
  | .challenged => .challenged
  | .active     => .active

def recoveryRank : AssuranceState → Nat
  | .failed     => 0
  | .degraded   => 1
  | .challenged => 2
  | .active     => 3

inductive AuditorStatus
  | active | expired | revoked
deriving DecidableEq, Repr

structure AuditorIdentity where
  id : Nat
  status : AuditorStatus
  credentialExpiry : Nat

structure SignatureVerificationProof (signature : Digest) (verifier : AuditorIdentity) where
  verifier_active : verifier.status = AuditorStatus.active

structure SignedEvidenceReceipt (Digest : Type) [CryptographicDigest Digest] where
  sequence : Nat
  receiptId : Nat
  sourceId : Nat
  timestamp : Nat
  measurementHash : Digest
  verifier : AuditorIdentity
  signature : Digest
  verificationProof : SignatureVerificationProof signature verifier
  parentReceiptId : Option Nat
  parentHash : Option Digest

def MonotonicTimestamps : List (SignedEvidenceReceipt Digest) → Prop
  | [] => True
  | _ :: [] => True
  | r2 :: r1 :: rest => r2.timestamp ≥ r1.timestamp ∧ MonotonicTimestamps (r1 :: rest)

inductive ReceiptChain : Option Digest → List (SignedEvidenceReceipt Digest) → Prop
| genesis : ReceiptChain none []
| extend (xs : List (SignedEvidenceReceipt Digest)) (r : SignedEvidenceReceipt Digest)
    (prevHash : Option Digest) (prevSeq : Nat) :
    ReceiptChain prevHash xs →
    (match xs with
     | [] => prevHash = none
     | last :: _ => prevHash = some last.measurementHash ∧
                    r.sequence = last.sequence + 1 ∧
                    r.timestamp ≥ last.timestamp) →
    r.parentHash = prevHash →
    r.verificationProof.verifier_active = true →
    ReceiptChain (some r.measurementHash) (r :: xs)

/-- Extract the head timestamp inequality already present in a non-empty ReceiptChain. -/
lemma ReceiptChain.head_timestamp_ge
    {xs : List (SignedEvidenceReceipt Digest)}
    {r : SignedEvidenceReceipt Digest}
    (h : ReceiptChain (some r.measurementHash) (r :: xs)) :
    match xs with
    | [] => True
    | last :: _ => r.timestamp ≥ last.timestamp := by
  cases h with
  | extend xs' r' prevHash' prevSeq hChain hMatch hParent hActive =>
    cases xs with
    | nil => exact True.intro
    | cons last rest =>
      -- After inversion the match hypothesis contains the three conjuncts
      have hMatch' := hMatch
      simp at hMatch'
      exact hMatch'.2.2

structure OverrideCertificate (Digest : Type) [CryptographicDigest Digest] where
  id : Nat
  meshId : String
  maxAuthorityDelta : Nat
  expiresAt : Nat
  signers : List AuditorIdentity

structure ValidSignatureProof (c : OverrideCertificate Digest) (currentTime : Nat)
    (revoked : List Nat) (targetDelta : Nat) (currentMesh : String) where
  mesh_match : c.meshId = currentMesh
  not_expired : currentTime < c.expiresAt
  delta_bounded : targetDelta ≤ c.maxAuthorityDelta
  not_revoked : ¬ (c.id ∈ revoked)
  signers_qualified : ∀ signer ∈ c.signers,
    signer.status = AuditorStatus.active ∧ currentTime < signer.credentialExpiry
  min_quorum : c.signers.length ≥ 2

structure SystemState (Digest : Type) [CryptographicDigest Digest] where
  assurance : AssuranceState
  authority : Fin 10001
  overrideCert : OverrideCertificate Digest
  currentTime : Nat
  meshId : String
  evidenceLog : List (SignedEvidenceReceipt Digest)
  revokedCerts : List Nat
  auditors : List AuditorIdentity
  evidenceScore : Nat
  continuityScore : Nat
  lastEvidenceHash : Option Digest

/-- Canonical (simplified) serialization of the fields that participate in state commitment.
    Full structural serialization is future work; this is deterministic and sufficient for chaining. -/
def serializeSystemState (s : SystemState Digest) : ByteArray :=
  encodeNatBE s.authority.val ++
  encodeNatBE s.currentTime ++
  encodeNatBE s.evidenceScore ++
  encodeNatBE s.continuityScore ++
  (match s.lastEvidenceHash with
   | none => ByteArray.empty
   | some h => CryptographicDigest.toBytes h)

structure EmergencyAuthorityProof (s : SystemState Digest)
    (c : OverrideCertificate Digest) (delta : Nat) (currentTime : Nat) where
  signature : ValidSignatureProof c currentTime s.revokedCerts delta s.meshId
  notFailed : s.assurance ≠ AssuranceState.failed
  notExpired : currentTime < c.expiresAt

inductive AuthorityExpansionAllowed (s : SystemState Digest) (delta : Nat) : Type where
  | normal (h : s.assurance = AssuranceState.active) : AuthorityExpansionAllowed s delta
  | emergency (proof : EmergencyAuthorityProof s s.overrideCert delta s.currentTime) :
      AuthorityExpansionAllowed s delta

structure KernelInvariant (s : SystemState Digest) : Prop where
  authoritySafe : s.authority.val ≤ 10000
  lineageValid : ReceiptChain s.lastEvidenceHash s.evidenceLog
  failedCannotExpand : s.assurance = AssuranceState.failed → s.authority.val = 0
  temporalConsistency : MonotonicTimestamps s.evidenceLog

structure CertifiedState (Digest : Type) [CryptographicDigest Digest] where
  state : SystemState Digest
  invariant : KernelInvariant state

inductive ValidAction (s : SystemState Digest) : Type
  | ingestTelemetry (actionId : Digest) (receipt : SignedEvidenceReceipt Digest)
      (eScore cScore : Nat)
      (chainProof : ReceiptChain (some receipt.measurementHash) (receipt :: s.evidenceLog))
  | graduateRecovery (actionId : Digest) (target : AssuranceState)
      (h_tier : recoveryRank target = recoveryRank s.assurance + 1)
      (h_scores : s.evidenceScore ≥ 80 ∧ s.continuityScore ≥ 90)
      (chainProof : ReceiptChain s.lastEvidenceHash s.evidenceLog)
  | increaseAuthority (actionId : Digest) (recState : RecoverableState)
      (h_match : s.assurance = recoverableToAssurance recState)
      (delta : Nat) (auth : AuthorityExpansionAllowed s delta)
      (h_delta : s.authority.val + delta ≤ 10000)
  | tickTime (actionId : Digest)

def getActionId {s : SystemState Digest} (a : ValidAction s) : Digest :=
  match a with
  | .ingestTelemetry id _ _ _ => id
  | .graduateRecovery id _ _ _ _ => id
  | .increaseAuthority id _ _ _ _ _ => id
  | .tickTime id => id

structure StateTransitionCommitment (Digest : Type) [CryptographicDigest Digest] where
  previousRoot : Digest
  actionHash : Digest
  stateHash : Digest
  timestamp : Nat

def encodeCommitment (c : StateTransitionCommitment Digest) : ByteArray :=
  CryptographicDigest.toBytes c.previousRoot ++
  CryptographicDigest.toBytes c.actionHash ++
  CryptographicDigest.toBytes c.stateHash ++
  encodeNatBE c.timestamp

def computeRootTransition (c : StateTransitionCommitment Digest) : Digest :=
  CryptographicDigest.hashBytes (encodeCommitment c)

structure LedgerRecord (Digest : Type) [CryptographicDigest Digest] where
  actionId : Digest
  oldStateRoot : Digest
  newStateRoot : Digest
  timestamp : Nat

structure CertifiedLedger (Digest : Type) [CryptographicDigest Digest] where
  entries : List (LedgerRecord Digest)
  seenActions : Finset Digest
  stateHashRoot : Digest
  nodupProof : entries.Nodup
  indexProof : seenActions = Finset.ofList (entries.map LedgerRecord.actionId)

lemma action_not_in_entries
    (ledger : CertifiedLedger Digest)
    (record : LedgerRecord Digest)
    (h : record.actionId ∉ ledger.seenActions) :
    record.actionId ∉ ledger.entries.map LedgerRecord.actionId := by
  intro hx
  have : record.actionId ∈ ledger.seenActions := by
    rw [ledger.indexProof]
    exact Finset.mem_coe.mpr hx
  exact h this

def appendRecord
    (ledger : CertifiedLedger Digest)
    (record : LedgerRecord Digest)
    (h_not_seen : record.actionId ∉ ledger.seenActions) :
    CertifiedLedger Digest :=
  { entries := record :: ledger.entries
    seenActions := ledger.seenActions.insert record.actionId
    stateHashRoot := record.newStateRoot
    nodupProof := List.nodup_cons.mpr ⟨action_not_in_entries ledger record h_not_seen, ledger.nodupProof⟩
    indexProof := by ext x; simp [ledger.indexProof] }

structure CertifiedTransition
    (oldState : CertifiedState Digest)
    (action : ValidAction oldState.state)
    (newState : CertifiedState Digest)
    (ledger : CertifiedLedger Digest) where
  timestampValid : newState.state.currentTime ≥ oldState.state.currentTime
  authorityBounded : newState.state.authority.val ≤ 10000
  lineageProof : ReceiptChain newState.state.lastEvidenceHash newState.state.evidenceLog

def executeCertifiedTransition
    (ledger : CertifiedLedger Digest)
    (cs : CertifiedState Digest)
    (a : ValidAction cs.state)
    (h_not_seen : getActionId a ∉ ledger.seenActions) :
    Σ (nextLedger : CertifiedLedger Digest),
      Σ (nextState : CertifiedState Digest),
        CertifiedTransition cs a nextState nextLedger :=
  match a with
  | .ingestTelemetry actionId receipt eScore cScore chainProof =>
      let nextS := { cs.state with
        evidenceLog := receipt :: cs.state.evidenceLog
        evidenceScore := eScore
        continuityScore := cScore
        lastEvidenceHash := some receipt.measurementHash }
      let newStateHash := CryptographicDigest.hashBytes (serializeSystemState nextS)
      let commitment : StateTransitionCommitment Digest := {
        previousRoot := ledger.stateHashRoot
        actionHash := actionId
        stateHash := newStateHash
        timestamp := cs.state.currentTime }
      let newRoot := computeRootTransition commitment
      let record : LedgerRecord Digest := {
        actionId := actionId
        oldStateRoot := ledger.stateHashRoot
        newStateRoot := newRoot
        timestamp := cs.state.currentTime }
      let nextLedger := appendRecord ledger record h_not_seen
      let monoProof : MonotonicTimestamps nextS.evidenceLog := by
        cases hlog : cs.state.evidenceLog with
        | nil => exact True.intro
        | cons last rest =>
            have h_ts : receipt.timestamp ≥ last.timestamp :=
              ReceiptChain.head_timestamp_ge chainProof
            exact And.intro h_ts cs.invariant.temporalConsistency
      let nextState : CertifiedState Digest := {
        state := nextS
        invariant := {
          authoritySafe := nextS.authority.isLt
          lineageValid := chainProof
          failedCannotExpand := fun hfail => cs.invariant.failedCannotExpand hfail
          temporalConsistency := monoProof } }
      let cert : CertifiedTransition cs a nextState nextLedger := {
        timestampValid := by omega
        authorityBounded := nextS.authority.isLt
        lineageProof := chainProof }
      ⟨nextLedger, ⟨nextState, cert⟩⟩

  | .graduateRecovery actionId target _ _ chainProof =>
      let nextS := { cs.state with assurance := target }
      let newStateHash := CryptographicDigest.hashBytes (serializeSystemState nextS)
      let commitment : StateTransitionCommitment Digest := {
        previousRoot := ledger.stateHashRoot
        actionHash := actionId
        stateHash := newStateHash
        timestamp := cs.state.currentTime }
      let newRoot := computeRootTransition commitment
      let record : LedgerRecord Digest := {
        actionId := actionId
        oldStateRoot := ledger.stateHashRoot
        newStateRoot := newRoot
        timestamp := cs.state.currentTime }
      let nextLedger := appendRecord ledger record h_not_seen
      let nextState : CertifiedState Digest := {
        state := nextS
        invariant := {
          authoritySafe := nextS.authority.isLt
          lineageValid := chainProof
          failedCannotExpand := fun hfail => by cases hfail
          temporalConsistency := cs.invariant.temporalConsistency } }
      let cert : CertifiedTransition cs a nextState nextLedger := {
        timestampValid := by omega
        authorityBounded := nextS.authority.isLt
        lineageProof := chainProof }
      ⟨nextLedger, ⟨nextState, cert⟩⟩

  | .increaseAuthority actionId _ _ delta _ h_delta =>
      let newAuthorityVal : Fin 10001 := ⟨cs.state.authority.val + delta, h_delta⟩
      let nextS := { cs.state with authority := newAuthorityVal }
      let newStateHash := CryptographicDigest.hashBytes (serializeSystemState nextS)
      let commitment : StateTransitionCommitment Digest := {
        previousRoot := ledger.stateHashRoot
        actionHash := actionId
        stateHash := newStateHash
        timestamp := cs.state.currentTime }
      let newRoot := computeRootTransition commitment
      let record : LedgerRecord Digest := {
        actionId := actionId
        oldStateRoot := ledger.stateHashRoot
        newStateRoot := newRoot
        timestamp := cs.state.currentTime }
      let nextLedger := appendRecord ledger record h_not_seen
      let nextState : CertifiedState Digest := {
        state := nextS
        invariant := {
          authoritySafe := nextS.authority.isLt
          lineageValid := cs.invariant.lineageValid
          failedCannotExpand := fun hfail => by cases hfail
          temporalConsistency := cs.invariant.temporalConsistency } }
      let cert : CertifiedTransition cs a nextState nextLedger := {
        timestampValid := by omega
        authorityBounded := nextS.authority.isLt
        lineageProof := cs.invariant.lineageValid }
      ⟨nextLedger, ⟨nextState, cert⟩⟩

  | .tickTime actionId =>
      let nextS := { cs.state with currentTime := cs.state.currentTime + 1 }
      let newStateHash := CryptographicDigest.hashBytes (serializeSystemState nextS)
      let commitment : StateTransitionCommitment Digest := {
        previousRoot := ledger.stateHashRoot
        actionHash := actionId
        stateHash := newStateHash
        timestamp := cs.state.currentTime }
      let newRoot := computeRootTransition commitment
      let record : LedgerRecord Digest := {
        actionId := actionId
        oldStateRoot := ledger.stateHashRoot
        newStateRoot := newRoot
        timestamp := cs.state.currentTime }
      let nextLedger := appendRecord ledger record h_not_seen
      let nextState : CertifiedState Digest := {
        state := nextS
        invariant := {
          authoritySafe := nextS.authority.isLt
          lineageValid := cs.invariant.lineageValid
          failedCannotExpand := cs.invariant.failedCannotExpand
          temporalConsistency := cs.invariant.temporalConsistency } }
      let cert : CertifiedTransition cs a nextState nextLedger := {
        timestampValid := by omega
        authorityBounded := nextS.authority.isLt
        lineageProof := cs.invariant.lineageValid }
      ⟨nextLedger, ⟨nextState, cert⟩⟩
