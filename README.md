# Modifiers
[![Build Status](https://travis-ci.org/nicknovitski/modifiers.svg?branch=master)](https://travis-ci.org/nicknovitski/modifiers)

## What is/are Modifiers?

`Modifiers` is a collection of method modifiers, and a way to make more.

_Method Modifiers_, obviously, are modifiers to methods.  Specifically, in Ruby
terms, they are class methods which:

1. Take a symbol argument which names an instance method of the same class, and
2. Return the same symbol, but
3. Alter the named method in some way.

Ruby has shipped with four (4) modifiers since forever: the three access
modifiers (`public`, `private`, and `protected`), and `module_function`.  This
library [adds a few others, and a facility for creating even more](#usage).

## Why is/are Modifiers?

DRYing up code sometimes involves smaller fragments of shared behavior than a
method.  Here's an example you've probably read and written before:
```ruby
# old and busted
def count_ducks
  @count_ducks ||= DuckFlock.all.map(&size).inject(0, &:+)
end
```

Why are you writing the characters 'count_ducks', in the _exact same order_
__two whole times__?  If you already know how to implement memoization, why let
your code challenge you to prove it every time you want it done?! Instead,
implement it one final, flawless time, and tell the interpreter firmly, "No,
_you_ type the name twice, my time is far too valuable."

## Installation

Add this line to your application's Gemfile:

    gem 'modifiers', require: false

And then execute:

    $ bundle

## Usage

### built-in modifiers

#### deprecated

Sometimes there's a method, and you want it to die, but not a clean, swift
death.  Instead, you wish it a slow, cursed strangulation, as collaborators
gradually abandon it.  Mark it with your sign, that all may know to shun it or
be punished.

```ruby
require 'modifiers/deprecated'

class BadHacks
  extend Modifiers

  deprecated def awful_method
    # some ugly hack, probably involving define_method and ObjectSpace
  end
end
```

A method modified by `deprecated` will issue a helpful deprecation warning
every time it is called.  Something like: `deprecated method
BadHacks#awful_method called from app/controllers/ducks_controller.rb:782`

(Please note that the `deprecated` method is deprecated, and you should
definitely use `Gem.deprecate` instead.)

#### memoized

Every now and then, you will come to care how long it takes for a method to
run.  You may find yourself wishing it just re-used some hard-won values,
rather than throwing them away and rebuilding them anew every time you call it.

To demonstrate this, on multiple levels, I will re-use the case from a previous
section.

```ruby
require 'modifiers/memoized'

class DuckService
  extend Modifiers

  memoized def count_ducks
    DuckFlock.all.map(&size).inject(0, &:+)
  end
end
```

A method modified by `memoized` will run once normally, per unique combination
of arguments, after which it will simply return the same result for the
lifetime of the receiving object. Dazzle your friends with your terse, yet
performant, fibonnaci implementations!

(If you want all this and more, you can use
[memoist](https://github.com/matthewrudy/memoist) (formerly
`ActiveSupport::Memoizable`) instead, but I warn you: it involves `eval`.)

#### commands and queries

You may have heard of 'Command-Query Separation`, and the claim that code
quality can be improved by writing methods to either have only side-effects, or
no side-effects.

It may or may not be a good idea, but at least now it's easy to unambiguously
indicate and enforce!

First, a method modified by `command` will always return nil.  It's as trivial as it
sounds.

Conversely (?), a method modified by `query` will never change the state of
anything non-global and in-process.  This is also trivial, but it might seem
more impressive.
```ruby
require 'modifiers/command_query'

class DuckFarmer < Struct.new(:hutches)
  extend Modifiers

  query def fullest_hutch
    hutches.max { |h1,h2| h1.count_eggs - h2.count_eggs }
  end
end

class DuckHutch < Struct.new(:num_eggs)
  def self.count_eggs
    @ducks_disturbed = true
    num_eggs
  end

  def ducks_disturbed?
    @ducks_disturbed
  end
end

john = DuckFarmer.new(Array.new(3) { DuckHutch.new(rand(20)) })

john.fullest_hutch # => #<struct DuckHutch num_eggs=11>

john.hutches.any? { |h| h.ducks_disturbed? } # => false
```

If this was an infomercial, now is when I would say something like "It's just
that easy, Michael!", and you (your name is Michael in this scenario) would say
"Now _that's_ incredible!" and the audience would applaud.

I'm mildly proud of this library.

### defining new modifiers

New modifiers can be defined in your own modules using the `define_modifier` method.

Let's start with the simplest case: the null modifier, with a name, but no behavior.

```ruby
require 'modifiers/define_modifier'

module DuckFarmModifiers
  extend Modifiers
  define_modifier(:duck)
end

class DuckFarm
  extend DuckFarmModifiers

  duck :some_method # => unchanged
end
```

Here's an identical implementation:
```ruby
module DuckFarmModifiers
  define_modifier(:duck) do |method_invocation|
    method_invocation.invoke
  end
end
```

A block passed to `define_modifier` will become the new body of the methods
modified by the modifier, kinda like with `define_method`.

The argument passed to that block will be an object representing a particular
call to the modified method.  As I showed you above, all you have to do
continue that call as normal is `#invoke` it.

Or not!
```ruby
module DuckFarmModifiers
  define_modifier(:x) do
    # temporarily disable a method and see if anyone notices
  end
end
```

You can do things before, after, or even "around" the invocation.
```ruby
module DuckFarmModifiers
  define_modifier(:perf_logged) do |invocation|
    start = Time.now
    invocation.invoke
    Rails.logger "#{invocation.method_identifier} finished in #{Time.now - start}s"
  end
end
```

The method invocation object can also tell you the `#arguments` in the call,
and its `#location` in the source, the `#method_name` of the method which was
modified, or even the full `#method_identifier` in
`Class.class_method`/`Class#instance_method` style.  All of the modifiers
included in the library were made using it.

What awesome ones will _you_ write?

## Contributing

1. [Fork it](https://github.com/nicknovitski/modifiers/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
