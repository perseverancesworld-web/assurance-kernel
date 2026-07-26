/-
  First-class event identity and duplicate-delivery rejection.
-/

import Assurance.Models.DegradationRules

namespace Assurance.Event

structure Event (Digest : Type) [CryptographicDigest Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  payload : ByteArray
  parentHash : Option Digest
  proposedStateHash : Digest

def ProcessedSet (Digest : Type) [CryptographicDigest Digest] :=
  Finset Digest

def isDuplicate (processed : ProcessedSet Digest) (e : Event Digest) : Bool :=
  e.eventId ∈ processed

def markProcessed (processed : ProcessedSet Digest) (e : Event Digest) :
    ProcessedSet Digest :=
  processed.insert e.eventId

/-- Deduplicate preserving first-occurrence order. -/
def deduplicate (events : List (Event Digest)) : List (Event Digest) :=
  go events ∅
where
  go : List (Event Digest) → Finset Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if e.eventId ∈ seen then
        go rest seen
      else
        e :: go rest (seen.insert e.eventId)

/-- Helper: every event_id in the output of go appears in the seen set
    accumulated so far, and no duplicates are emitted. -/
theorem deduplicate.go_nodup
    (events : List (Event Digest)) (seen : Finset Digest) :
    (deduplicate.go events seen).Pairwise
      (fun a b => a.eventId ≠ b.eventId) := by
  induction events generalizing seen with
  | nil => simp [deduplicate.go]
  | cons e rest ih =>
      simp [deduplicate.go]
      split_ifs with h
      · exact ih seen
      · constructor
        · intro b hb
          -- b comes from go rest (seen.insert e.eventId)
          -- by induction those ids are distinct from each other;
          -- e.eventId is not in the remaining output because it was inserted
          sorry  -- requires a stronger inductive invariant
        · exact ih (seen.insert e.eventId)

/-- Deduplication is idempotent. -/
theorem deduplicate_idempotent (events : List (Event Digest)) :
    deduplicate (deduplicate events) = deduplicate events := by
  -- Because the output of deduplicate already contains unique event_ids,
  -- a second pass leaves it unchanged.
  induction events with
  | nil => simp [deduplicate, deduplicate.go]
  | cons e rest ih =>
      simp [deduplicate, deduplicate.go]
      -- Full discharge needs the nodup invariant above.
      sorry

end Assurance.Event
