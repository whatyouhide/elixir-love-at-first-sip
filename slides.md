---
<!-- ######################################################################## -->

# Elixir: love at first sip

???

I thought I was being clever by using the word "sip" in the talk title since the
language is called Elixir. Well, I wasn't.



---
<!-- ######################################################################## -->

![The First Few Sips](images/sips/the-first-few-sips.png)
![@elixirsips](images/sips/elixir-sips.png)
![A Sip of Elixir](images/sips/a-sip-of-elixir.png)









---


???

My name is Andrea Leopardi.

I'm a recent CS graduate and I work on the web.

---

???

Today I'm going to tell you about Elixir.



---
<!-- ######################################################################## -->

# Elixir

Programming language that runs on the Erlang VM



---
<!-- ######################################################################## -->

> Elixir is a dynamic, functional language designed for building scalable and
> maintainable applications.

--

Nice!

???

I could have come up with a nice pitch for Elixir, but I'm lazy and the Elixir
website already has one.

So, let's briefly see what that means.



---
<!-- ######################################################################## -->

# What does it look like

```elixir
defmodule Slugger do
  @doc "Slugs a string."
  @spec slufigy(String.t) :: String.t
  def slugify(str) do
    str
    |> String.downcase
    |> String.replace("'", "")
    |> String.replace(~/[?!,\-:;.]/, "-")
  end
end
```



---
<!-- ######################################################################## -->

# Dynamic

- Dynamically typed

```elixir
a = 1
b = "foo"
a = :gotcha
```



---
<!-- ######################################################################## -->

# Functional



---
<!-- ######################################################################## -->

Immutable data structures

```elixir
list = [:foo, :bar, :baz]

List.delete_at(list, 1)
#=> [:foo, :baz]

list
#=> [:foo, :bar, :baz]
```


???

Data structures in Elixir are just like Erlang data structures (actually, they
*are* Erlang data structures).



---
<!-- ######################################################################## -->

High-order functions

--

```elixir
sum = fn(n) ->
  fn(x) -> x + n end
end

add42 = sum.(42)
add42.(1)
#=> 43
```

--

```elixir
Enum.map [1, 2, 3, 4], fn(x) ->
  x * 3
end
#=> [3, 6, 9, 12]
```

???

Elixir functions are Erlang functions and Elixir modules are Erlang modules.


---
<!-- ######################################################################## -->

## Not *purely* functional

--

Side effects:

```elixir
iex> IO.puts "Hello world!"
Hello world!
:ok
```

--

Call-dependent results:

```elixir
iex> :erlang.now()
{1426, 179468, 348062}
iex> :erlang.now()
{1426, 179478, 386986}
```



---
<!-- ######################################################################## -->

# Scalable

```elixir
for _ <- 1..1_000_000 do
  spawn fn ->
    "hello"
  end
end
```

Thanks Erlang!



---
<!-- ######################################################################## -->

# Maintainable

- Nice syntax
- *Extremely* extensible (hint: macros!)
- Well documented



---
<!-- ####################################################################### -->

???

As I said, Elixir shares most of its features with Erlang. In the next part of
the talk, I will first highlight some of the great things that Elixir inherits
from Erlang, then I will focus on what Elixir brings to the table when compared
with Erlang.





---
<!-- ####################################################################### -->

--

# Process


???

Compiling to Erlang code and running on the Erlang VM allows Elixir to leverage
all the power of Erlang itself.o

Erlang allows to build very distributed, scalable and fault-tolerant
applications.

In Erlang, the basic unit of computation is the **process**.



---
<!-- ####################################################################### -->

???

If you understand how an Erlang process works, then you will see all the power
of this language. So, let's dive in!

The first thing to keep in mind is that *an Erlang/Elixir process is not an OS
process*. It is entirely handled by the VM, allowing processes to:

- be very lightweight
- behave consistently over different OSs

--

```elixir
pid = spawn fn ->
  IO.puts "Hello world!"
end
#=> #PID<0.61.0>
```


???

A process is created by **spawning** a function.



---
<!-- ####################################################################### -->

# Lightweight

```elixir
:timer.tc fn ->
  Enum.each 1..100_000, fn(_) ->
    spawn(fn -> :foo end)
  end
end
#=> {1735741, :ok}
```

That's about **1.7s** for 100k spawned processes!


???

Processes are **extremely** lightweight.

(*Don't mind the syntax, we will briefly talk about it later on*)

{Show that code in the console}



---
<!-- ####################################################################### -->

# Sending messages

```elixir
pid = spawn fn ->
  :timer.sleep 20_000
end

send pid, "Hello!"
#=> "Hello!"
```


???

Processes cannot share memory. The only form of communication between processes
is through *asynchronous* message passing.

You can *send* a process some message by using the primitive `send/2` passing
the pid of the process. Sending is *asynchronous*, and `send/2` will always
return the second argument passed to it.

Messages send to a process are guaranteed to be delivered to that process, and
they end up in that process' **message queue**.



---
<!-- ####################################################################### -->

# Receiving messages

```elixir
pid = spawn fn ->
  receive do
    {from, :hello} -> send from, {self(), "Hello to you!"}
    {from, :bye}   -> send from, {self(), "Bye bye!"}
    _              -> send from, {self(), "Eh?"}
  end
end
```

--

```elixir
send pid, {self(), :hello}
#=> {#PID<0.79.0>, :hello}
```

--

```elixir
receive do
  {_from, message} -> "Response: #{message}"
end
#=> "Response: Hello to you!"
```

???

To receive a message, a process has to use the `receive` construct. Receiving
messages is *blocking*.

When a process calls `receive`, the first message in the queue that matches one
of the patterns is removed from the queue. If no messages are in the queue, the
process waits for one (with a configurable timeout).















---

Elixir : Erlang = CoffeeScript : JavaScript **NO!**

Elixir : Erlang ≅ Clojure : Java



???

Elixir code is pretty much Erlang code.

Elixir data structures are Erlang data structures, and Erlang processes are
Elixir processes.




---





---

# Homoiconicity

> In a homoiconic language the primary representation of programs is also a data
> structure in a primitive type of the language itself.


---

# Quoting

???

How does quoting work? It's very similar to languages like Lisp. You quote an
expression and that expression is not evaluated: its AST is returned. If you
want to inject values from the outer context into a quoted expression, you just
**unquote** those values (just like you would do in Lisp).

Small example:

```elixir
quote do
  foo(1, 2)
end
#=> {:foo, [], [1, 2]}
```

`{:foo, [], [1, 2]}` looks very similar to a possible Lisp analogous, `(foo 1 2)`.


---

# Macros

???

Macros are wrappers around quoting: a macro receives its arguments as an AST (as
if they had been quoted before having been passed to the macro) and must return
a quoted expression (an AST). *That expression is executed in the caller's
context, immediately*.


---

# Demo time!

???

Dataset:
https://dspl.googlecode.com/hg/datasets/google/canonical/currencies.csv


---

???

One point I want to stress: why using Elixir instead of Erlang?

Using Elixir, you get all the power of Erlang (all the nice things like
lightweight processes, fault-tolerance, low latency and so on) with in addition:

* Homoiconicity (and thus macros)
* Nicer syntax
* Easy string/binary manipulation (instead of binaries/charlists in Erlang)
* Lots of cool new libraries

At the same time, however, you're really not giving up anything: Elixir has
direct access to **everything** in the Erlang VM: you can use modules, functions
and data structures from Erlang. Say you don't trust Elixir's `String` module:
just call functions from the `:binary` module and you're fine.

You could write Elixir code using only Erlang stuff, and you could still gain
from macros and nicer syntax. It would still be worth it.
