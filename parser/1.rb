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
    number
  end

  def number
    token = advance
    raise "EOF" if token.nil?
    raise "Expected a number, got #{token}" unless token.match?(/\A\d\z/)

    {type: :number, value: token.to_i}
  end

  private

  def advance
    @tokens.shift
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
assert_raises(/EOF/) { Interpreter.call("") }

puts "All tests pass"
