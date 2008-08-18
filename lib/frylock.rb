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
      @cmd = case cmd
      when Symbol
        cmd = cmd.to_s
      else
        cmd
      end
      @b = b
    end
    
    def call(argv)
      found = false
      argv.each_with_index { |a,i| found = i and break if @cmd === a }
      if found
        range = if @b.arity > 0
          (found + 1)..(found + @b.arity)
        else
          found + 1
        end
        @b.call(*argv[range])
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
