import OpenAiApi
import Ui

def main : IO Unit := do
  let mut previousResponseId : Option String := none

  while true do
    let some prompt ← Ui.readPrompt
      | break

    if prompt == "/quit" then
      break

    if prompt.isEmpty then
      continue

    let response ← OpenAiApi.respond prompt previousResponseId
    let text ← IO.ofExcept response.outputText

    Ui.printResponse text

    previousResponseId := some response.id
