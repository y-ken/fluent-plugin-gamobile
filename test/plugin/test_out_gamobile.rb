require 'helper'

class GamobileOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    ga_account MO-1234567-1
    set_var    agent
  ]

  def create_driver(conf=CONFIG,tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::GamobileOutput, tag).configure(conf)
  end

  def test_configure
    assert_raise(Fluent::ConfigError) {
      d = create_driver('')
    }
    d = create_driver %[
      ga_account MO-1234567-1
      set_var    agent
    ]
    d.instance.inspect
    assert_equal 'MO-1234567-1', d.instance.ga_account
    assert_equal 'agent', d.instance.set_var
  end

  def test_emit
    d1 = create_driver(CONFIG, 'input.access')
    time = Time.parse("2012-01-02 13:14:15").to_i
    d1.run do
      d1.emit({'message' => 'sample message'})
    end
    emits = d1.emits
    assert_equal 0, emits.length
  end
end

