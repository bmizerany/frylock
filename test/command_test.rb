require File.dirname(__FILE__) + "/../lib/frylock"
require "rubygems"
require "test/spec"
require "mocha"

class Test::Unit::TestCase
  def test_command(cmd, argv, &b)
    Frylock::Command.new(cmd, &b).call(argv)
  end
end

Frylock.run = false

context "command" do
  
  setup { @mock = mock() }
  
  specify "should know a symbol is the full command name" do
    @mock.expects(:called).with()
    test_command(:foo, ['foo']) { @mock.called }
  end
  
  specify "should know only send params needed by block" do
    @mock.expects(:called).with('bar')
    test_command(:foo, ['foo', 'bar']) { |a| @mock.called(a) }
  end

  specify "should know only send params needed by block 2" do
    @mock.expects(:called).with('bar', 'baz')
    test_command(:foo, ['foo', 'bar', 'baz']) { |a,b| @mock.called(a,b) }
  end
  
end
