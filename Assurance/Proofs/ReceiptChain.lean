import Assurance.Models.DegradationRules

/-!
  ReceiptChain inversion and transport lemmas.
  The primary lemma `ReceiptChain.head_timestamp_ge` currently lives in Models
  for dependency simplicity; it can be moved here once the module graph is stable.
-/

namespace Assurance.Proofs.ReceiptChain

-- Re-export for convenience
export Assurance.Models (ReceiptChain.head_timestamp_ge)

end Assurance.Proofs.ReceiptChain
