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

# ```rb
# program → term
# term    → factor ( ( "+" | "-" ) factor )*
# factor  → primary ( ( "/" | "*" ) primary )*
# primary → NUMBER | "(" term ")"
# NUMBER  → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
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
    if matches?(/\A\d\z/)
      number
    elsif matches?("(")
      token = advance # consume the "("
      raise "EOF" if token.nil?
      expr = term
      raise "Expected a closing parenthesis" unless advance == ")"
      expr
    elsif advance.nil?
      raise "EOF"
    else
      binding.irb
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
    # return if @tokens.empty?
    @tokens.shift
  end
end

module Interpreter
  def self.call(input)
    tokens = Tokenizer.call(input)
    Parser.new(tokens).call
  end
end

if %w[0 no false].include?(ENV["TEST"])
  loop do
    print "> "
    input = gets
    break if input.nil?
    p Interpreter.call(input)
  rescue => e
    puts "#{e.class}: #{e.message}"
  end
else
  # assert_equal(
  #   "(+ 1 2)",
  #   to_s_expr(Interpreter.call("1 + 2"))
  # )
  # assert_equal(
  #   "(+ (- 1 2) 3)",
  #   to_s_expr(Interpreter.call("1 - 2 + 3"))
  # )
  # assert_equal(
  #   "(- 1 (/ (* 2 3) 4))",
  #   to_s_expr(Interpreter.call("1 - 2 * 3 / 4"))
  # )
  # assert_equal(
  #   "(- 1 (+ 2 3))",
  #   to_s_expr(Interpreter.call("1 - ( 2 + 3 )"))
  # )
  # assert_raises("EOF") { Interpreter.call("1 +") }
  assert_raises(/Expected a number, got a/) { Interpreter.call("a") }
  # assert_raises(/Expected a closing parenthesis/) { Interpreter.call("(1 + 2") }

  puts "All tests pass"
end
