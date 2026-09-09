import Init

namespace Ui

private def color (stdout : IO.FS.Stream) (style text : String) : IO String := do
  let noColor := (← IO.getEnv "NO_COLOR").getD ""
  let useColor := (← stdout.isTty) && noColor.isEmpty

  return if useColor then s!"\x1b[{style}m{text}\x1b[0m" else text

def readPrompt : IO (Option String) := do
  let stdout ← IO.getStdout
  let label ← color stdout "1;32" "You: "

  stdout.putStr s!"\n{label}"
  stdout.flush

  let line ← (← IO.getStdin).getLine

  if line.isEmpty then
    stdout.putStrLn ""
    return none

  return some line.trimAscii.toString

def printResponse (text : String) : IO Unit := do
  let stdout ← IO.getStdout
  let label ← color stdout "1;36" "Assistant"

  stdout.putStrLn s!"\n{label}\n{text}"
  stdout.flush

end Ui
