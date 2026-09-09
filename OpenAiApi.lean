import Lean

namespace OpenAiApi

structure Usage where
  input_tokens : Nat
  output_tokens : Nat
  total_tokens : Nat

  input_tokens_details : Option Lean.Json
  output_tokens_details : Option Lean.Json

  deriving Lean.FromJson

structure Response where
  id : String
  model : String

  created_at : Float
  completed_at : Option Float
  status : Option String

  output : Array Lean.Json
  usage : Option Usage

  error : Option Lean.Json
  incomplete_details : Option Lean.Json

  deriving Lean.FromJson

def Response.outputText (response : Response) : Except String String := do
  let mut texts : Array String := #[]

  for item in response.output do
    if (item.getObjValAs? String "type").toOption == some "message" then
      let content ← item.getObjValAs? (Array Lean.Json) "content"

      for part in content do
        if let .ok text := part.getObjValAs? String "text" then
          texts := texts.push text
        else if let .ok refusal := part.getObjValAs? String "refusal" then
          texts := texts.push refusal

  return String.intercalate "\n" texts.toList

def respond (prompt : String) (previousResponseId : Option String := none) : IO Response := do
  let some apiKey ← IO.getEnv "OPENAI_API_KEY"
    | throw <| IO.userError "Set OPENAI_API_KEY."

  let model := (← IO.getEnv "OPENAI_MODEL").getD "gpt-5.4-mini"
  let body := Lean.Json.mkObj (
    [("model", .str model), ("input", .str prompt)] ++
    Lean.Json.opt "previous_response_id" previousResponseId)

  let result ← IO.Process.output {
    cmd := "curl"
    args := #[
      "--silent", "--show-error", "--fail-with-body",
      "https://api.openai.com/v1/responses",
      "--header", s!"Authorization: Bearer {apiKey}",
      "--header", "Content-Type: application/json",
      "--data-binary", "@-"
    ]
  } (some body.compress)

  if result.exitCode != 0 then
    throw <| IO.userError s!"{result.stderr}{result.stdout}"

  let response ← IO.ofExcept (Lean.Json.parse result.stdout)
  IO.ofExcept (Lean.fromJson? response)

end OpenAiApi
