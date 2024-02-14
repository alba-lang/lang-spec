.. _Pattern_match:

********************************************************************************
Pattern Match
********************************************************************************


.. code::

    case( f: F, [c1,...,cn], t)                 -- case tree t

    F = all (x1: A1) ... (xm: Am): R            -- type

    ci = (Delta, [p1: P1, ... , pm: Pm], e: E)  -- ith clause

    Delta = [y1: B1, ....]                      -- pattern variables


.. code::

    -- Pattern
    p   ::=     x                   -- variable
        |       x := c              -- constant
        |       x := C q ... p ...  -- constructor with parameter
                                    -- and index arguments


The type of a pattern match expression is a function type. Implicit arguments
are ghost arguments (i.e. not present in the runtime). The can be used in
pattern only if the result type ``R`` is a proposition.

Each pattern variable corresponds to a node in the case tree.




.. code::

    leInvers {a b: Nat}: succ a <= succ b -> a <= b :=
        case
        \ next {a} {b} le := le
