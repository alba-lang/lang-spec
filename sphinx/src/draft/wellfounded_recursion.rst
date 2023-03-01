********************************************************************************
Wellfounded Recursion
********************************************************************************



W Types
================================================================================


.. code::

    type W (A: Any) (P: A -> Any): Any :=
        mw x: (B x -> W A P) -> W A P

    Unit: Any := all (A: Any): A -> A
    id: Unit := \ A x := x

    Void: Any := all (A: Any): A

    Bool: Any := all (A: Any): A -> A -> A
    true:  Bool := \ A x y := x
    false: Bool := \ A x y := y

    Nat :=
        W Bool (\ b := b Any Unit Void)
    zero :=
        mw false (\ void := void Nat)
    succ (n: Nat): Nat :=
        mw true (\ id := id Nat n)







Unbounded Search with Bound Function
================================================================================

Document with a wellfounded relation that the argument of the recursive call
decrease a bound function with respect to the relation.

.. code::

    find (P: Predicate Nat) (d: Decider P) (e: Exist P): Nat :=
        let
            aux: all n: Decision (P n) -> LowerBound P n -> Exist P -> Nat
            := case
                \ n, left p, _ :=
                    n
                \ n, right notp, e := (v, _) :=
                    aux (succ n) e (succ n |> d) where
                        _ : v - (succ n) < v - n :=
                                -- bound function 'v - n'
                                -- '<' is wellfounded relation
                            ...
                            -- use 'notp' to prove 'LowerBound P (succ n)'
                            -- ~> 'succ n < v'
                            -- 'v < succ v' (generally true)
                            -- ~> 'v - succ n < succ v - succ n'
                            -- ~> 'v - succ n < v - n'
        :=
            aux zero (d zero) (start: all {n}: 0 <= n) e





Merge Sorted Lists
================================================================================


In a set of arguments at least one argument decreases structurally and the
others remain the same.

.. code::

    merge: List Nat -> List Nat -> List Nat := case
        \ [], l  := l
        \ l,  [] := l
        \ x0 := x :: xs, y0 := y :: ys :=
            if x <=? y then
                x :: merge xs y0
            else
                y :: merge x0 ys






Ackermann Function
================================================================================

We use the lexicographic order of the two arguments. On each recursive call
either the first decrease or the first is the same and the second decreases.

.. code::

    ack: Nat -> Nat -> Nat := case
        \ zero, m :=
            succ m
        \ succ n, zero :=
            ack n (succ zero)
        \ n0 := succ n, succ m :=
            ack n (ack n0 m)





Unbounded Search for Natural Numbers
================================================================================

For an unbounded search we have a predicate ``P: Nat -> Prop`` and a decider
``d: Decider P`` where the call ``d n`` decides whether ``n`` satisfies the
predicate ``P``. The task is to find the least number satisfying the predicate
``P``.

This task can be done successfully if there is at least one number satisfying
the predicate. If there is no such number a search for such a number never
terminates.

Formally we have to find a function with the signature

.. code::

    find {P: Nat -> Prop} (d: Decider P): Exist P -> Refine (Least P)
    :=
        ...

where an object of type ``Exist P`` is a proof that there exists a number
satisfying ``P`` and an object of type ``Refine (Least P)`` is a number ``n``
together with a proof that ``n`` is the least number satisfying ``P``.

The algorithm is quite simple:

- Set ``n`` to zero.

- loop: Check, if the number ``n`` satisfies the predicate.

- if yes, return the number.

- if no, increment the number and goto loop.

This algorithm has the invariant:

- ``n`` is always a lower bound for all numbers which satisfy the predicate.
  Specifically for each number ``v`` which satisfies the predicate the
  inequality ``n <= v`` is valid.

Furthermore if ``v`` is a number which satisfies the predicate then the distance
between ``v`` and ``n`` i.e. ``v - n`` is decremented at each iteration by one.
I.e. ``v - n`` is a bound function which has zero as a lower bound.

The following is an incomplete implementation of the algorithm as a recursive function.

.. code::

    find {P: Nat -> Prop} (d: Decider P): Exist P -> Refine (Least P)
    := case
        \ exist _ :=                -- unused existence
            aux zero (d zero)
            where
                aux := case
                    \ n, (true _) :=
                            -- n satisfies the predicate P
                            -- we are ready
                        (n, _)      -- proof that 'n' is the smallest number
                                    -- satisfying 'P' is missing

                    \ n, (false _) :=
                            -- n does not satisfy the predicate P
                            -- the search must goon
                        aux (succ n) (d (succ n))
                    --  ^  illegal recursive call

This incomplete implementation has several shortcomings:

#. It does not exploit the invariant that at each step of the iteration the
   number ``n`` is a lower bound for all numbers satisfying the predicate.

#. In case of success (first case) it does not provide a proof that the number
   is the smallest number satisfying the predicate.

#. It does not use the fact that a number satisfying the predicate ``P`` exists.

#. In the recursive case it does not decrement any argument. Therefore the
   compiler has no evidence that the recursion is terminating.


The first two shortcomings can easily be resolved by providing the auxiliary
function with an argument proving that the number ``n`` is a lower bound for the
set of all numbers satisfying the predicate.

