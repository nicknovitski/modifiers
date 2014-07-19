APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$LOAD_PATH << File.join(APP_ROOT, 'lib')

require 'shared_examples_for_modifiers'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
