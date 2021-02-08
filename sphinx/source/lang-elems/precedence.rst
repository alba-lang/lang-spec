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

An operator expression has the form ::

    a o₁ b o₂ c o₃ d o₃ ...

where each operand *a*, *b*, ... can be an atomic expression prefixed by an
arbitrary number of operators.

We can generate a parse tree by the recursive algorithm
::

    parse (a o b) :=
        (a o b)

    parse (a o₁ b o₂ ...) :=
        if o₁ > o₂ then
            parse ((a o₁ b) o₂ ...)
        else
            parse (a o₁ (parse (b o₂ ...)))

    MISSING: Prefix operators!!


The algorithm terminates, because each parse reduces the length of the operator
expression (and increases the depth).
