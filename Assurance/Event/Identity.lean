namespace Assurance.Event

structure Event (Digest : Type) where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  proposedStateHash : Digest

/-- Membership test; caller supplies equality. -/
def memId {Digest : Type}
    (eq : Digest → Digest → Bool)
    (seen : List Digest) (id : Digest) : Bool :=
  match seen with
  | [] => false
  | x :: xs => eq x id || memId eq xs id

def isDuplicate {Digest : Type}
    (eq : Digest → Digest → Bool)
    (seen : List Digest) (e : Event Digest) : Bool :=
  memId eq seen e.eventId

def markProcessed {Digest : Type}
    (seen : List Digest) (e : Event Digest) : List Digest :=
  e.eventId :: seen

def deduplicate {Digest : Type}
    (eq : Digest → Digest → Bool)
    (events : List (Event Digest)) : List (Event Digest) :=
  go events []
where
  go : List (Event Digest) → List Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if memId eq seen e.eventId then go rest seen
      else e :: go rest (e.eventId :: seen)

end Assurance.Event
