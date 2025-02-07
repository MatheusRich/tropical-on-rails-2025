# Parsing

## Introduction

> If you don't know how compilers work, then you don't know how computers work. - Steve Yegge (Check)

To understand how Ruby works, let's think about how _we_ read text.

> Ruby: A Programmer's Best Friend

When I this, I startfrom left to right, top to bottom. My brain automatically
splits the sentence by space into words. It also pays attention to the accents and ponctuation.

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

While this sentence follow grammar rules, it doesn't make sense.

With programming it's the same thing.