.. code::

    aux
        {P: Nat -> Prop} (d: Decider P)
        : all n: Decision (P n) -> LowerBound P n -> Refine (Least P)
    := case
        \ n, true nP, lbN :=
            (n, nP, lbN)
            --  ^^^^^^^ n satisfies P and is a lower bound, therefore
            --          n is the smallest number satisfying P

        \ n, false notNP, lbN :=
            aux (succ n) (d (succ n)) (lowerBoundSucc lbN notNP)
        --                             ^ invariant satisfied by (succ n)
        --  ^ recursive call still illegal, no argument is decreasing

    find {P: Nat -> Prop) (d: Decider P): Exist P -> Refine (Least P)
    := case
        \ exist _ :=
            aux d zero (d zero) (zeroLowerBound P)

    -- using the following definitions:
        LowerBound (P: Nat -> Prop) (n: Nat): Prop :=
            all {x}: P x -> n <= x

        Least (P: Nat -> Prop) (n: Nat): Prop :=
            P n /\ LowerBound P n

        zeroLowerBound (P: Nat -> Prop): LowerBound P zero
        := ...

        lowerBoundSucc
            (P: Nat -> Prop)
            : all {n}: LowerBound P n -> Not (P n) -> LowerBound P (succ n)
        := ...

However the auxiliary function still contains an illegal recursive call where no
argument is decreasing and therefore the compiler has no evidence that the
recursion terminates.



For unbounded search we need the inductive type ``Acc``. The proposition ``Acc R
x`` says that ``x`` is an accessible element of the relation ``R``. An element
``x`` is a accessible if all its predecessors ``y`` in the relation ``R`` i.e.
all ``y`` satisfying ``R y x`` must be accessible as well. In order to construct
a proof of ``Acc R x`` we need a proof of ``all {y}: R y x -> Acc R y``.

.. code::

    type Acc {A: Any} (R: A -> A -> Prop): A -> Prop :=
        acc {x}: (all {y}: R y x -> Acc y) -> Acc x

A relation is wellfounded if all elements of the carrier are accessible.

.. code::

    Wellfounded {A: Any} (R: A -> A -> Prop): Prop :=
        all {x}: Acc R x

For natural numbers the relation ``<`` is wellfounded.

.. code::

    lessThanWellfounded: Wellfounded (<)
    :=
        ...  -- proof omitted.

I.e. for all numbers ``n`` it is possible to construct a proof of ``Acc (<) n``.
Since all proofs are finite, it is possible to iterate over such a proof.



Suppose we have ``x < y`` and ``ub`` is an upper bound for both i.e. ``y <=
ub`` is valid, then we have ``ub - y < ub - x``.

.. code::

    predLessThan: all {n: Nat}: n < succ n
    := ...

    invertLessThan
        all {x y ub: Nat}:
            x < y  ->  y <= ub  ->  ub - y < ub - x
    := ...


    lessThanWellfounded: all {n}: Acc (<) n
    := ...

.. code::

    aux
        {P: Nat -> Prop) (d: Decider P) {v} (vP: P v)
        : all n:
            Decision (P n)
            -> LowerBound P n
            -> Acc (<) (v - n)
            -> Refine (Least P)
    := case
        \ n, true pN, lbN, _ :=
            (n, pN, lbN)

        \ n, false notPN, lbN, acc f :=
            findAux (succ n) (d (succ n)) lbSuccN (f lt)
            where
                lt: v - succ n  <  v - n :=
                    invertLessThan predLessThan (lbSuccN vP)
                lbSuccN: LowerBound P (succ n) :=
                        -- use that n does not satisfy P and n is a lower
                        -- bound of P
                    lowerBoundSucc lbN notPN

    find {P: Nat -> Prop} (d: Decider P): Exist P -> Refine (Least P)
    := case
        \ exist vP :=
            aux d vP zero (d zero) (zeroLowerbound P) lessThanWellfounded




Wellfounded Relations on Inductive Types
================================================================================


Wellfounded relation for peano numbers:

.. code::

    type Acc {A: Any} (R: A -> A -> Prop): A -> Prop :=
        acc {x}: (all {y}: R y x -> Acc y) -> Acc x

    type WfNat: Nat -> Nat -> Prop :=
            -- Canonical wellfounded relation on natural numbers
        next: all {n}: WfNat n (succ n)

    WfNatWellfounded: all {n: Nat}: Acc WfNat n
        -- Proof: 'WfNat' is wellfounded i.e. all elements of its
        --        carrier are accessible.
    := case {Wf}
        \ zero := acc f where
            f: all {y}: WfNat y zero -> Acc WfNat y :=
                case
                    -- no match possible
        \ succ n := acc f where
            f: all{y}: WfNat y (succ n) -> Acc WfNat y
            := case
                \ (next {n}: WfNat n (succ n) :=
                    Wf {n}



Wellfounded relation for lists and trees:

.. code::

    type WfList {A: Any}: List A -> List A -> Prop :=
            -- canonical wellfounded relation for lists
        next: all {x, xs}: WfList xs (x :: xs)

    type Tree (A: Any): Any :=
        empty: Tree
        node:  Tree -> A -> Tree -> Tree

    type WfTree {A: Any}: Tree A -> Tree A -> Prop :=
        left:  all {l a r}: WfTree l (node l a r)
        right: all {l a r}: WfTree r (node l a r)
