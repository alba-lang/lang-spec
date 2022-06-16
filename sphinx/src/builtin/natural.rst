********************************************************************************
Module: alba.core.natural
********************************************************************************


There are arbitrary sized natural numbers and integer numbers. Both are given a
definition as an inductive type. However they are compiled to more efficient
types in the runtime.

Therefore the basic arithmetic functions and decision procedures are also
defined in terms of the inductive types. But these arithmetic functions and
decision procedures are compiled to more efficient runtime representations.




Builtin Definitions
================================================================================

.. code-block::

    class Natural: Any :=
        zero: Natural
        succ: Natural -> Natural

    class (<=): Natural -> Natural -> Prop :=
        start {n}: 0 <= n
        next {n m}: n <= m -> succ n <= succ m


    (<) (a b: Natural): Prop :=
        succ a <= b

    (>=) (a b: Natural): Prop :=
        b <= a

    (>) (a b: Natural): Prop :=
        b < a


    pred: Natural -> Natural
    := case
        \ zero :=
            zero
        \ (succ n) :=
            n

    zeroNotSucc: all {a: Natural}: zero /= succ a
    := case
        -- not unifiable


    succInjective: all {a b: Natural}: succ a = succ b -> a = b
    :=
        \ eqSucc := (=).inject pred eqSucc


    (=?): (a b: Natural): Decision (a = b)
    := case
        λ zero      zero        :=
            true identical

        λ (succ n)  (succ m)    :=
            inspect n =? m case
                \ true eq :=
                    true (=).inject succ eq
                \ (false notEq) :=
                    false (\ eqSuccs := notEq (succInjective eqSuccs))

        λ zero (succ m) :=
            false zeroNotSucc

        \ (succ n) zero :=
            false (\ eq := zeroNotSucc ((=).flip eq))


    (<?): Natural -> Natural -> Bool := case
        λ _         zero        := false
        λ zero      (succ _)    := true
        λ (succ n)  (succ m)    := n <? m

    (+): Natural -> Natural -> Natural := case
        λ n zero        := n
        λ n (succ m)    := succ (n + m)

    (-): Natural -> Natural -> Natural := case
        λ n         zero        :=  n
        λ n         (succ _)    :=  zero
        λ (succ n)  (succ m)    :=  n - m

    (*): Natural -> Natural -> Natural := case
        λ zero      m           :=  zero
        λ (succ n)  m           :=  n * m + m

    (^): Natural -> Natural -> Natural := case
        λ n         zero        := succ zero
        λ n         (succ m)    := n * (n ^ m)

    divAux: Natural -> Natural -> Natural -> Natural -> Natural := case
            -- n / (succ m) = divAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  divAux (succ k) m n m
        λ k m   (succ n)    (succ j):=  divAux k m n j

    modAux: Natural -> Natural -> Natural -> Natural -> Natural := case
            -- n % (succ m) = modAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  modAux 0 m n m
        λ k m   (succ n)    (succ j):=  modAux (succ k) m n j


Key idea in ``divAux`` and ``modAux``: The number ``k`` is initialized to
``zero`` and incremented in some cases such that at the end it is either the
quotient or the remainder. Both are total functions have efficient runtime
representations.





Recursion and Induction
================================================================================


.. code-block::

    recurse
        {F: Natural -> Any}
        (start: F zero)
        (next: all i: F i -> F (succ i))
        : all n: F n
    := case
        \ zero :=
            start
        \ (succ n) :=
            next n (recurse n)


    induce
        {P: Predicate Natural}
        (start: P zero)
        (next: all {i}: P i -> P (succ i))
        : all {n}: P n
    := case
        \ {zero} :=
            start
        \ {succ n} :=
            next (induce {n})



Addition
================================================================================



Helper Functions
--------------------------------------------------------------------------------


.. code-block::

    pullSucc:
        all {a b: Natural}:
            succ a + b = succ (a + b)
    := case
        \ {a} {zero} :=
            identical
        \ {a} {succ n} :=
            (=).inject succ (pullSucc {a} {n})


    pushSucc {a b: Natural}:
            succ (a + b) = succ a + b
    :=
        (=).flip pullSucc


    zeroLeftNeutral:
        all {a: Natural}
            zero + a = a
    := case
        \ {zero} :=
            identical
        \ {succ n} :=
            (=).inject succ (zeroLeftNeutral {n})


Associativity
--------------------------------------------------------------------------------


.. code-block::

    associate:
        all {a b c: Natural}:
            a + b + c = a + (b + c)
    := case
        \ {a} {b} {zero} :=
            identical
        \ {a} {b} {succ n} :=
            (=).inject succ (associate {a} {b} {n})



Commutativity
--------------------------------------------------------------------------------


.. code-block::

    commute:
        all {a b: Natural}:
            a + b = b + a
    := case
        \ {a} {zero} :=
            (=).flip zeroLeftNeutral
        \ {a} {succ n} :=
            (=).(
                inject succ (commute {a} {n})   -- a + succ n = succ (n + a)
                +
                pushSucc {n} {a}                --            = succ n + a
            )



Multiplication
================================================================================



Exponentiation
================================================================================



Order Relation
================================================================================
