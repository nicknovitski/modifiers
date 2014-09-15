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

The pursuit of DRY code can involve fragments of shared behavior smaller than a
method.

Here's an example that might feel familiar:
```ruby
def count_ducks
  @count_ducks ||= DuckFlock.all.map(&size).inject(0, &:+)
end
```

This method is quite small, but it still complects the concerns of counting
ducks and of saving and reusing the result of a calculation, and that latter
concern might be repeated any number of times in your codebase.

With modifiers, we can encapsulate the implementation of the memoization, and
keep the intent:
```ruby
def count_ducks
  DuckFlock.all.map(&size).inject(0, &:+)
end
memoized :count_ducks
```

## Requirements

Behind the scenes, `modifiers` uses `Module#prepend`, so it requires Ruby
version 2.0.0 or higher.

If you have at least version 2.1.0, you can call them in-line with your method
definitions, which looks completely baller imo:
```ruby
# requires Ruby 2.1.0 or higher, cool kids only
memoized query def fetch_from_api(params)
  ApiFetcher.new(params).call
end
```

(All other code examples in this document work on 2.0.)

## Installation

Add this line to your application's Gemfile:

    gem 'modifiers', require: false

And then execute:

    $ bundle

## Usage

### built-in modifiers

#### memoized

Every now and then, you start to care how long it takes for a method to run.
You may find yourself wishing it just re-used some hard-won values, rather than
throwing them away and rebuilding them anew every time you call it.

(You may recognize the example from earlier, but this one is more complete.)

```ruby
require 'modifiers/memoized'

class DuckService
  extend Modifiers

  def count_ducks
    DuckFlock.all.map(&size).inject(0, &:+)
  end
  memoized :count_ducks
end
```

A method modified by `memoized` will run once normally, per unique combination
of arguments, after which it will simply return the same result for the
lifetime of the receiving object. Dazzle your friends with your terse, yet
performant, fibonnaci implementations!

(If you want all this and more, you can use
[memoist](https://github.com/matthewrudy/memoist) (formerly
`ActiveSupport::Memoizable`) instead, but I warn you: it involves `eval`.)

#### deprecated

Sometimes there's a method, and you want it to die, but not a clean, swift
death.  Instead, you wish it a slow, cursed strangulation, as collaborators
gradually abandon it.  Mark it with your sign, that all may know to shun it or
be punished.

```ruby
require 'modifiers/deprecated'

class BadHacks
  extend Modifiers

  def awful_method
    # some ugly hack, probably involving define_method and ObjectSpace
  end
  deprecated :awful_method
end
```

A method modified by `deprecated` will issue a helpful deprecation warning
every time it is called.  Something like: `deprecated method
BadHacks#awful_method called from app/controllers/ducks_controller.rb:782`

(Please note that the `deprecated` method is deprecated, and you should
definitely use `Gem.deprecate` instead.)

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

  def fullest_hutch
    hutches.max { |h1,h2| h1.count_eggs - h2.count_eggs }
  end
  query :fullest_hutch
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

### defining new modifiers

New modifiers can be defined in your own modules using the `define_modifier` method.

Let's start with the simplest case: the null modifier, with a name, but no behavior.

```ruby
require 'modifiers/define_modifier'

module DuckFarmModifiers
  extend Modifiers
  define_modifier(:duck) do |*args, &block|
    super(*args, &block)
  end
end

class DuckFarm
  extend DuckFarmModifiers
  def farm
    # raise, tend, cultivate
  end

  duck :farm # => unchanged
end
```

Much as with `define_method`, the first argument to `define_modifier` gives us
the name of the new modifier, and the block gives us the implementation of a
given *modification*: a method which intercepts calls to the original method
(in this case, `DuckFarm#farm`), does whatever it likes, then invokes the
original method using `super`.

(Sadly, just as with `define_method`, you have to use explicit arguments when
calling `super`.  Sorry, doing otherwise involved too much oddity.)

But maybe you don't want to call the original method at all!
```ruby
module DuckFarmModifiers
  define_modifier(:x) { }
end
```

Or maybe you don't want to call it with the same arguments!
```ruby
module DuckFarmModifiers
  define_modifier(:int) do |*args, &block|
    super(*args.map(&:to_i), &block)
  end
end

You can do things before, after, or even "around" the invocation.
```ruby
module DuckFarmModifiers
  define_modifier(:perf_logged) do |*args, &block|
    start = Time.now
    super(*args, &block)
    Rails.logger "#{self.class.name}##{__method__} finished in #{Time.now - start}s"
  end
end
```

### Extending modifiers

The body of a modifier will be evaluated in the context of the receiver
instance of the modified method, so you can refer to any other instance
methods.  However, given that you probably wrote your modifier to be used from
_any_ object, there isn't much you can rely on, so you may find yourself
writing everything you need right there in the method, resulting in a long and
ugly method body.

Luckily, there's a way out: if a given modification requires additional
behavior, simply pass a module with all the other methods you need as the
second argument to `define_modifier`.

```ruby
module DuckFarmModifiers
  module Gracefully
    private

    def logger
      Rails.logger
    end

    def log_exception(method_name, exception)
      logger.warn("#{method_name} raised #{exception}")
    end
  end

  define_modifier(:gracefully, Gracefully) do |*args, &block|
    super(*args, &block)
  rescue => e
    log_exception(__method__, e)
  end
end
```

## Contributing

1. [Fork it](https://github.com/nicknovitski/modifiers/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
