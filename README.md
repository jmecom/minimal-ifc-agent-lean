# minimal-ifc-agent-lean

A minimal Lean 4 chat program. `Main.lean` loops over `You:` prompts, calls the
OpenAI Responses API through `curl`, and prints each reply as `Assistant:`.
It passes the previous response ID with each follow-up so the conversation
keeps its context. Blank lines are skipped; `/quit` or Ctrl-D exits.

The `OpenAiApi.respond` function in `OpenAiApi.lean` handles the API call and
returns an `OpenAiApi.Response` with the ID, model, timestamps, status, output
items, token usage, and error details. Output items remain JSON so message,
reasoning, and tool-call data are preserved. `Response.outputText` extracts
text for display; `main` handles console input and output.

Install [Lean via elan](https://lean-lang.org/install/manual/) and have `curl`
on your path, then run:

```sh
source ~/.elan/env
export OPENAI_API_KEY="your-api-key"
lake exe chat
```

Set `OPENAI_MODEL` to override the default model, `gpt-5.4-mini`.
Run `lake build` to compile without making an API request.
