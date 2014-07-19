require 'modifiers/define_modifier'

module Modifiers
  class Deprecation < Modification
    def warning(invocation)
      "deprecated method #{method_identifier} called from #{invocation.location.join(":")}"
    end
  end

  define_modifier(:deprecated, Deprecation) do |invocation, modification|
    warn modification.warning(invocation)
    invocation.invoke
  end
end
