require 'modifiers/define_modifier'

module Modifiers
  define_modifier(:query) do |invocation|
    invocation.invoke(Marshal.load(Marshal.dump(self)))
  end
end
