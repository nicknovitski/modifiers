require 'spec_helper'
require 'modifiers/memoized'

RSpec.describe Modifiers do
  class Service
    def self.expensive_operation
      'done'
    end
  end

  class Client
    extend Modifiers
    def call_service
      Service.expensive_operation
    end
    memoized :call_service
  end

  subject(:client) { Client.new }

  describe '#memoized' do
    it_behaves_like 'a modifier', :memoized

    it 'prevents execution after the first time' do
      expect(Service).to receive(:expensive_operation).once

      subject.call_service
      subject.call_service
    end
  end
end
