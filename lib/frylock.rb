module Frylock
  extend self
  
  FORWARDED_METHODS = %w(command)
  
  def command(cmd, &b)
    @commands << Command.new(cmd, &b)
  end
  
  def run!(argv)
    (@commands || []).each { |c| c.call(argv) }
  end
  
  def run
    @run || true
  end
  
  def run=(v)
    @run = v
  end
  
  class Command
    def initialize(cmd, &b)
      @cmd = cmd
      @cmd = cmd.to_s if cmd.kind_of?(Symbol)
      @b = b
    end
    
    def call(argv)
      if @cmd === argv[0] && (@b.arity == -1 || argv.size - 1 == @b.arity)
        @b.call(*argv[1..-1])
      end
    end
  end
  
end

Frylock::FORWARDED_METHODS.each do |m|
  eval(<<-end_eval, binding, "(Frylock)", __LINE__)
    def #{m}(*args, &b)
      Frylock.#{m}(*args, &b)
    end
  end_eval
end

at_exit { Frylock.run!(ARGV) }
