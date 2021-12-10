********************************************************************************
Module: alba.core.natural
********************************************************************************


There are arbitrary sized natural numbers and integer numbers. Both are given a
definition as an inductive type. However they are compiled to more efficient
types in the runtime.

Therefore the basic arithmetic functions and decision procedures are also
defined in terms of the inductive types. But these arithmetic functions and
decision procedures are compiled to more efficient runtime representations.

.. code-block::

    -- Natural Numbers
    class Natural: Any :=
        zero: Natural
        succ: Natural -> Natural


    Natural.(=?): Natural -> Natural -> Boolean := case
        λ zero      zero        := true
        λ (succ n)  (succ m)    := n =? m
        λ _         _           := false


    Natural.(<?): Natural -> Natural -> Boolean := case
        λ _         zero        := false
        λ zero      (succ _)    := true
        λ (succ n)  (succ m)    := n <? m

    Natural.(+): Natural -> Natural -> Natural := case
        λ n zero        := n
        λ n (succ m)    := succ (n + m)

    Natural.(-): Natural -> Natural -> Natural := case
        λ n         zero        :=  n
        λ n         (succ _)    :=  zero
        λ (succ n)  (succ m)    :=  n - m

    Natural.(*): Natural -> Natural -> Natural := case
        λ zero      m           :=  zero
        λ (succ n)  m           :=  n * m + m

    Natural.(^): Natural -> Natural -> Natural := case
        λ n         zero        := succ zero
        λ n         (succ m)    := n * (n ^ m)

    Natural.divAux: Natural -> Natural -> Natural -> Natural -> Natural := case
            -- n / (succ m) = divAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  divAux (succ k) m n m
        λ k m   (succ n)    (succ j):=  divAux k m n j

    Natural.modAux: Natural -> Natural -> Natural -> Natural -> Natural := case
            -- n % (succ m) = modAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  modAux 0 m n m
        λ k m   (succ n)    (succ j):=  modAux (succ k) m n j


Key idea in ``divAux`` and ``modAux``: The number ``k`` is initialized to
``zero`` and incremented in some cases such that at the end it is either the
quotient or the remainder. Both are total functions have efficient runtime
representations.
