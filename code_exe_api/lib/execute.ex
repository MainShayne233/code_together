defmodule CodeExeApi.Execute do

  def code(%{language: "ruby", code: code}) do
    file_name = "./exe/ruby_run_#{:os.system_time}.rb"
    code = code |> String.replace(~s("), ~s(\\"))
    code = Regex.replace(~r/\#{(.*?)}/, code, "\#{\\1}")
    |> String.replace(~s(\#{), ~s(\\\#{))
    file_name
    |> File.open!([:write])
    |> IO.binwrite(
      ~s(begin\n)                                <>
      ~s(  return_val = eval "\n#{code}\n" \n)   <>
      ~s(  print "=> \#{return_val || 'nil'}"\n) <>
      ~s(rescue Exception => e\n)                <>
      ~s(  print e\n)                            <>
      ~s(end)
    )
    |> File.close
    case System.cmd("ruby", [file_name]) do
      {result, 0} ->
        # File.rm(file_name)
        {:ok, result}
      {_, 1} ->
        File.rm(file_name)
        {:error, "Error when executing code"}
    end
  end

  def code(%{language: language}), do: code(%{language: language, code: ""})

end
