require_relative "helper"

module Tokenizer
  def self.call(input)
    input.scan(%r{[A-Za-z0-9]+|[+\-*/=()]})
  end
end

class Parser
  def self.call(tokens)
    new(tokens).call
  end

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
    unless token.match?(/\d/)
      raise "Expected a number, got #{token}"
    end

    {type: :number, value: token.to_i} # only integers!
  end

  private

  def advance
    @tokens.shift
  end
end

module Language
  def self.call(code)
    tokenize(code)
      .then { parse(it) }
  end

  def self.tokenize(code) = Tokenizer.call(code)

  def self.parse(tokens) = Parser.call(tokens)
end

assert_equal({type: :number, value: 1}, Language.call("1"))
assert_raises(/Expected a number, got a/) { Language.call("a") }
assert_raises(/EOF/) { Language.call("") }

puts "All tests pass"
