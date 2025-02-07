require_relative "helper"

module Tokenizer
  def self.call(input)
    input.split
  end
end

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def call
    program
  end

  def program
    expr = number

    if matches?(/\+/)
      @tokens.shift
      expr2 = program
    end
  end

  def number
    token = @tokens.shift
    raise "Expected a number, got #{token}" unless token.match?(/\A\d\z/)

    {type: :number, value: token.to_i}
  end

  private

  def matches?(type)
    type === @tokens.first
  end
end

module Interpreter
  def self.call(input)
    tokens = Tokenizer.call(input)
    Parser.new(tokens).call
  end
end

assert_equal({type: :number, value: 1}, Interpreter.call("1"))
assert_raises(/Expected a number, got a/) { Interpreter.call("a") }

puts Interpreter.call("1 + 1 + 2")
# assert_equal({}, Interpreter.call("1 + 1 + 2"))
puts Interpreter.call("1 + 1")
# assert_equal({}, Interpreter.call("1 + 1"))
puts Interpreter.call("")
# assert_raises("", Interpreter.call(""))
puts Interpreter.call("1 +")
# assert_raises("", Interpreter.call("1 +"))

puts "All tests pass"
