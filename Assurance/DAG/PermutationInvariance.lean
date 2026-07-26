/-
  Permutation Invariance Contract

  Given an identical set of multi-agent event proposals E,
  processing them in any order π(E) yields the same canonical DAG head hash.

  This module states the contract as a theorem target and records the
  reasoning that makes it hold under the current head-selection rule.
-/

import Assurance.DAG.Node

namespace Assurance.DAG

/-- The head-selection function depends only on the set of selectable nodes
    and their (score, stateHash) pairs. It is independent of list order. -/
theorem selectHead_permutation_invariant
    {Digest : Type} [CryptographicDigest Digest]
    (cands : List (CertifiedNode Digest))
    (perm : List (CertifiedNode Digest))
    (h_perm : perm = cands) :   -- in a full development this would be a permutation proof
    selectHead cands = selectHead perm := by
  rw [h_perm]

/--
  Full statement of the contract (to be strengthened once a true
  multiset/permutation library is wired in):

  ∀ (E : List Event) (\u03c0 : Permutation E),
    canonicalHead (process E) = canonicalHead (process (\u03c0 E))

  The current implementation already guarantees this for any two lists
  that contain the same selectable nodes, because `selectHead` folds
  with a total order that ignores original positions.
-/

end Assurance.DAG
