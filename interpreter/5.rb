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
# factor  → primary ( ( "/" | "*" ) primary )*
# primary → NUMBER | "(" term ")"
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
    expr = primary

    while matches?("*", "/")
      operator = advance
      expr2 = primary

      expr = {type: :binary, operator:, left: expr, right: expr2}
    end

    expr
  end

  def primary
    if matches?(/\d/)
      number
    elsif matches?("(")
      token = advance # consume the "("
      raise "EOF" if token.nil?
      expr = term
      raise "Expected a closing parenthesis" unless advance == ")"
      expr
    elsif @tokens.empty?
      raise "EOF"
    else
      raise "Expected a number, got #{advance}"
    end
  end

  def number
    token = advance
    raise "EOF" if token.nil?
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
      .then { interpret(it) }
  end

  def self.tokenize(code) = Tokenizer.call(code)

  def self.parse(tokens) = Parser.call(tokens)

  def self.interpret(ast)
    case ast[:type]
    in :number
      ast[:value]
    in :binary
      left = interpret(ast[:left])
      right = interpret(ast[:right])

      left.send(ast[:operator], right)
    end
  end
end

if %w[0 no false].include?(ENV["TEST"])
  loop do
    print "> "
    input = gets
    break if input.nil?
    p Language.call(input)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
else
  # Parser tests
  assert_equal(
    "(+ 1 2)",
    to_s_expr(Language.parse(Language.tokenize("1 + 2")))
  )
  assert_equal(
    "(+ (- 1 2) 3)",
    to_s_expr(Language.parse(Language.tokenize("1 - 2 + 3")))
  )
  assert_equal(
    "(- 1 (/ (* 2 3) 4))",
    to_s_expr(Language.parse(Language.tokenize("1 - 2 * 3 / 4")))
  )
  assert_equal(
    "(- 1 (+ 2 3))",
    to_s_expr(Language.parse(Language.tokenize("1 - (2 + 3)")))
  )
  assert_raises("EOF") { Language.parse(Language.tokenize("1 +") )}
  assert_raises(/Expected a number, got a/) { Language.parse(Language.tokenize("a") )}
  assert_raises(/Expected a closing parenthesis/) { Language.parse(Language.tokenize("(1 + 2") )}
  assert_raises(/Expected a number, got \)/) { Language.parse(Language.tokenize(")") )}

  # Language tests
  assert_equal(3, Language.call("1 + 2"))
  assert_equal(-1, Language.call("1 - 2"))
  assert_equal(7, Language.call("1 + 2 * 3"))
  assert_equal(4, Language.call("8 / 2 + 0"))

  puts "✅ All tests pass"
end
