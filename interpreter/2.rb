require_relative "helper"

# https://craftinginterpreters.com/parsing-expressions.html#the-parser-class

def to_s_expr(expr)
  case expr[:type]
  in :number
    expr[:value].to_s
  in :binary
    "(#{expr[:operator]} #{to_s_expr(expr[:left])} #{to_s_expr(expr[:right])})"
  end
end


module Tokenizer
  def self.call(input)
    input.split
  end
end

# ```grammar
# program → term
# term    → NUMBER ("+" NUMBER)*
# ```

class Parser
  def initialize(tokens)
    @tokens = tokens
  end

  def call
    program
  end

  def program
    term
  end

  def term
    expr = number

    while matches?("+", "-")
      operator = advance
      expr2 = number

      expr = {type: :binary, operator:, left: expr, right: expr2}
    end

    expr
  end

  def number
    token = advance
    raise "EOF" if token.nil?
    raise "Expected a number, got #{token}" unless token.match?(/\A\d\z/)

    {type: :number, value: token.to_i}
  end

  private

  def matches?(*types)
    types.any? { it === @tokens.first }
  end

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

assert_equal(
  "(+ 1 2)",
  to_s_expr(Interpreter.call("1 + 2"))
)
assert_equal(
  "(+ (- 1 2) 3)",
  to_s_expr(Interpreter.call("1 - 2 + 3"))
)
assert_raises(/Expected a number, got a/) { Interpreter.call("a") }
assert_raises("EOF") { Interpreter.call("1 +") }

puts "All tests pass"
