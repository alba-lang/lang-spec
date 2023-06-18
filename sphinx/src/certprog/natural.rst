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
        \ {succ n}, {b}   := (map succ plusCommutes, flip pullSucc)






Properties of Order
================================================================================

.. code::

    leReflexive: all {a: Nat}: a <= a := case
        \ {zero}      :=  start
        \ {succ n}    :=  next leReflexive


    leSucc: all {a: Nat}: a <= succ a := case
        \ {zero}      := start
        \ {succ n}    := next leSucc


    zeroLeast: all {a: Nat}: a <= zero  ->  a = zero := case
        \ start := same
        -- The case 'next' is not possible!


    (,): all {a b c: Nat}: a <= b  ->  b <= c  ->  a <= c := case
        \ {a}, {_}, {zero}, leAB, leBZ := 

            let
                aZ: a = zero := zeroLeast (replace (zeroLeast leBZ) leAB
            :=
                replace (flip aZ) start

        \ {succ n}, leAB, leBN :=

            leSucc (leAB, leBN)
