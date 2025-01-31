# Ruby Internals: A Guide for Rails Developers

## Introduction

Have you ever wondered "How does Ruby work?".

## Parsing

### Lexer

- Make connection with how we parse sentence when reading
- Recursive descent parser
- Prism

Impact:
  - Better error messages
  - unified tooling (Rubocop, packwerk, LSP, etc)
  - Better IDE support via LSP

## VM

How do we go from a AST to code running on the CPU?

vm lock GVL/GVM: why do we have it? What are the tradeoffs?
  - Mention Threads, Fibers, and how they never run in parallel
  - Mention Ractors, the only way to run CRuby code in parallel (link to previous talk)

> impact of local vs. instance variables vs methods calls, the performance hits
> of metaprogramming, and understand how object shapes impact memory efficiency.

https://railsatscale.com/2023-10-24-memoization-pattern-and-object-shapes/

Impact:
  - When performance is important, you can make better decisions about how to
    write your code.
  - Understand the pros and cons of different ways of writing code.

## YJIT

Just-in-time compiler for CRuby

Impact:
  - Faster rails apps:
    - Who doesn't love that? You should get around 10-30% speedup without any
      changes to your code.
    - Better for your users.
    - TODO: Get benchmarks for this (Hey, Discourse, Lobsters, etc)
  - YJIT works best when code doesn't have to jump between Ruby and C. The
    recent impact of this was porting code from C to Ruby. This makes it a lot
    easier to write and to maintain. Not a lot of us know C, but we all know
    Ruby and can contribute back to CRuby. A lot easier to fix bugs and add new
    features.

## The people behind this

Thank the core team for their work in making Ruby better for us, so we can make
softare that makes the world a better place.
