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





Zero is Different from a Successor
================================================================================


.. code::

    zeroNeSucc: all {n: Nat}: zero = succ n -> False :=
        case        -- no clauses

A potential clause would have the form

.. code::

    case
    \ {n}, same {?m} := ?
    --      : ?m = ?m

This would require to unify ``zero = succ n`` with ``?m = ?m`` which is
impossible, because ``?m`` cannot be ``zero`` and ``succ n`` at the same time
(``zero`` and ``succ n`` are not unifiable).



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
        ( flip plusAssociates:                    _ = (a + b) + c
        , mapEquals {\ x := x + c} plusCommutes:  _ = (b + a) + c
        , plusAssociates:                         _ = b + (a + c)
        )


Having ``plusSwap`` we can prove the distributivity of multiplication.

.. code::

    timesDistributes: all {a b c: Nat}: a * (b + c)  =  a * b + a * c
        -- Multiplication distributes over addition
    := case
        \ {zero},    {b},   {c} := same
        \ {succ n},  {b},   {c} :=
            -- goal: (b + c) + n * (b + c)  =  (b + n * b) + (c + n * c)
            ( plusAssociates
                : _  =  b + (c + n * (b + c))
            , mapEquals {\ x := _ + (_ + x)} timesDistributes
                : _  =  b + (c + (n * b + n * c))
            , mapEquals {\ x := _ + x} plusSwap
                : _  =  b + (n * b + (c + n * c))
            , flip plusAssociates
                : _  =  (b + n * b) + (c + n * c)
            )



Properties of Order
================================================================================


Reflexivity

.. code::

    leReflexive: all {a: Nat}: a <= a
        -- The less equal relation is reflexive.
    := case
        \ {zero}      :=  start
        \ {succ _}    :=  next leReflexive

    -- with implicits made explicit
        \ {zero}      := start {zero}
        \ {succ n}    := next {n} {n} (leReflexive {n})


Inversion

.. code::

    leInvers {a b: Nat}: succ a <= succ b  ->  a <= b
        -- If two successors are less equal then the values are
        -- less equal as well.
    := case
        -- constructor 'start' not possible, its type is 'zero <= .'
        \ next le := le

        -- with implicits
        \ next {a} {b} le := le


Transitivity

.. code::

    (,): all {a b c: Nat}: a <= b -> b <= c -> a <= c
        -- The '<=' relation is transitive
    := case
        \ start,        _           := start
        \ next leAB,    next leBC   := next (leAB, leBC)

        -- with implicits
        \ {zero}, {b}, {c}, start {b}, _ :=

            start {c}

        \ {succ a}, {succ b}, {succ c}, next {a} {b} leAB, next {b} {c} leBC :=

            next {a} {c} ((,) {a} {b} {c} leAB leBC)



Others

.. code::

    ltIrreflexive: all {a: Nat}: a < a -> False
        -- The less than relation is irreflexive.
    := case
        -- The 'start' constructor constructs 'zero <= _' which cannot be
        -- unified with 'succ ?a <= ?a'.
        \ next lt := ltIrreflexive lt


    leLtOrEq: all {a b: Nat}: a <= b -> a < b \/ a = b
    := case
        \ {zero},   {zero},     start   := right same
        \ {zero},   {succ _},   start   := left (next start)
        \ {succ _}, {succ _},   next le :=
            match leLtOrEq le case
                \ left  lt  := left  (next lt)
                \ right eq  := right (mapEquals eq)


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


    lowerBoundSucc
        {n: Nat} (lbN: LowerBound P n) (notPN: Not P n)
        : LowerBound P (succ n)
    :=
        \ {y} (pY: P y): succ n <= y :=
            match leLtOrEq (lbN pY) case
                \ left  lt  := lt
                \ right eq  := notPN (replace {P} (flip eq) pY)






Difference
================================================================================


