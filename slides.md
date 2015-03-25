class: center, first-slide

# Elixir: love at first sip

???

I thought I was being clever by using the word "sip" in the talk title since the
language is called Elixir. Well, I wasn't.



---
class: sips
<!-- ######################################################################## -->

--

![The First Few Sips](images/sips/the-first-few-sips.png)

--

![@elixirsips](images/sips/elixir-sips.png)

--

![A Sip of Elixir](images/sips/a-sip-of-elixir.png)



---
class: center
<!-- ####################################################################### -->

# Andrea Leopardi

@whatyouhide

andrea@leopardi.me

.avatar[![](images/avatar.jpg)]

???

My name is Andrea Leopardi.

I'm a recent CS graduate and I work on the web.

This is my face on the internet.



---
class: center
<!-- ####################################################################### -->

# Questions

Interrupt me!

???

If you have any questions at any moment feel free to interrupt me, I'd be glad
if you did.

So, today I'm going to tell you about Elixir.



---
<!-- ######################################################################## -->

# Elixir

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

- Dynamically typed (strongly typed)
- Runtime code evaluation


---
<!-- ######################################################################## -->

# Functional



---
<!-- ######################################################################## -->

# Functional

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

# Functional

High-order functions

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
- *Extremely* extensible
- Well documented



---
class: center, elixir-loves-erlang
<!-- ####################################################################### -->

# Elixir <3 Erlang

???

As I said, Elixir shares most of its features with Erlang. In the next part of
the talk, I will first highlight some of the great things that Elixir inherits
from Erlang, then I will focus on what Elixir brings to the table when compared
with Erlang.

I will skim over the basics (syntax, data types) and over the "classic"
functional features of the language, like:

- high-order functions
- immutable data structures

We're at a conference about functional languages after all!



---
<!-- ####################################################################### -->

# Pattern matching

`=` is not what it looks like.

--

```elixir
list = [1, 2, 3, 4]

[first, second|rest] = list

first  #=> 1
second #=> 2
rest   #=> [3, 4]
```

--

```elixir
tuple = {:my, 3, "elements", :tuple}

{:my, how_many, "ele" <> rest_of_the_string, :tuple} = tuple

how_many           #=> 3
rest_of_the_string #=> "ments"
```

???

`=` doesn't mean assignment, but it means pattern matching.

Similar to Haskell or ML.

