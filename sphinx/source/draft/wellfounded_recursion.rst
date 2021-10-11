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

    leToNotLt: ∀ {x y}: x ≤ y → not y < x :=
        ...

    ltIrreflexive: ∀ {x}: x < x → False :=
        ...

    succLowerBound
        {P: Predicate ℕ}
        : ∀ {x}: LowerBound P x → not P x → LowerBound P (succ x)
    :=
        ...

    LowerBound (P: Predicate ℕ) (n: ℕ): Prop :=
        ∀ {x}: P x → n ≤ x

    Least (P: Predicate ℕ) (n: ℕ): Prop :=
        LowerBound P n and P n



The algorithm is intuitively clear. We check if the number zero satisfies the
predicate. If yes, we have found the number. If not we check the next number and
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
            succ x = y and LowerBound P y


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
                    lbSuccX satX: x < x |> ltIrreflexive |> exFalso


    accessibleToPredecessor
        {P: Predicate ℕ}
        {x: ℕ}
        : Accessible (Rel P) (succ x) → Accessible (Rel P) x
    :=
        λ accSuccX :=
            access f where
                f: ∀ {y}: succ x = y and LowerBound P y → Accessible (Rel P) y :=
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





Recursion like Coq
================================================================================

.. code-block::

    Accessible.recurse
        {A: Any}
        {T: A → Any}
        {R: Endorelation A}
        (f: ∀ x: (∀ y: R y x → T y) → T x)
        : ∀ x: Accessible R x → T x
    :=
        λ x (access h) :=
            f x (λ y rYX := recurse y (h rYX))
