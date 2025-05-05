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

Having ``a + succ b`` it is possible to pull out the successor function getting
``succ (a + b)``. This can be proved by induction on ``a``. The base case is
proved by reflexivity. The induction step requires to prove the equality of the
two expressions

.. code::

    -- expressions                          normal forms
    succ n + succ b                         succ (n + succ b)
    succ (succ n + b)                       succ (succ (n + b))

This can be done by the induction hypothesis using congruence.


.. code::

    pullSucc: all {a b: Nat}: a + succ b = succ (a + b) := case
        \ {zero},   {_} := refl
        \ {succ n}, {_} := congruence succ pullSucc

Zero is the neutral element of addition. The left neutrality doesn't need a
proof. It is evident by normalisation. The right neutrality ``a + zero = a``
requires an induction proof.

.. code::

    zeroRightNeutral: all {a: Nat}: a + zero = a := case
        \ {zero}   := refl
        \ {succ n} := congruence succ zeroRightNeutral

Addition is commutative i.e. ``a + b = b + a``. We prove this by induction on
``a``. The base case is proved by right neutrality of ``zero``. The induction
case requires a proof of the equality of the two left expressions

.. code::

    -- expression                       normal form
    succ n + b                          succ (n + b)
    b + succ n                          b + succ n

Via the induction hypothesis and congruence we can prove the equality of ``succ
(n + b)`` and ``succ (b + n)``. The flipped version of ``pullSucc`` can
transform it into ``b + succ n``.

.. code::

    plusCommutes: all {a b: Nat}: a + b = b + a := case
        \ {zero},   {b}   := zeroRightNeutral
        \ {succ n}, {b}   := (congruence succ plusCommutes, flip pullSucc)


The associativity of addition

.. code::

    (a + b) + c = a + (b + c)

can be proved by induction on ``a``. The base case is trivial. The proof of the
induction step can be done by the equivalences

.. code::

    (succ n + b) + c
    =                           -- normalisation
    succ ((n + b) + c)
    =                           -- induction hypothesis + congruence
    succ (n + (b + c))
    =                           -- normalisation (bwd)
    succ n + (b + c)

.. code::

    plusAssociates: all {a b c: Nat}: (a + b) + c = a + (b + c)
    := case
        \ {zero},   {b}, {c} := same
        \ {succ n}, {b}, {c} := congruence plus plusAssociates





Properties of Multiplication
================================================================================

Multiplication distributes over addition. In order to prove this we need a
helper theorem.


.. code::

    plusSwap: all {a b c: Nat}: a + (b + c) = b + (a + c)
    :=
        ( flip plusAssociates:                    _ = (a + b) + c
        , congruence (\ x := x + c) plusCommutes: _ = (b + a) + c
        , plusAssociates:                         _ = b + (a + c)
        )


Having ``plusSwap`` we can prove the distributivity of multiplication

.. code::

    a * (b + c) = a * b + a * c

by induction on ``a``. The base case is trivial. The induction step requires a
proof of

.. code::

    succ n * (b + c) = succ n * b + succ n * c

The equality can be proved by the steps

.. code::

    succ n * (b + c)
    =                               -- normalisation
    (b + c) + n * (b + c)
    =                               -- associativity of addition
    b + (c + n * (b + c))
    =                               -- induction hypothesis + congruence
    b + (c + (n * b + n * c))
    =                               -- plusSwap + congruence
    b + (n * b + (c + n * c))
    =                               -- associativity of addition (bwd)
    (b + n * b) + (c + b * c)
    =                               -- normalization (bwd)
    succ n * b + succ n * c

.. code::

    timesDistributes: all {a b c: Nat}: a * (b + c)  =  a * b + a * c
        -- Multiplication distributes over addition
    := case
        \ {zero},    {b},   {c} := refl
        \ {succ n},  {b},   {c} :=
            -- goal:
            --       succ n * (b + c)
            --       =
            --       succ n * b + succ n * c
            ( plusAssociates:
                    succ n * (b + c)
                    =
                    b + (c + n * (b + c))

            , congruence
                    (\ x := b + (c + x))
                    timesDistributes
                :   _
                    =
                    b + (c + (n * b + n * c))

            , congruence
                (\ x :=  b + x)
                plusSwap
                :  _
                   =
                   b + (n * b + (c + n * c))

            , flip plusAssociates
                :  _
                   =
                   succ n * b + succ n * c
                   -- (b + n * b) + (c + n * c)
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
        \ {zero},   {zero},     start   := right refl
        \ {zero},   {succ _},   start   := left (next start)
        \ {succ n}, {succ m},   next le :=
            match
                leLtOrEq le: n < m \/ n = m
            case
                \ left  lt  := left  (next lt)
                \ right eq  := right (congruence succ eq)


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
finitely many applications of the successor function. But here we invent another
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
                aux: all {n}: Finite n -> all {y}: y < succ n -> Finite y
                := case
                    -- no match for
                    --      {_} _ {_} start
                    -- because
                    --      succ y <= x
                    -- cannot be unified with
                    --      zero <= x

                    {n} (finN := fin f) {y} (next le) :=
                        match
                            leLtOrEq (le: y <= n): y < n \/ y = n
                        case
                            left  lt  :=
                                (f: all {y}: y < n -> Finite y)
                                    lt

                            right eq  :=
                                cast (flip eq) finN
            :=
                fin (aux natFinite: all {y}: y < succ n -> Finite y)
                : Finite (succ n)


Unbounded search:

.. code::

    find {P: Nat -> Prop} (d: Decider P): Exist P -> Refine (Least P)
    := case
        \ (w, pW) :=
            let
                aux: all n:
                        n <= w  ->              -- invariant 1
                        LowerBound P n ->       -- invariant 2
                        Finite (w - n) ->       -- bound function
                        Decision P n   ->
                        Refine (Least P)
                := case
                    n _ lbN _ (true pN) :=
                        (n, lbN, pN)

                    n leNW lbN (fin f) (false notPN) :=
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
