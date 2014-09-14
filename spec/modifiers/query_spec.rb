require 'spec_helper'
require 'modifiers/query'

RSpec.describe Modifiers do
  class Test
    extend Modifiers

    def initialize(sub_test = nil)
      @sub_test = sub_test
      @enum = []
    end

    attr_reader :memo, :enum

    query def fooer?
      @memo ||= true
    end

    query def insertable?(val)
      @enum << val
    end

    query def child_status
      @sub_test.status
    end
  end

  class SubTest
    def initialize
      @state_changes = []
    end
    def status
      @state_changes << :awake
    end
  end

  let(:child) { SubTest.new }
  subject(:instance) { Test.new(child) }

  describe '#query' do
    it_behaves_like 'a modifier', :query

    it "prevents the method from changing the object's instance variables" do
      expect { subject.fooer? }.not_to change { subject.memo }
    end

    it 'prevents the method from altering arrays' do
      expect { subject.insertable?(:foo) }.not_to change { subject.enum }
    end

    it 'prevents the method from altering linked objects' do
      expect { instance.child_status }.not_to change { child.instance_variable_get(:@state_changes) }
    end
  end
end
