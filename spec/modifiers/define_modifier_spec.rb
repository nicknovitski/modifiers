require 'spec_helper'
require 'modifiers/define_modifier'

module MyModifier
  extend Modifiers
  define_modifier(:bro) do |*args, &block|
    super(*args, &block) + ', bro'
  end

  module Watch
    private

    def timestamp
      Time.now
    end
  end

  define_modifier(:timed, Watch) do |*args, &block|
    super(*args, &block) + "(#{__method__} called at #{timestamp})"
  end
end

class Foo
  extend MyModifier

  def hello(name = 'world')
    "hello, #{name}"
  end
  bro :hello

  def poot
   "I accidentally typed the name of this method but I think it's great"
  end
  timed :poot
end

RSpec.describe Modifiers do
  describe '.define_modifier' do
    it 'can make new modifiers in new modules' do
      expect(Foo.new.hello('modified')).to eq('hello, modified, bro')
    end

    it 'can include helper modules' do
      expect(Foo.new.poot).to match(/\(poot called at/)
    end
  end
end
