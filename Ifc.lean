import Lean

namespace Ifc

-- The guillemets let us use Lean keywords as constructor names.
inductive Confidentiality where
  | «public»
  | «private»

  deriving DecidableEq, Repr

inductive Integrity where
  | trusted
  | untrusted

  deriving DecidableEq, Repr

structure Label where
  confidentiality : Confidentiality
  integrity : Integrity

  deriving DecidableEq, Repr

/-- Both conditions must hold: private data stays private, and untrusted data
stays untrusted. `Prop` lets callers require a proof that a flow is allowed. -/
def FlowsTo (source destination : Label) : Prop :=
  (source.confidentiality = .public ∨ destination.confidentiality = .private) ∧
  (source.integrity = .trusted ∨ destination.integrity = .untrusted)

-- `Decidable` connects the proposition to computation: Lean can either prove
-- the flow is allowed or prove it is forbidden. It supports `by decide` and `if`.
instance (source destination : Label) : Decidable (FlowsTo source destination) := by
  unfold FlowsTo
  infer_instance

/-- `a ≤ b` means information labeled `a` may flow to label `b`. -/
instance : LE Label := ⟨FlowsTo⟩

/-- Keep the restrictions of both inputs: either private input makes the result
private, and either untrusted input makes the result untrusted. -/
def Label.join (first second : Label) : Label where
  confidentiality :=
    match first.confidentiality, second.confidentiality with
    | .public, .public => .public
    | _, _ => .private

  integrity :=
    match first.integrity, second.integrity with
    | .trusted, .trusted => .trusted
    | _, _ => .untrusted

/-- `label` is part of the type, so values with different labels are not
interchangeable. `α` is the payload type; `u` lets it live in any type universe.

Construction, raw `.value` access, and functions passed below are trusted code.
The wrapper does not track captured values or restrict arbitrary Lean IO. -/
structure Labeled (label : Label) (α : Type u) where
  value : α

/-- Transforming the payload, such as taking a string's length, keeps its label. -/
def Labeled.map (f : α → β) (input : Labeled label α) : Labeled label β :=
  ⟨f input.value⟩

/-- The result type computes its label from both inputs. The caller does not
choose a separate output label. -/
def Labeled.zipWith (f : α → β → γ)
    (first : Labeled firstLabel α) (second : Labeled secondLabel β) :
    Labeled (firstLabel.join secondLabel) γ :=
  ⟨f first.value second.value⟩

/-- For concrete labels, the default `by decide` supplies the proof at the call
site. For symbolic labels, pass a proof explicitly. Proofs are erased at runtime;
the payload is unchanged. -/
def Labeled.relabel (input : Labeled source α) (destination : Label)
    (_allowed : FlowsTo source destination := by decide) : Labeled destination α :=
  ⟨input.value⟩

/-- Use a runtime check when the labels are not known during compilation. -/
def Labeled.tryRelabel (input : Labeled source α) (destination : Label) :
    Option (Labeled destination α) :=
  -- The named `if` gives the successful branch a proof called `allowed`, which
  -- satisfies `relabel`'s proof argument. Even here, the result type fixes the label.
  if allowed : FlowsTo source destination then
    some (input.relabel destination allowed)
  else
    none

end Ifc
