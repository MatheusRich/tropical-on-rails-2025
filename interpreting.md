https://www.youtube.com/watch?v=ySuMOEVLaMw&t=2s
https://www.youtube.com/live/6loKD2LXxbc?si=EVAF5Cq9JZtKhXoD&t=826

# Interpreting the AST directly

With the AST at hand, we can interpret it to run our program. TO do that is
really simple, we just need to check the type of each node and run the appropriate
code.

```rb
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
```

There you go. We just built a very simple interpreter!

![](./interpreting-ruby-1.8.png)

This is exactly how Ruby <= 1.8 worked. Let's check some examples from the source code directly

```c
// eval.c
static VALUE
rb_eval(self, n)
    VALUE self;
    NODE *n;
{
  switch (nd_type(node)) {
    // ...
    case NODE_LIT:
      result = node->nd_lit;
      break;
    // ...
  }
}
```

## Considerations

- Simple, but slow
  - https://craftinginterpreters.com/chunks-of-bytecode.html#why-not-walk-the-ast
- How RUby <= 1.8 worked
- https://github.com/MatheusRich/ruby/blob/f48ae0d10c5b586db5748b0d4b645c7e9ff5d52e/eval.c#L2982

# Compiling

- How AST becomes bytecode
https://github.com/MatheusRich/ruby/blob/7178593558080ca529abb61ef27038236ab2687d/prism_compile.c#L242

![](./interpreting-ruby-1.9.png)

# Interpreting bytecode

- Executing bytecode
