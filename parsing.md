# Parsing

## Introduction

> If you don't know how compilers work, then you don't know how computers work. - Steve Yegge

To understand how Ruby works, let's think about how _we_ read text.

> Ruby: A Programmer's Best Friend

When I this, I startfrom left to right, top to bottom. My brain automatically
splits the sentence by space into words. It also pays attention to the accents and punctuation.

```rb
tokens = %w[Ruby : A Programmer ' s Best Friend]
```

That happens super fast, and automatically. When it comes to understand its
meaning, we use the tokens and see their relation and structure.

For example, the colon lets me know that the word "Ruby" is the subject of the
sentence, and what comes after that is describing it.

the `'s` tells me that what comes after (best friend) is a possessive of the
previous word (programmer). etc

But note that not everything that is correct grammatically makes sense. For
example:

> Colorless green ideas sleep furiously

While this sentence follow grammar rules, it doesn't make sense. ALthough some
might argue that it sounds poetic, thus having a meaning. That's a topic for a
different discussion.

With programming it's the same thing. The computer will read your sentence
(code), split it into tokens, check their structure and relation, and interpret
their meaning (or error if it doesn't make sense).

```rb
def meaning_of = 42
puts meaning_of(:life, :universe, :everything)
```

---

So there are 3 steps to this process:

1. **Lexing**: Splitting the code into tokens
2. **Parsing**: Checking the structure and relation of the tokens
3. **Interpretation/Execution**: Understanding the meaning of the code and running it

In Ruby, that's roughly divided like this

1. Lexer & Parsing: Prism
2. Interpretation/Compilation: YARV (vm)
3. Execution: YARV (vm) + YJIT

---

Let's imagine a simple language. It only let's you write numbers.

```rb
program → NUMBER

NUMBER  → 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
```

This is the grammar. It tells us that a program is a number, and a number is any
digit from 0 to 9.

So this program is valid:

```rb
5
```

and this one is not:

```rb
hello
```

Let's make it a bit more interesting by adding addition:

```rb
program → NUMBER
        | sum

sum     → NUMBER "+" NUMBER
```

That let's us sum two numbers. Let's change it to allow any number of sums:

```rb
program → NUMBER
        | NUMBER "+" program
```
