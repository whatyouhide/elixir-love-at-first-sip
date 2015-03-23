# First version with generic assertion code.
defmodule Assertions.V1 do
  defmacro assert(code) do
    quote do
      if unquote(code) do
        IO.puts "ok"
      else
        IO.puts """
        * Failure! *
        Code: #{unquote(Macro.to_string(code))}
        """
        raise "failure"
      end
    end
  end
end


# Second version which uses pattern matching to differentiate operators in order
# to show LHS and RHS.

defmodule Assertions.V2 do
  defmacro assert({_op, _meta, [lhs, rhs]} = code) do
    quote do
      if unquote(code) do
        IO.puts "ok"
      else
        IO.puts """
        * Failure! *
        Code: #{unquote(Macro.to_string(code))}
        LHS: #{unquote(lhs)}
        RHS: #{unquote(rhs)}
        """
        raise "failure"
      end
    end
  end

  defmacro assert(code) do
    quote do
      if unquote(code) do
        IO.puts "ok"
      else
        IO.puts """
        * Failure! *
        Code: #{unquote(Macro.to_string(code))}
        """
        raise "failure"
      end
    end
  end
end


# This has a bug because the operator isn't checked and the `{op, meta, [lhs,
# rhs]}` form could easily represent a function call with two arguments. To fix
# that, we should check that `op` is in a list of known operators, but we're not
# going to do that now.
