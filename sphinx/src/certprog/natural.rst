********************************************************************************
Natural Numbers
********************************************************************************





Basic Definitions
================================================================================

.. code::

    type Nat :=
        zero: Nat
        succ: Nat -> Nat

    one: Nat := succ zero

    (+): Nat -> Nat -> Nat := case
        \ zero, b     := b
        \ succ n, b   := succ (n + b)

    (*): Nat -> Nat -> Nat := case
        \ zero, _     := zero
        \ succ n, b   := b + n * b

    (^): Nat -> Nat -> Nat := case
        \ a,  zero    := one
        \ a,  succ n  := a * a^n


    type (<=): Nat -> Nat -> Prop :=
        start {n}: zero <= n
        next  {n m}: n <= m  ->  succ n <= succ m

    (<) (a b: Nat): Prop :=
        succ a <= b





Properties of Addition
================================================================================


.. code::

    pullSucc: all {a b: Nat}: a + succ b = succ (a + b) := case
        \ {zero},   {b} := same
        \ {succ n}, {b} := map succ pullSucc


    zeroRightNeutral: all {a: Nat}: a + zero = a := case
        \ {zero}   := same
        \ {succ n} := map succ zeroRightNeutral


    plusCommutes: all {a b: Nat}: a + b = b + a := case
        \ {zero},   {b}   := zeroRightNeutral
        \ {succ n}, {b}   := (mapEquals plusCommutes, flip pullSucc)


    plusAssociates: all {a b c: Nat}: (a + b) + c = a + (b + c)
    := case
        \ {zero},   {b}, {c} := same
        \ {succ n}, {b}, {c} := mapEquals plusAssociates





Properties of Multiplication
================================================================================

Multiplication distributes over addition. In order to prove this we need a
helper theorem.


.. code::

    plusSwap: all {a b c: Nat}: a + (b + c) = b + (a + c)
    :=
        ( plusAssociates
        , replace { \ x := x + c } plusCommutes
        , flip plusAssociates
        )


Having ``plusSwap`` we can prove the distributivity of multiplication.

.. code::

    timesDistributes: all {a b c: Nat}: a * (b + c)  =  a * b + a * c
        -- Multiplication distributes over addition
    := case
        \ {zero},    {b},   {c} := same
        \ {succ n},  {b},   {c} :=
            -- goal: (b + c) + n * (b + c)  =  (b + n * b) + (c + n * c)
            ( flip plusAssociates
                : _  =  b + (c + n * (b + c))
            , replace {\ x := _ + (_ + x)} timesDistributes
                : _  =  b + (c + (n * b + n * c))
            , replace {\ x := _ + x} plusSwap
                : _  =  b + (n * b + (c + n * c))
            , plusAssociates
                : _  =  (b + n * b) + (c + n * c)
            )



Properties of Order
================================================================================

.. code::

    leReflexive: all {a: Nat}: a <= a
        -- The less equal relation is reflexive
    := case
        \ {zero}      :=  start
        \ {succ n}    :=  next leReflexive


    leSucc: all {a: Nat}: a <= succ a
        -- All numbers are less or equal their successors
    := case
        \ {zero}      := start
        \ {succ n}    := next leSucc


    zeroLeast: all {a: Nat}: a <= zero  ->  a = zero
        -- All numbers less or equal 'zero' are 'zero'
    := case
        \ start := same
        -- The case 'next' is not possible!


    notLtZero: all {a: Nat}: a < zero -> False
        -- No number is less than 'zero'
    := case
        -- neither start nor next can construct an object of
        -- type 'succ a <= zero'


    ltSucc {a: Nat}: a < succ a
        -- All numbers are less than their successors
    :=
        leReflexive


    (,): all {a b c: Nat}: a <= b  ->  b <= c  ->  a <= c
        -- The '<=' relation is transitive
    := case
        \ {a}, {b}, {zero}, leAB, leBZ :=

            let
                aZ: a = zero := zeroLeast (replace (zeroLeast leBZ) leAB
            :=
                replace (flip aZ) start

        \ {succ n}, leAB, leBN :=

            leSucc (leAB, leBN)



Order and Predicates
================================================================================


.. code::

    LowerBound (P: Nat -> Prop) (x: Nat): Prop
            -- 'x' is a lower bound for all numbers satisfying 'P'
    :=
        all {y}: P y  ->  x <= y


    StrictLowerBound (P: Nat -> Prop) (x: Nat): Prop
            -- 'x' is a strict lower bound for all numbers satisfying 'P'
    :=
        all {y}: P y  ->  x < y


    Least (P: Nat -> Prop) (x: Nat): Prop
        -- 'x' is the smallest number satisfying 'P'
    :=
        LowerBound P x /\ P x
