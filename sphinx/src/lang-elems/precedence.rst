.. _Precendence and Associativity:

************************************************************
Precedence and Associativity
************************************************************

In order to parse and pretty print expressions in a non ambiguous manner we
attach to some language symbols and all operators a precedence and an
associativity. Associativity can be either *left*, *right* or *nonassoc*.

For expressions like ``a o₁ b o₂ c`` where the operators ``o₁`` and ``o₂``
have the same precedence, but different associativity, the operator with left
associativity gets higher precedence.

For two subsequent operators in an operator expression one of the operators has
always higher precedence. If the numerical precendece is the same, the
associativity decides. Left associativity of the first gives the first a higher
precedence. Right associativity of the first gives the first a lower precedence.

There are the following precedence levels from lowest to highest with some
example operators/symbols:


+-----------------+--------------+-------------------+---------------+
|  level          |  left        |       right       |  noassoc      |
+-----------------+--------------+-------------------+---------------+
|  where          |              |                   |               |
+-----------------+--------------+-------------------+---------------+
|  comma          |              |  ,                |               |
+-----------------+--------------+-------------------+---------------+
|  assign         |              |  λ :=             |               |
+-----------------+--------------+-------------------+---------------+
|  colon          |              |  all  :           |               |
+-----------------+--------------+-------------------+---------------+
|  arrow          |              |  → =              |               |
+-----------------+--------------+-------------------+---------------+
|  or             |              |  \\/ ∨ or         |               |
+-----------------+--------------+-------------------+---------------+
|  and            |              |  /\\ ∧ and        |               |
+-----------------+--------------+-------------------+---------------+
|  not            |              |                   | ¬ Not not     |
+-----------------+--------------+-------------------+---------------+
|  apply          | \|>          | <\|               |               |
+-----------------+--------------+-------------------+---------------+
|  composition    | >>           | <<                |               |
+-----------------+--------------+-------------------+---------------+
|  relation       |              |                   |  = ≤ < ...    |
+-----------------+--------------+-------------------+---------------+
|  add            | \+ \-        |                   |               |
+-----------------+--------------+-------------------+---------------+
|  mult           | \* / mod     |                   |               |
+-----------------+--------------+-------------------+---------------+
|  exp            |              | ^                 |               |
+-----------------+--------------+-------------------+---------------+
|  application    |  f a b c ..  |                   |               |
+-----------------+--------------+-------------------+---------------+


Some examples of expressions and the corresponding parsing::

    expression                          parsed as

    a + b + c                           (a + b) + c

    - a + b                             (- a) + b

    - a * b                             - (a * b)

    x |> f |> g                         (x |> f) |> g

    f <| g <| x                         f <| (g <| x)

    x |> f <| y                         (x |> f) <| y

    x |> f >> g                         x |> (f >> g)

    a :: b :: c                         a :: (b :: c)

    A : B : C                           A : ( B : C)

    λ x := a, b                         (λ x := a), b
    --                                  comma < assign

    λ x := a : T                        λ x := (a: T)
    --                                  assign < colon

    all x: T, e                         (all x: T), e
    --                                  comma < colon

    all y: T → U                        all y: (T → U)
    --                                  colon < arrow
