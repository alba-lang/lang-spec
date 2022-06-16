********************************************************************************
Records, Objects, ...
********************************************************************************






Inductive Data Types
================================================================================

.. code-block::

    type [red, green, blue]

    type Color := [red: Color, green: Color, blue: Color]

    type Color := [red, green, blue]

    case: type [red, green, blue] -> Int :=
        \ red := 0
        \ green := 1
        \ blue := 2

    char_to_color: Char -> type [red, green, blue] :=
        case \ 'r' := red
             \ _   := green


    type List (A: Any): Any := [[], (::): A -> List -> List]
        -- A recursive type needs a name, otherwise it cannot be used in
        -- constructor arguments.


    -- Tuple
    type Tuple (A B: Any): Any := (,): Tuple

    type (A B: Any): Any := (,)


    -- Either
    type (A B: Any): Any := [left A, right B] -- no indices, no named args

    type Either (A B: Any): Any := [left: A -> Either, right: A -> Either]


    -- Natural
    type N := [zero, succ N]        -- no indices, no named args
    type N := [zero, succ: N -> N]


    -- Order on natural numbers
    type le: Endorelation Natural :=
        start {n}:  le zero n
        next {n m}: le n m -> le (succ n) (succ m)
    -- type has indices, therefore no simple constructor types (result type must
    -- be present, i.e. ':' is mandatory and arguments can have names


Subtyping: An inductive type with more constructors is a subtype of one with a
subset of the constructors (same names and arguments).

The type ``type [red, green, blue]`` has the internal representation

.. code-block::

    type I: Any := [red: I, green: I, blue: I]
    -- The name 'I' is a local name.


Two algebraic types are the same if they have the same structure i.e. the same
parameters, constructor names and constructor types. The name of the type is
local.

For all inductive types there are terms which represent the type.

.. code-block::

    type (<=): Natural -> Natural -> Prop
    := [ start x: zero <= x
       , next x y: x <= y -> x <= succ y
       ]

    -- the same type with a different local name
    type le: Natural -> Natural -> Prop
    := [ start x: le zero x
       , next x y: le x y -> le x succ y
       ]

    -- or with layout syntax
    type le: Natural -> Natural -> Prop :=
        start x:  le zero x
        next x y: le x y -> le x succ y


Records
================================================================================


Records are labelled n-tuples (i.e the order matters).

.. code-block::

    record type [name: String, age: Natural]