Extremely useful in order to destructure complex data (and often only keep the
data we're interested in).

`=` can be used à-la-assignment because a "variable" matches anything and is
bounded to it.



---
<!-- ####################################################################### -->

# Pattern matching

Can be used in function heads:

```elixir
def do_action(:something) do
  something()
end

def do_action(:something_else) do
  something_else()
end
```

???

Pattern matching can be used in function heads.

This is extremely common in Erlang/Elixir for two reasons:

- it makes code much cleaner and easier to understand than when conditionals are
  used (since the spotlight is on the structure of the data) and it moves that
  logic "out" of the function
- it is very optimized by the Erlang VM

We will see an example of how we can take advantage of pattern matching later
on.



---
<!-- ####################################################################### -->

# Pattern matching + guards = polymorphism

(on steroids!)

```elixir
defmodule Math do
  def factorial(n) when n < 0 do
    raise "negative"
  end

  def factorial(0) do
    0
  end

  def factorial(n) do
    n * factorial(n - 1)
  end
end
```



---
<!-- ####################################################################### -->

# Processes

???

Compiling to Erlang code and running on the Erlang VM allows Elixir to leverage
all the power of Erlang itself.

Erlang allows to build very distributed, scalable and fault-tolerant
applications.

In Erlang, the basic unit of computation is the **process**.



---
<!-- ####################################################################### -->

# Processes

```elixir
pid = spawn fn ->
  IO.puts "Hello world!"
end
#=> #PID<0.61.0>
```

???

If you understand how an Erlang process works, then you will see all the power
of this language.

The first thing to keep in mind is that *an Erlang/Elixir process is not an OS
process*. It is entirely handled by the VM, allowing processes to:

- be very lightweight
- behave consistently over different OSs

A process is created by **spawning** a function.



---
<!-- ####################################################################### -->

# **Lightweight** processes


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
class: actor
<!-- ####################################################################### -->

```elixir
defmodule Actor do
  # "Client"
  def start(initial_state) do
    spawn fn -> loop(initial_state) end
  end

  def get(pid) do
    send pid, {:get, self()}
    receive do
      state -> state
    end
  end

  def put(pid, state) do
    send pid, {:put, self(), state}
  end

  # "Server"
  def loop(state) do
    receive do
      {:get, from} ->
        send(from, state)
        loop(state)
      {:put, from, new_state} ->
        loop(new_state)
    end
  end
end
```

--

```elixir
actor = Actor.start(1)
Actor.set(actor, 2)

Actor.get(actor)
#=> 2
```

???

With just these constructs, we can easily implement fairly complicated
things. For example, the implementation of something akin to the actor model can
fit in a slide.



---
<!-- ####################################################################### -->

# Error handling

Processes can be linked or monitored.

--

```elixir
spawn fn ->
  raise "dead :("
end
```

--

```elixir
spawn_link fn ->
  raise "die with me!"
end
```

--

```elixir
spawn_monitor fn ->
  raise "die"
end

# self() receives a :DOWN message
```

???

The other thing that makes Erlang processes so powerful is error handling.

When you spawn a process and that process dies abnormally (e.g., unhandled
exception) nothing happens to the parent process.

In order to propagate the error processes have to be **linked**. Links work
bilaterally.

If you want to only be notified when a process dies (unilaterally), then
**monitors** are the answer. This is extremely useful when you want to have a
process that monitors other processes and restarts them when they fail.



---
<!-- ####################################################################### -->

# Let it crash!

--

```elixir
spawn_monitor fn -> might_fail() end

receive do
  {:DOWN, _ref, :process, _pid, _reason} ->
    spawn_monitor fn -> might_fail() end
end
```


???

This brings us to an important phylosophy encouraged by Erlang: **let it crash**.

When something is going wrong with a computer, one of the easiest thing to do is
to simply *reboot* it: bring it back to an initial known initial state.

Erlang encourages to do the same thing: when a process fails, instead of trying
to fix the mess, just restart it in order to bring it back to a known initial state.



---
class: center, like-cs-for-js
<!-- ####################################################################### -->

Ah, like CoffeeScript for JavaScript

--

.no[NO]

--

More like Clojure for Java

???

So, Elixir inherits a lot of its power from Erlang. At this point, one could
argue that Elixir is like CoffeeScript for JavaScript.

It's very similar to what Clojure is for Java.

In the rest of the talk, we will talk about what makes Elixir great and why it's
an extremely valid choice over Erlang.



---
class: funny-quote
<!-- ####################################################################### -->

> Elixir is what would happend if **Erlang**, **Clojure** and **Ruby** somehow
> had a baby and it wasn't an accident.
> -- <cite>Devin Torres</cite>


---
<!-- ####################################################################### -->

# Interop

--

Erlang

```erlang
random:uniform().
%=> 0.4435846174457203
```

--

Elixir

```elixir
:random.uniform
#=> 0.4435846174457203
```

???

It's so easy to use Erlang from Elixir that it's almost ridicolous.



---
<!-- ####################################################################### -->

# Interop

--

Erlang

```erlang
lists:map(fun(El) -> El + 2 end, [1, 2, 3]).
%=> [3, 4, 5]
```

--

Elixir

```elixir
:lists.map(fn(el) -> el + 2 end, [1, 2, 3])
#=> [3, 4, 5]
```



---
<!-- ####################################################################### -->

# Protocols

<!-- Highlighted as Ruby since highlight.js is messy sometimes :( -->
```ruby
defprotocol Blank do
  @doc "Tells if the given data is blank"
  def blank?(data)
end
```

--

```elixir
defimpl Blank, for: List do
  def blank?([]) do
    true
  end

  def blank?(_) do
    false
  end
end
```

???

Inspired by Clojure



---
<!-- ####################################################################### -->

# Pipe operator

???

In functional languages, **transformation** of data is often emphasized.

Singing the praises of an *operator* may sound silly, but the pipe operator can
really make code **extremely** clear.

--

This...

```elixir
List.first(Enum.reject(String.codepoints("wat"), fn(char) -> char == "a" end))
```

--

...becomes this:

```elixir
"wat"
|> String.codepoints
|> Enum.reject(fn(char) -> char == "a" end)
|> List.first
```

???

The pipe operator simply takes the expression on its left-hand side and
passes it as the first argument to the function call on its right-hand side.



---
<!-- ####################################################################### -->

# Pipe operator

Non-ridicolous (still simplified) example:

```elixir
def eval_file(path) do
  path
  |> File.read!
  |> Tokenizer.tokenize
  |> Parser.parse
  |> Interpreter.eval
end
```

Nice, uh?



---
<!-- ####################################################################### -->

# Tooling

Great REPL (IEx):

```elixir
iex(1)> 3 + 4
7
iex(3)> v(1) + 4
11
```



---
<!-- ####################################################################### -->

# Tooling

Built-in templating language (EEx):

```elixir
EEx.eval_string "Hello, <%= name %>", [name: "José"]
#=> "Hello, José"
```



---
<!-- ####################################################################### -->

# Tooling

Build/test/project management tool (Mix):

```bash
mix new my_new_project
cd my_new_project
mix compile
mix test
```



---
<!-- ####################################################################### -->

# Tooling

Package manager (Hex):

```elixir
def dependencies do
  [{:cowboy, "~> 1.0"},
   {:plug, github: "elixir-lang/plug"}]
end
```

(not in the core)



---
<!-- ####################################################################### -->

Ok, so that's pretty much it...

--

.wait[WAIT]

???

We saw that Elixir adds a lot of niceties to Erlang, and it's a valid
alternative. Learning the syntax and all the quirks may not be worth it, but
it's nice to have another option.

Ok, the talk is ov-WAIT! METAPROGRAMMING!



---
class: metaprogramming, center
<!-- ####################################################################### -->

# METAPROGRAMMING

???

Elixir compiler is extremely powerful and allows for extreme
metaprogramming. First of all, this may come as a surprise but Elixir is
actually **homoiconic**.



---
class: center
<!-- ####################################################################### -->

# MACROS!

.kid[![](images/metaprogramming.gif)]



---
class: center
<!-- ####################################################################### -->

# HOMOICONICITY!

.andy[![](images/homoiconicity.gif)]



---
class: center
<!-- ####################################################################### -->

.minions[![](images/minions.gif)]

???

To be honest, this is how I imagined you at this point but, well... ok.



---
<!-- ####################################################################### -->

# Homoiconicity

> In a homoiconic language the primary representation of programs is also a data
> structure in a primitive type of the language itself.

The representation of Elixir code is valid Elixir code!

???

It's much easier to see the homoiconicity in Lisp because pretty much every
complex data is just a list (code *and* representation). In Elixir, the syntax
does not reflect this property.


---

# Quoting

```elixir
quote do
  1 + 2
end
#=> {:+, _metadata, [1, 2]}
```

Looks not-so-different from Lisp:

```lisp
(+ 1 2)
```

???

In Elixir, you can **quote** expressions to get their internal representation (AST).

Quoting primitive values (like strings, numbers, atoms) returns the values
themselves, but quoting everything else returns a three-elements tuple with:

* function name
* metadata
* arguments

--

God-mode

```elixir
{:+, meta, args} = quote(do: 1 + 2)

Code.eval_quoted {:-, meta, args}
#=> {-1, []}
```

???

You can manipulate the AST just like any other Elixir code.



---
<!-- ####################################################################### -->

# Unquoting

--

```elixir
a = 1

quote do
  a + 3
end
#=> {:+, _metadata, [{:a, [], Elixir}, 3]}
```

--

```elixir
a = 1

quote do
  unquote(a) + 3
end
#=> {:+, _metadata, [1, 3]}
```

???

When you want to inject a value into a quoted expression. Think of it like
**string interpolation** for code.



---
<!-- ####################################################################### -->

# Macros

```elixir
defmodule MyMacros do
  defmacro unless(condition, do: something) do
    quote do
      if !unquote(condition) do
        unquote(something)
      end
    end
  end
end
```

--

```elixir
require MyMacros

MyMacros.unless 2 + 2 == 5 do
  "Math still works"
end
#=> "Math still works"
```

???

Macros are wrappers around quoting: a macro receives its arguments as a quoted
expression and must return a quoted expression (an AST). *That expression is
executed in the caller's context, immediately*.



---
<!-- ####################################################################### -->

# Demo time!

--

1. Nano assertion framework

--

2. Logging with levels

--

3. The power of the compiler

???

Dataset:
https://dspl.googlecode.com/hg/datasets/google/canonical/currencies.csv



---
class: center
<!-- ####################################################################### -->

# Questions?

Andrea Leopardi

@whatyouhide (twitter/github)

andrea@leopardi.me
