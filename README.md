# minimal-ifc-agent-lean

A minimal Lean 4 chat program. `Main.lean` loops over `You:` prompts, calls the
OpenAI Responses API through `curl`, and prints each reply below an `Assistant`
heading. Like the Python UI, prompts are bold green and assistant headings are
bold cyan, with blank lines between turns. Colors are enabled only on terminals;
set `NO_COLOR=1` to disable them.

It passes the previous response ID with each follow-up so the conversation
keeps its context. Blank lines are skipped; `/quit` or Ctrl-D exits.

The `OpenAiApi.respond` function in `OpenAiApi.lean` handles the API call and
returns an `OpenAiApi.Response` with the ID, model, timestamps, status, output
items, token usage, and error details. Output items remain JSON so message,
reasoning, and tool-call data are preserved. `Response.outputText` extracts
text for display. `Ui.lean` handles prompts, colors, and console output;
`Main.lean` owns the conversation loop.

`Ifc.lean` defines public/private confidentiality, trusted/untrusted integrity,
and the rules for combining labels. Private data cannot flow to a public label,
and untrusted data cannot flow to a trusted label.

`Labeled label α` puts the label in the value's type. `map` preserves it;
`zipWith` combines both inputs' labels. `relabel` requires a proof of
`FlowsTo source destination`; Lean fills it in for concrete labels. `tryRelabel`
checks that same rule at runtime, with a proof that it accepts exactly the allowed flows.
These are label primitives: the chat has not yet been connected to them.
Constructing a labeled value or accessing its `.value` is trusted code.

`IfcProofs.lean` proves that flow is a partial order (`a ≤ b` means `FlowsTo a b`),
and that `join` is associative, commutative, and idempotent. Its central theorem,
`Label.join_flowsTo`, says a combined value may flow to a destination exactly
when both inputs may flow there. Import `Ifc` for the types and operations, or
`IfcProofs` to include the theorems and partial-order laws. `IfcTests.lean` checks
examples using both. These proofs use Lean's standard library.

Install [Lean via elan](https://lean-lang.org/install/manual/) and have `curl`
on your path, then run:

```sh
source ~/.elan/env
export OPENAI_API_KEY="your-api-key"
lake exe chat
```

Set `OPENAI_MODEL` to override the default model, `gpt-5.4-mini`.
Run `lake build` to compile the chat and check the IFC rules and examples
without making an API request.
