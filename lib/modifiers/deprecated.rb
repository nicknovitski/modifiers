require 'modifiers/define_modifier'

module Modifiers
  define_modifier(:deprecated) do |invocation|
    warn "deprecated method #{invocation.method_identifier} called from #{invocation.location.join(':')}"
    invocation.invoke
  end
end
