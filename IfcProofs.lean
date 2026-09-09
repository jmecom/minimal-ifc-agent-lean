import Ifc

namespace Ifc

-- `@[simp]` makes this fact available to the simplifier in later proofs.
@[simp] theorem FlowsTo.refl (label : Label) : FlowsTo label label := by
  -- `rcases` unpacks the label and splits each field into its two constructors.
  -- `<;>` runs `decide` on every resulting case, covering all four labels.
  rcases label with ⟨_ | _, _ | _⟩ <;> decide

/-- Two allowed hops compose into one allowed flow. -/
theorem FlowsTo.trans {a b c : Label}
    (ab : FlowsTo a b) (bc : FlowsTo b c) : FlowsTo a c := by
  -- `grind` uses the definition and the two hypotheses to construct a proof.
  grind [FlowsTo]

/-- Flow in both directions is possible only when the labels are equal. -/
theorem FlowsTo.antisymm {a b : Label}
    (ab : FlowsTo a b) (ba : FlowsTo b a) : a = b := by
  rcases a with ⟨_ | _, _ | _⟩ <;>
    rcases b with ⟨_ | _, _ | _⟩ <;> simp_all [FlowsTo]

-- Register the three laws so generic Lean code can treat labels as a partial order.
instance : Std.IsPartialOrder Label where
  le_refl := FlowsTo.refl
  le_trans _ _ _ := FlowsTo.trans
  le_antisymm _ _ := FlowsTo.antisymm

/-- A combined value may flow somewhere exactly when both inputs may flow there.
The `↔` proves both directions: `join` preserves the restrictions without adding
unnecessary ones. -/
@[simp] theorem Label.join_flowsTo {a b destination : Label} :
    FlowsTo (a.join b) destination ↔ FlowsTo a destination ∧ FlowsTo b destination := by
  rcases a with ⟨_ | _, _ | _⟩ <;>
    rcases b with ⟨_ | _, _ | _⟩ <;>
    rcases destination with ⟨_ | _, _ | _⟩ <;> decide

-- The joined label flows to itself. Applying the forward direction (`.mp`) of
-- the theorem above gives a conjunction: `.1` selects the left input's proof,
-- and `.2` selects the right input's proof.
@[simp] theorem Label.flowsTo_join_left (a b : Label) : FlowsTo a (a.join b) :=
  (join_flowsTo.mp (FlowsTo.refl (a.join b))).1

@[simp] theorem Label.flowsTo_join_right (a b : Label) : FlowsTo b (a.join b) :=
  (join_flowsTo.mp (FlowsTo.refl (a.join b))).2

@[simp] theorem Label.join_self (a : Label) : a.join a = a := by
  -- Prove equality by showing flow in both directions; `simp` uses the laws above.
  apply FlowsTo.antisymm <;> simp

theorem Label.join_comm (a b : Label) : a.join b = b.join a := by
  apply FlowsTo.antisymm <;> simp

theorem Label.join_assoc (a b c : Label) : (a.join b).join c = a.join (b.join c) := by
  -- Once the labels are concrete, `rfl` checks that both sides compute identically.
  rcases a with ⟨_ | _, _ | _⟩ <;>
    rcases b with ⟨_ | _, _ | _⟩ <;>
    rcases c with ⟨_ | _, _ | _⟩ <;> rfl

/-- The runtime check accepts exactly the flows allowed by the type-level rule. -/
@[simp] theorem Labeled.tryRelabel_isSome (input : Labeled source α) (destination : Label) :
    (input.tryRelabel destination).isSome = true ↔ FlowsTo source destination := by
  unfold tryRelabel
  -- Check both branches; `simp_all` simplifies using each branch's flow hypothesis.
  split <;> simp_all

end Ifc
