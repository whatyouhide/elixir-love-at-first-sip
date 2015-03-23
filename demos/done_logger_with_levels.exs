defmodule LoggerWithLevels do
  @level (System.get_env("LLEVEL") || "debug")
         |> String.downcase
         |> String.to_atom

  defmacro log(@level, str) do
    quote do
      IO.puts unquote(str)
    end
  end

  defmacro log(_level, _str) do
    nil
  end
end
