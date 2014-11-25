require 'spec_helper'
require 'modifiers/command'

RSpec.describe Modifiers do
  class Doer
    extend Modifiers
    def take_action
      # lots of side-effectful-operations
      2 + 2
    end
    command :take_action
  end

  subject(:doer) { Doer.new }

  describe '#command' do
    it_behaves_like 'a modifier', :command, changes_return_value: true

    it 'causes the method to always return the receiver' do
      expect(doer.take_action).to be doer
    end
  end
end
