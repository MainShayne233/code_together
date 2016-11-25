defmodule CodeTogether.Language do

  def default_code_for("ruby") do
    "class String\n  "         <>
    "def palindrome?\n    "    <>
    "self == self.reverse\n  " <>
    "end\nend\n\n'racecar'.palindrome?"
  end
  
  def default_output_for("ruby"), do: "=> true"

end
