require 'chefspec'
require 'chefspec/berkshelf'

# Generate a report
ChefSpec::Coverage.start!

RSpec.configure do |c|
  c.color     = true
  c.formatter = :documentation
end
