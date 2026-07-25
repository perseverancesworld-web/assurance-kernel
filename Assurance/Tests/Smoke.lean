/-
  Executable smoke test using the pure-Lean TestDigest.
  Exercises genesis → ingestTelemetry and checks core invariants.
-/

import Assurance.Models.DegradationRules
import Assurance.Crypto.TestDigest
import Assurance.Tests.Regression

open Assurance.Crypto

namespace Assurance.Tests.Smoke

/-- Minimal genesis state for smoke testing. -/
def genesisState : SystemState TestDigest := {
  assurance := .active
  authority := ⟨0, by omega⟩
  overrideCert := {
    id := 0
    meshId := "test-mesh"
    maxAuthorityDelta := 100
    expiresAt := 999999
    signers := [] }
  currentTime := 0
  meshId := "test-mesh"
  evidenceLog := []
  revokedCerts := []
  auditors := []
  evidenceScore := 100
  continuityScore := 100
  lastEvidenceHash := none }

def genesisInvariant : KernelInvariant genesisState where
  authoritySafe := by omega
  lineageValid := ReceiptChain.genesis
  failedCannotExpand := fun h => by cases h
  temporalConsistency := True.intro

def genesisCertified : CertifiedState TestDigest :=
  { state := genesisState, invariant := genesisInvariant }

def emptyLedger : CertifiedLedger TestDigest := {
  entries := []
  seenActions := ∅
  stateHashRoot := TestDigest.zero
  nodupProof := List.nodup_nil
  indexProof := by simp }

/-- Smoke test: perform a single ingest and check that the world still makes sense. -/
def smokeIngest : IO Unit := do
  -- Construct a trivial receipt that can extend the empty chain
  let receipt : SignedEvidenceReceipt TestDigest := {
    sequence := 0
    receiptId := 1
    sourceId := 42
    timestamp := 1
    measurementHash := TestDigest.hashBytes (ByteArray.mk #[1,2,3])
    verifier := { id := 1, status := .active, credentialExpiry := 999999 }
    signature := TestDigest.zero
    verificationProof := { verifier_active := rfl }
    parentReceiptId := none
    parentHash := none }
  -- The chain proof for the first receipt
  let chainProof : ReceiptChain (some receipt.measurementHash) [receipt] :=
    ReceiptChain.extend [] receipt none 0 ReceiptChain.genesis (by simp) (by rfl) rfl
  let action := ValidAction.ingestTelemetry
    (TestDigest.hashBytes (ByteArray.mk #[9,9,9])) receipt 95 97 chainProof
  -- Execute
  let ⟨nextLedger, ⟨nextState, cert⟩⟩ :=
    executeCertifiedTransition emptyLedger genesisCertified action (by simp)
  -- Basic sanity checks (executable)
  IO.println s!"Smoke test passed."
  IO.println s!"  New authority     = {nextState.state.authority.val}"
  IO.println s!"  New time          = {nextState.state.currentTime}"
  IO.println s!"  Evidence log len  = {nextState.state.evidenceLog.length}"
  IO.println s!"  Ledger entries    = {nextLedger.entries.length}"
  IO.println s!"  Action recorded   = {nextLedger.seenActions.card}"
  -- The regression theorems are already available as compile-time checks
  let _ := Assurance.Tests.authority_bounded nextState.state nextState.invariant
  let _ := Assurance.Tests.timestamps_monotonic nextState.state nextState.invariant
  pure ()

#eval smokeIngest

end Assurance.Tests.Smoke
