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

class Parser2 < Parser

  # def factor
  #   expr = primary

  #   while matches?("*", "/")
  #     operator = advance
  #     expr2 = primary

  #     if operator == "+" && expr[:type] == :number && expr2[:type] == :number
  #       expr = {type: :number, value: expr[:value] + expr2[:value]}
  #     else
  #       expr = {type: :binary, operator:, left: expr, right: expr2}
  #     end
  #   end

  #   expr
  # end
end

module Compiler
  def self.call(ast)
    instructions = []

    case ast[:type]
    in :number
      instructions += [[:putobject, ast[:value]]]
    in :binary
      instructions += call(ast[:left])
      instructions += call(ast[:right])
      instructions += [[:send, ast[:operator]]]
    end

    instructions
  end
end

module VM
  def self.call(instructions)
    stack = []

    instructions.each do |instruction|
      case instruction
      in [:putobject, value]
        stack.push(value)
      in [:send, operator]
        right = stack.pop
        left = stack.pop
        result = left.send(operator, right)
        stack.push(result)
      end
    end

    stack.pop
  end
end

module Compiler2
  def self.call(ast)
    instructions = []

    case ast[:type]
    in :number
      instructions += [[:putobject, ast[:value]]]
    in :binary
      if ast[:operator] == "+" && ast[:left][:type] == :number && ast[:right][:type] == :number
        instructions += [[:putobject, ast[:left][:value] + ast[:right][:value]]]
      else
      instructions += call(ast[:left])
      instructions += call(ast[:right])
      instructions += [[:send, ast[:operator]]]
    end
    end

    instructions
  end
end

module VM2
  def self.call(instructions)
    stack = []

    instructions.each do |instruction|
      case instruction
      in [:putobject, value]
        stack.push(value)
      in [:send, operator]
        right = stack.pop
        left = stack.pop
        result = left.send(operator, right)
        stack.push(result)
      end
    end

    stack.pop
  end
end

module Language
  def self.call(code)
    tokenize(code)
      .then { parse(it) }
      .then { compile(it) }
      .then { run(it) }
  end

  def self.tokenize(code) = Tokenizer.call(code)
  def self.parse(tokens)  = Parser.call(tokens)
  def self.compile(ast)   = Compiler.call(ast)
  def self.run(bytecode)  = VM.call(bytecode)
end

module Language2
  def self.call(code)
    tokenize(code)
      .then { parse(it) }
      .then { compile(it) }
      .then { run(it) }
  end

  def self.tokenize(code) = Tokenizer.call(code)
  def self.parse(tokens)  = Parser2.call(tokens)
  def self.compile(ast)   = Compiler2.call(ast)
  def self.run(bytecode)  = VM2.call(bytecode)
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
    to_s_expr(Language2.parse(Language2.tokenize("1 + 2")))
  )
  assert_equal(
    "(+ (- 1 2) 3)",
    to_s_expr(Language2.parse(Language2.tokenize("1 - 2 + 3")))
  )
  assert_equal(
    "(- 1 (/ (* 2 3) 4))",
    to_s_expr(Language2.parse(Language2.tokenize("1 - 2 * 3 / 4")))
  )
  assert_equal(
    "(- 1 (+ 2 3))",
    to_s_expr(Language2.parse(Language2.tokenize("1 - (2 + 3)")))
  )
  assert_raises("EOF") { Language2.parse(Language2.tokenize("1 +") )}
  assert_raises(/Expected a number, got a/) { Language2.parse(Language2.tokenize("a") )}
  assert_raises(/Expected a closing parenthesis/) { Language2.parse(Language2.tokenize("(1 + 2") )}
  assert_raises(/Expected a number, got \)/) { Language2.parse(Language2.tokenize(")") )}

  # VM instructions tests
  assert_equal([[:putobject, 1]], Language2.compile(Language2.parse(Language2.tokenize("1"))))
  assert_equal([[:putobject, 3]], Language2.compile(Language2.parse(Language2.tokenize("1 + 2"))))

  # Language2 tests
  assert_equal(-1, Language2.call("1 - 2"))
  assert_equal(7, Language2.call("1 + 2 * 3"))
  assert_equal(3, Language2.call("8 / 3 + 1"))

  puts "✅ All tests pass"

  puts "🔬 Benchmarking..."

  require "benchable"

  # Benchable.bench(:ips, time: 10) do
  #   bench "Normal dispatch" do
  #     Language.call("1 + 2")
  #   end

  #   bench "Fast-path" do
  #     Language2.call("1 + 2")
  #   end
  # end

  Benchable.bench(:ips, time: 10) do
    bench "Slow path" do
      Language2.call("1 - 2")
    end

    bench "Fast-path" do
      Language2.call("1 + 2")
    end
  end
end
