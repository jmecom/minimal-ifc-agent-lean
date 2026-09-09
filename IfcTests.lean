import IfcProofs

open Ifc

private def publicTrusted : Label := ⟨.public, .trusted⟩
private def publicUntrusted : Label := ⟨.public, .untrusted⟩
private def privateTrusted : Label := ⟨.private, .trusted⟩
private def privateUntrusted : Label := ⟨.private, .untrusted⟩

private def labels := [publicTrusted, publicUntrusted, privateTrusted, privateUntrusted]

#guard labels.map (fun source => labels.map (fun destination => decide (FlowsTo source destination))) ==
  [[true, true, true, true],
   [false, true, false, true],
   [false, false, true, true],
   [false, false, false, true]]

example (a b c : Label) (ab : a ≤ b) (bc : b ≤ c) : a ≤ c :=
  Std.IsPreorder.le_trans a b c ab bc

private def publicText : Labeled publicTrusted String := ⟨"hello"⟩
private def privateText : Labeled privateUntrusted String := ⟨"private"⟩

example : Labeled publicTrusted Nat := publicText.map String.length

example : Labeled privateUntrusted String :=
  publicText.zipWith (fun a b => s!"{a}: {b}") privateText

example : Labeled privateUntrusted String :=
  publicText.relabel privateUntrusted

example {label : Label} (first second : Labeled label String) : Labeled label String := by
  simpa using first.zipWith String.append second

example {a b c : Label}
    (first : Labeled a String) (second : Labeled b String) (third : Labeled c String) :
    Labeled (a.join (b.join c)) String := by
  simpa only [Label.join_assoc] using (first.zipWith String.append second).zipWith String.append third

example {a b destination : Label} (first : Labeled a String) (second : Labeled b String)
    (ha : FlowsTo a destination) (hb : FlowsTo b destination) : Labeled destination String :=
  (first.zipWith String.append second).relabel destination (Label.join_flowsTo.mpr ⟨ha, hb⟩)

-- These relabels must fail to elaborate, even when the proof is filled in automatically.
example : Labeled publicUntrusted String := by
  fail_if_success exact privateText.relabel publicUntrusted
  exact publicText.relabel publicUntrusted

example : Labeled privateTrusted String := by
  fail_if_success exact privateText.relabel privateTrusted
  exact publicText.relabel privateTrusted

example : ¬ FlowsTo privateTrusted publicTrusted := by decide
example : ¬ FlowsTo publicUntrusted publicTrusted := by decide

#guard (privateText.tryRelabel publicTrusted).isNone
#guard (publicText.tryRelabel privateUntrusted).isSome
#guard (publicText.map String.length).value == 5
