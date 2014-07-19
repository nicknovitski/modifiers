require 'modifiers/define_modifier'
module Modifiers
  define_modifier(:deprecated) do |method, *args|
    caller[2] =~ /(.*?):(\d+).*?$/i
    method_id = self.class.to_s + '#' + method.name.to_s
    location = [$1, $2].join(":")
    warning = "deprecated method #{method_id} called from #{location}"
    warn warning
    method.call(*args)
  end
end
