************************************************************
Continuations
************************************************************


Convert to tail recursive
==================================================

Why: Convert recursive functions to tail recursive function.

Example: Preorder list of a binary tree.

::

    class T :=
        ε: T
        nd: T → Int → T → T


    -- compute preorder sequence
    pre: T → L := case
        λ ε :=
            []
        λ (nd l x r) :=
            pre l + (x :: pre r)

Problem: ``pre`` is not tail recursive. The result of the recursive calls has to
be processed before it can be returned to the caller.


::

    -- prepend the preorder list in front of another list
    prep: T → L → L := case
        λ ε a :=
            a
        λ (nd l x r) a :=
            prep l (x :: prep r a)

    prepCPS: T → L → (L → L) → L := case
        λ ε b k :=
            k b
        λ (nd l x r) b k :=
            prepCPS l res₁ k where
                res₁ :=
                    prepCPS r b (λ res := x :: res)


``prep`` is tail recursive.

.. code-block:: javascript

    // javascript implementation



Mutual Recursion
==================================================


.. code-block::

    mutual
        even: ℕ → Bool := case
            λ zero :=
                true
            λ (succ i) :=
                odd i
        odd: ℕ → Bool := case
            λ zero :=
                false
            λ (succ i) :=
                even i


Every recursive call is a tail call.

.. code-block:: javascript

    function even (n) { even_odd (n, 0) }
    function odd  (n) { even_odd (n, 1) }

    function even_odd (n, which) {
        for (;;) {
            switch (which) {
            case 0:     // even case
                switch (n[0]) {
                case 0:
                    return true
                default:
                    n = n[1]
                    which = 1
                }
            default:    // odd case
                switch (n[0]) {
                case 0:
                    return false
                default:
                    n = n[1]
                    which = 0
                }
            }
        }
    }




Continuation Monad
==================================================


::

    class Bounce {α: Any} :=
        done: α → Bounce
        more: (Unit → Bounce) → Bounce

    Cont (R A: Any): Any :=
        (A → Bounce R) → Bounce R

    return {R A: Any} (a: A): Cont R A :=
        λ k := k a

    (>>=) {R A B: Any} (m: Cont R A) (f: A → Cont R B): Cont R B :=
        λ k := m (λ a := f a k)

    run {R: Any} (m: Cont R R): R :=
        iter (m (λ x := x))
        where
            iter: Bounce R → R := case
                λ (done x) :=   x
                λ (more f) :=   iter (f ())


We consider the problem of computing the preorder sequence of a binary tree
(here an int-tree in order to keep things simple).

::

    class T :=
        ε: T
        nd: T → Int → T → T


    -- compute preorder sequence ('L' is 'List Int')
    pre: T → L := case
        λ ε :=
            []
        λ (nd l x r) :=
            pre l + (x :: pre r)


::

    preB: T → Cont L L := case
        λ ε :=
            return []

        λ (nd l x r) := do
            l := return l           -- avoid recursion
            resL := preB l
            resR := preB r
            return resL + (x :: resR)

    pre (t: T): L :=
        run (preB t)





Optimized Preorder Sequence
==================================================


::

    -- preoder sequence prepended in front of a list

    preOpt: T → L → L := case
        λ ε b :=
            b
        λ (nd l x r) b :=
            preOpt l (x :: preOpt r b)


    -- with bounce

    preCPS: T → L → (L → Bounce L) → Bounce L :=
        λ ε b k :=
            k b

        λ (nd l x r) b := do
            b := return b
            bR := preCPS r b
            preCPS l (x :: bR)
