.. _Functions:

************************************************************
Functions
************************************************************



Anonymous Functions
============================================================

An anonymous function is an expression of the form ::

    \ <telescope>: <type> := <expression>

    -- Examples:
    \ x := x + 1

    \ (x: ℕ): ℕ := x + 1

Type annotations in the :ref:`telescope <Telescopes>` are optional. The result
type is optional as well. The types will be inferred by the compiler from the
context. If the compiler cannot infer the types, it asks the user to add type
annotations.




Named Functions
============================================================

An named function has the form ::

    <name> <telescope>: <type> := <expression>

    -- Examples:
    increment x := x + 1

    increment (x: ℤ): ℤ := x + 1

Named functions can be used in :ref:`local definitions <Local Definitions>` or
top level definitions.




Recursive Functions
============================================================


Recursive functions are named functions where the function is used inside the
defining expression. Usually the defining expression is a :ref:`pattern match
<Pattern Match>` expression. The definition of a recursive function has the
form::

    name <params>: all <indices>: <type> := case
        \ p₁₁ p₁₂ ... := e₁
        \ p₂₁ p₂₂ ... := e₂
        ...

where ``<params>`` and ``indices`` are :ref:`telescopes <Telescopes>` and some
of the defining expressions ``e₁, e₂, ...`` contain a call to ``name``.

In a recursive function we distinguish between parameter arguments and index
arguments. If the body of the function is a pattern match expression as shown
above, then pattern match can happen only on index arguments.

Inside the body we can use ``name`` with the type ``name: all <indices>:
<type>`` i.e. there is no need to use the parameter arguments in the recursive
calls.

The pattern match happens on the index arguments. There must be one index
argument which is used in all recursive calls only structurally smaller than the
original index argument.

Example::

    append {A: Any}: List A → List A → List A := case
        \ []        b   := b
        \ (h :: t)  b   := h :: (append t b)

        -- 't' is structurally smaller than 'h :: t'.
        -- The first index argument is decreasing.
        -- 'append t b' is a legal recursive call.

    -- Illegal recursive call
    append {A: Any}: List A → List A → List A := case
        \ []        b   := b
        \ a         b   := append a b   -- <-- ILLEGAL




Mutually Recursive Functions
============================================================

A collection of functions can be mutually recursive ::

    mutual <common-params> :=
        name₁ <params₁>: all <indices₁>: <type₁> := case
            ...
            ...

        name₂ <params₂>: all <indices₂>: <type₂> := case
            ...
            ...

Example::

    class Tree (A: Any) :=
        node: A → List Tree → Tree


    mutual {A: Any} :=
        flipTree: Tree A → Tree A := case
            \ (node a f) :=
                node a (flipChildren f)
        -- 'f' is structurally smaller than 'node a f'

        flipChildren: List (Tree A): List (Tree A) := case
            \ [] :=
                []
            \ (t :: f) :=
                flipChildren f + [flipTree t]
        -- 'f' is structurally smaller than 't :: f'
        -- 't' is structurally smaller than 't :: f'

With mutally recursive functions there is the same rule that each of the
mutually recursive functions must have one index argument which is structurally
decreasing on each call of one of the mutually recursive functions.
