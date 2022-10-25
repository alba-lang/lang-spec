********************************************************************************
Wellfounded Recursion
********************************************************************************



Unbounded Search for Natural Numbers
================================================================================

As an example we use the function which finds the least natural number which
satisfies a predicate provided that a number exists which satisfies the
predicate. In the following we use::

    P: Predicate Natural
    d: all n: Decision (P n)

as the search predicate and the decision procedure. We want to find a function
with the following signature::

    find
        {P: Predicate ℕ}
        : (∀ n: Decision (P n)) → Exist P → Refine (Least P)
    :=
        ...

We assume that the following declarations are available for natural numbers::

    class ℕ :=
        zero: ℕ
        succ: ℕ → ℕ

    class (≤): Endorelation ℕ :=
        start {n}:  zero ≤ n
        next {n m}: n ≤ m → succ n ≤ succ m

    (<): Endorelation ℕ :=
        λ x y := succ x ≤ y

    leToNotLt: ∀ {x y}: x ≤ y → Not y < x :=
        ...

    ltIrreflexive: ∀ {x}: x < x → False :=
        ...

    succLowerBound
        {P: Predicate ℕ}
        : ∀ {x}: LowerBound P x → Not P x → LowerBound P (succ x)
    :=
        ...

    LowerBound (P: Predicate ℕ) (n: ℕ): Prop :=
        ∀ {x}: P x → n ≤ x

    Least (P: Predicate ℕ) (n: ℕ): Prop :=
        LowerBound P n ∧ P n



The algorithm is intuitively clear. We check if the number zero satisfies the
predicate. If yes, we have found the number. If Not we check the next number and
iterate the function until we have found a number satisfying the predicate::

    findAux
        {P: Predicate ℕ}
        (d: ∀ n: Decision (P n)
        : ℕ → ℕ
    :=
        λ i :=
            if d i then
                i
            else
                findAux (succ i)

    findAux d zero      -- returns the desired number

However the function ``findAux`` is recursive and there is no decreasing
argument in the recursive call.

We use the relation::

    Rel (P: Predicate ℕ): Endorelation ℕ :=
        λ y x :=
            succ x = y ∧ LowerBound P y


and the inductive definition to define the accessible elements of an
endorelation::

    class
        Accessible
            {A: Any}
            (R: Endorelation A)
            : Predicate A
    :=
        access {x}:
            (∀ {y}: R y x → Accessible y)
            →
            Accessible x

Using this accessibility we can prove that an element is accessible in a
relation either if the element has no predecessors or if all predecessors are
accessible.


.. code-block::

    satToAccessible
        {P: Predicate ℕ}
        {x: ℕ}
        (satX: P x)
        : Accessible (Rel P) x
    :=
        access
            (λ (eq,lb) := f eq lb)
        where
            f: ∀ {y}: succ x = y → LowerBound P y → Accessible (Rel P) y
            :=
                λ identical lbSuccX :=
                    (lbSuccX satX: x < x) |> ltIrreflexive |> exFalso


    accessibleToPredecessor
        {P: Predicate ℕ}
        {x: ℕ}
        : Accessible (Rel P) (succ x) → Accessible (Rel P) x
    :=
        λ accSuccX :=
            access f where
                f: ∀ {y}: succ x = y ∧ LowerBound P y → Accessible (Rel P) y :=
                    λ (identical, _) := accSuccX


    accessibleToZero
        {P: Predicate ℕ}
        : ∀ {x}: Accessible (Rel P) x → Acessible (Rel P) zero
    := case
        λ {zero} acc :=
            acc
        λ {succ x} accSuccX :=
            accessibleToZero
                x
                (accessibleToPredecessor accSuccX)

    zeroAccessible
        {P: Predicate ℕ}
        : Exist P → Accessible (Rel P) Zero
    :=
        λ sat :=
            satToAccessible sat |> accessibleToZero


    findAux
        {P: Predicate ℕ}
        (d: ∀ x: Decision (P x))
        : ∀ x:  Decision (P x)
                → LowerBound P x
                → Accessible (Rel P) x
                → Refine (Least P)
    :=
        λ x (left pX) lbX _ :=
            refine x (lbX, pX)

        λ x (right notPX) lbX (access f) :=
            findAux
                (succ x)
                (d (succ x)A)
                lbSuccX
                (f (identical, lbSuccX)
            where
                lbSuccX := succLowerBound lbX notPX


    find
        {P: Predicate ℕ}
        (d: ∀ x: Decision (P x))
        (ex: Exist P)
        : Refine (Least P)
    :=
        findAux
            d
            zero
            (d zero)
            (λ _ := start)
            (zeroAccessible ex)





Wellfounded Recursion
================================================================================

In order to do wellfounded recursion we need

- A success predicate ``P``.

- A an endorelation ``R`` which we step downward from one accessible element to
  a lower accessible element (closer to the goal).

- A start value and an iteration function for the iteration.

- A decision procedure ``d`` which decides if we have reached the goal or the
  next element is closer to the goal.



.. code::

    section
        {A: Any}
        (P: A -> Prop)
        (R: A -> A -> Prop)
        (next: A -> A)
        (d:  all x: Decision (P x) (R (next x) x)
    :=
        recurse:
            all x: Decision (P x) (R (next x) x) -> Acc R x -> Refine P
        := case
            \ x, left p, _ :=
                (x, p)
            \ x, right r, acc f :=
                recurse y (d y) (f r) where y := next x



Unbounded Search Revisited
================================================================================


.. code::

    module
        find (P: ℕ -> Prop): Decider P -> Exist P -> Refine P
    :=
        section
            P: ℕ -> Prop
            d: Decider P
            e: Exist P
        :=
            type R: ℕ -> ℕ -> Prop :=
                    -- 'n' and its successor figure in the relation 'R'
                    -- if 'n' does not satisfy the predicate.
                next {n}: not (P n) -> R n (succ n)

            type Via: ℕ -> Prop :=
                    -- Set of viable candidates: A number 'n' is in the
                    -- set, if its successor in the relation 'n' is in
                    -- the set.
                via {x}: (all {y}: R x y -> Via y) -> Via x

            viaP {n} (p: P n): Via n :=
                    -- Every number which satisfies the predicate 'P'
                    -- is a viable candidate.
                via (case \ next notp := contra p notp)

            down: all n: Via n -> Via zero :=
                    -- Every viable candidate implies that 'zero' is
                    -- a viable candidate.
                case
                    \ zero, v :=
                        v
                    \ succ m, via {succ m} f :=
                        match d m case
                            \ left p :=
                                down m (viaP p)
                            \ right notp:=
                                down m (f (next notp))

            viaZero: Via zero :=
                    -- Zero is a viable candidate.
                match e case
                    \ (n, p) := down n (viaP p)

            findAux: all n: Decision (P n) -> Via n -> Refine P
            := case
                \ n, left p, _ :=
                    (n, p)
                \ n, right notp, via f :=
                    findAux (succ n) (d (succ n)) (f (next notp))


            find: Refine P :=
                findAux zero (d zero) viaZero




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
