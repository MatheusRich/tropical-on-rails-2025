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
    input.scan(%r{[A-Za-z0-9]+|[+\-*/=()]})
  end
end

# ```rb
# program → term
# term    → factor ( ( "+" | "-" ) factor )*
# factor  → NUMBER ( ( "/" | "*" ) NUMBER )*
# NUMBER  → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
# ```
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
    term
  end

  def term
    expr = factor

    while matches?("+", "-")
      operator = advance
      expr2 = factor

      expr = {type: :binary, operator:, left: expr, right: expr2}
    end

    expr
  end

  def factor
    expr = number

    while matches?("*", "/")
      operator = advance
      expr2 = number

      expr = {type: :binary, operator:, left: expr, right: expr2}
    end

    expr
  end

  def number
    token = advance
    raise "EOF" if token.nil?
    if !token.match?(/\d/)
      raise "Expected a number, got #{token}"
    end

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

module Language
  def self.call(code)
    tokenize(code)
      .then { parse(it) }
  end

  def self.tokenize(code) = Tokenizer.call(code)

  def self.parse(tokens) = Parser.call(tokens)
end

# assert_equal({type: :number, value: 1}, Language.call("1"))
# assert_raises(/Expected a number, got a/) { Language.call("a") }

assert_equal(
  "(+ 1 2)",
  to_s_expr(Language.call("1 + 2"))
)
assert_equal(
  "(+ (- 1 2) 3)",
  to_s_expr(Language.call("1 - 2 + 3"))
)
assert_equal(
  "(- 1 (/ (* 2 3) 4))",
  to_s_expr(Language.call("1 - 2 * 3 / 4"))
)
assert_raises("EOF") { Language.call("1 +") }
assert_raises(/Expected a number, got a/) { Language.call("a") }
assert_raises("EOF") { Language.call("1 +") }

puts "✅ All tests pass"
