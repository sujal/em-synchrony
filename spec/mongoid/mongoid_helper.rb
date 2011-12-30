require 'rubygems'
require 'rspec'
require 'pp'

require 'spec/helper/tolerance_matcher'

require 'mongoid'
require 'lib/em-synchrony'

def now(); Time.now.to_f; end

RSpec.configure do |config|
  config.include(Sander6::CustomMatchers)
end

require 'em-synchrony/mongoid'

MODELS = File.join(File.dirname(__FILE__), "app/models")
$LOAD_PATH.unshift(MODELS)

Dir[ File.join(MODELS, "*.rb") ].sort.each do |file|
  name = File.basename(file, ".rb")
  autoload name.camelize.to_sym, name
end


