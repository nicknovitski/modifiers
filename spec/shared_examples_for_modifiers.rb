RSpec.shared_examples 'a modifier' do |modifier|
  let(:test_class) do
    Class.new do
      extend Modifiers

      def public_method(arg = :foo)
        arg
      end

      protected

      def protected_method
        #
      end

      private

      def private_method
        #
      end
    end
  end
  subject(:instance) { test_class.new }

  it 'does not change the return value of the method' do
    test_class.send(modifier, :public_method)
    expect(instance.public_method).to be :foo
    expect(instance.public_method(:bar)).to be :bar
  end

  it 'does not change the visibility of a private method' do
    test_class.send(modifier, :private_method)
    expect(instance.private_methods).to include(:private_method)
  end

  it 'does not change the visibility of a protected method' do
    test_class.send(modifier, :protected_method)
    expect(instance.protected_methods).to include(:protected_method)
  end
end
