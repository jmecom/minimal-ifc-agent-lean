import OpenAiApi

def main : IO Unit := do
  let stdin ← IO.getStdin
  let stdout ← IO.getStdout
  let mut previousResponseId : Option String := none

  while true do
    stdout.putStr "You: "
    stdout.flush

    let line ← stdin.getLine

    if line.isEmpty then
      stdout.putStrLn ""
      break

    let prompt := line.trimAscii.toString

    if prompt == "/quit" then
      break

    if prompt.isEmpty then
      continue

    let response ← OpenAiApi.respond prompt previousResponseId
    let text ← IO.ofExcept response.outputText

    stdout.putStrLn s!"Assistant: {text}\n"
    previousResponseId := some response.id
