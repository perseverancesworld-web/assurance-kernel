namespace Assurance.Event

structure Event (Digest : Type) [DecidableEq Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  proposedStateHash : Digest

def memId {Digest : Type} [DecidableEq Digest]
    (seen : List Digest) (id : Digest) : Bool :=
  match seen with
  | [] => false
  | x :: xs => decide (x = id) || memId xs id

def isDuplicate {Digest : Type} [DecidableEq Digest]
    (seen : List Digest) (e : Event Digest) : Bool :=
  memId seen e.eventId

def markProcessed {Digest : Type} [DecidableEq Digest]
    (seen : List Digest) (e : Event Digest) : List Digest :=
  e.eventId :: seen

def deduplicate {Digest : Type} [DecidableEq Digest]
    (events : List (Event Digest)) : List (Event Digest) :=
  go events []
where
  go : List (Event Digest) → List Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if memId seen e.eventId then go rest seen
      else e :: go rest (e.eventId :: seen)

end Assurance.Event