.. code::

    (-): all (a b: Nat) {le: b <= a}: Nat
    := case
        \ (a := zero)    zero       start     := a
        \ (a := succ _)  zero       start     := a
        \ (succ n)       (succ m)   (next le) := n - m

       -- or better
       case
         a        zero     {start}    := a
         (succ n) (succ m) {next le}  := (n - m) {le}

Note that the pattern match on ``b <= a`` is allowed in the case clauses,
because only one constructor is possible. Therefore no decision is made on the
propositional pattern match.


.. code::

    minusPlusInvers: all {a b: Nat}: b <= a -> a - b + b = a
    := case
        \ {zero},       {zero},     _       := zeroRightNeutral
        \ {succ n},     {zero},     _       := zeroRightNeutral
        \ {succ n},     {succ m},   next le :=
            -- goal: (succ n - succ m) + succ m = succ n
            -- i.e.: (n - m) + succ m = succ n
            (
                pullSucc: _ = succ ((n - m) + m)
            ,
                mapEquals (minusPlusInvers le)
            )


.. code::

    minusLe: all {a b: Nat}: b <= a -> a - b <= a
        -- Substraction makes a number less equal.
    := case
        \ {zero},   {zero},   start     := start
        \ {succ n}, {zero},   start     := leReflexive
        \ {succ n}, {succ m}, next le   :=
            -- goal: succ n - succ m <= succ n
            -- i.e.: n - m  <= succ n
            (
                minusLe le: n - m <= n
            ,
                leSucc:     n <= succ n
            )



From ``a < b`` we can infer ``c - b < c - a`` provided that ``b <= c`` is valid.

.. code::

    minusLt: all {a b c: Nat}: a <= c  ->  b <= c  ->  a < b  ->  c - b < c - a
        -- The preconditions 'a <= c'  and 'b <= c' are needed for '-'
    := case
        \ start,        next leBC,      next ltAB   :=
            -- goal: succ c - succ b < succ c - zero
            -- i.e.: succ (c - b) <= succ c
            next (minusLe leBC)
        \ next leAC,    next leBC,      next ltAB   :=
            -- goal: succ c - succ b < succ c - succ a
            -- i.e.: c - b < c - a
            minusLt leAC leBC ltAB







Wellfounded Recursion
================================================================================


Clearly all natural numbers are finite, because each number is constructed by
finitely many application of the successor function. But here we invent another
way to express the finiteness of natural numbers.

We say that a number is finite, if all numbers below it are finite.

.. code::

    type Finite: Nat -> Prop :=
        fin {x}: (all {y}: y < x -> Finite y) -> Finite x


We can prove that all natural numbers are finite by an induction proof.

.. code::

    natFinite: all {n: Nat}: Finite n
    := case
        \ {zero} :=
            fin notLtZero

        \ {succ n} :=
            -- goal: Finite (succ n)
            let
                aux: Finite n -> all {y}: y < succ n -> Finite y
                := case
                    \ (finN :=fin f), next le :=
                        match leLtOrEq le case
                            \ left  lt  := f lt
                            \ right eq  := replace {Finite} (flip eq) finN
            :=
                fin (aux natFinite)


Unbounded search:

.. code::

    find {P: Nat -> Prop} (d: Decider P): Exist P -> Refine (Least P)
    := case
        \ (w, pW) :=
            let
                aux n:
                    n <= w                  -- invariant 1
                    -> LowerBound P n       -- invariant 2
                    -> Finite (w - n)       -- bound function
                    -> Decision P n
                    -> Refine (Least P)
                := case
                    \ n, lbN, _, true pN :=
                        (n, lbN, pN)

                    \ n, leNW lbN, fin f, false notPN :=
                        let
                            lbSN: LowerBound P (succ n) :=
                                lowerBoundSucc lbN notPN

                            leSNW: succ n <= w :=
                                lbSN pW

                            ltWmSN: w - succ n < w - n :=
                                minusLt leNW leSNW leReflexive
                        :=
                            aux (succ n) leSNW lbSN (f ltWnSN) (d (succ n))
            :=
                aux zero start (\ _ := start) natFinite (d zero)
