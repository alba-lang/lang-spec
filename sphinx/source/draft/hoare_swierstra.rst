********************************************************************************
Hoare State Monad (Swierstra)
********************************************************************************


Wouter Swierstra use the example of relabelling binary to illustrate the Hoare
state monad.

.. code-block:: none

        original tree                   relabelled tree (start 10)
          *                                         *
        /   \                                     /   \
       a     *                                   10    *
           /   \                                     /   \
          b      c                                  11   12


Without Monad
================================================================================

.. code-block::

    class Tree (A: Any) :=
        leaf: A -> Tree             -- information in the leaves
        node: Tree -> Tree -> Tree

    relabel {A: Any}: Tree A -> ℕ -> (Tree ℕ, ℕ) :=
        case
            λ (leaf _) n :=
                (leaf n, succ n)
            λ (node t1 t2) n :=
                let (t11,n1) := relabel t1 n
                    (t22,n2) := relabel t2 n1
                :=
                    (node t12 t22, n2)


With Monad
================================================================================

.. code-block::

    -- State Monad
    SM (S A: Any): Any :=
        S → (A,S)

    return {S A: Any} (a: A): SM S A :=
        λ s := (a,s)

    (>>=) {S A B: Any} (m: SM S A) (f: A → SM S B): SM S B :=
        λ s :=
            let (a,s) := m s
            :=
                f a s

    get {S: Any}: SM S S :=
        λ s := (s,s)

    put {S: Any} (s: S): SM S Unit :=
        λ _ := (unit, s)


    relabel {A: Any}: Tree A → SM ℕ (Tree ℕ) :=
        case
            λ (leaf _) :=
                do
                    n := get
                    put (succ n)
                    return (leaf n)
            λ (node t1 t2) :=
                do
                    t1 := relabel t1
                    t2 := relabel t2
                    return (node t1 t2)




Hoare Monad
================================================================================


Definition of the Hoare state monad:

.. code-block::

    Pre (S: Any): Any :=
        S → Prop

    Post (S A: Any): Any :=
        S → A → S → Prop

    HM
        {S A: Any}
        (Q: Pre S)
        (R: Post S A)
        : Any
    :=
        all ((refine s0 _): Refine Q)
        : Refine (λ (a,s1) := R s0 a s1)


    Top {S: Any}: Pre S :=
        λ _ := True


The return function::

    return
        {S A: Any}
        (a: A)
        : HM (Top {S}) (λ s₀ b s₁ := s₀ = s₁ ∧ a = b)
    :=
        case
            λ (refine s _) := refine (a,s) (identical, identical)


The bind function::

    JoinPre {S A: Any} (Q1: Pre S) (R1: Post S A) (Q2: A → Pre S): Pre S
        -- The precondition 'Q1' and the postcondition 'R1' imply the
        -- precondition 'Q2'.
    :=
        λ s₀ :=
            Q1 s₀
            ∧
            all a s₁: R1 s₀ a s₁ → Q2 a s₁

    JoinPost {S A B: Any} (R1: Post S B) (R2: A → Post S B): Post S B
        -- A predicate on 's₀', 'b' and 's₂' such that
        -- there are some intermediate result 'a' and some intermediate state
        -- 's₁' such that the first postcondtion 'R1 s₀ a s₁' and the second
        -- postcondition 'R2 a s₁ b s₂' are satisfied.
    :=
        λ s₀ b s₂ :=
            some a s₁:
                R1 s₀ a s₁
                ∧
                R2 a s₁ b s₂

    (>>=)
        {S A B: Any}
        {Q1: Pre S}
        {R1: Post S A}
        {Q2: A → Pre S}
        {R2: A → Post S B}
        (m: HM Q1 R1)
        (f: all x: HM (Q2 x) (R2 x))
        : HM (JoinPre Q1 R1 Q2) (JoinPost R1 R2)
    := case
        λ (refine s₀ (q₀, fp)) :=
            let
                (refine (a,s₁) (r₁: R1 s₀ a s₁)) :=
                    m (refine s₀ q₀)
            :=
                inspect
                    f a s₀
                case
                    λ (refine (b,s₂) (r₂: R2 a s₁ b s₂) :=
                        refine (b,s₂) (exist (exist (r₁, r₂)))



Get and put ::

    get
        {S: Any}
        : HM (Top {S}) (λ s₀ s s₁ := s₀ = s₁ ∧ s = s₁)
    :=
        case
            λ (refine s _) :=
                refine (s,s) (identical, identical)

    put
        {S: Any}
        (s: S)
        : HM (Top {S}) (λ _ _ s₁ := s₁ = s)
    :=
        case
            λ (refine s _) :=
                refine (unit,s) identical


Adaption of pre- and postconditions::

    adapt
        {S A: Any}
        {Q1 Q2: Pre S}
        {R1 R2: Post S A}
    :   (all s: Q2 s → Q1 s)
        → (all s₀ a s₁: R1 s₀ a s₁ → R2 s₀ a s₁)
        → HM Q1 R1
        → HM Q2 R2
    :=
        λ fq fr m (refine s₀ q₀) :=
            let
                (refine (a,s₁) r₁ :=
                    m (refine s₀ (fq s₀))
            :=
                refine (a,s₁) (fr s₀ a s₁)




Certified Relabelling
================================================================================


.. code-block::

    flatten {A: Any}: Tree A → List A
    := case
        λ (leaf a) :=
            [a]
        λ (node t1 t2) :=
            flatten t1 + flatten t2


    size {A: Any}: Tree A → ℕ
        -- The number of leaf nodes in a tree.
    := case
        λ (leaf _) :=
            1
        λ (node t1 t2) :=
            size t1 + size t2


    seq: ℕ → ℕ → List ℕ
        -- seq start n = [start, 1+start, 2+start, ... (n - 1) + start]
    := case
        λ start zero :=
            []
        λ start (succ n) :=
            start :: seq (succ start) n


    relabel
        {A: Any}
        :   Tree A
            → HM
                (Top {ℕ})
                (λ n₀ t n₁ :=
                    n₁ = n₀ + size t
                    ∧
                    flatten t = seq n₀ (size t))
    := case  -- INCOMPLETE!!!!
        λ (leaf _) :=
            do
                n := get
                put (succ n)
                return (leaf n)
        λ (node t1 t2) :=
            do
                u1 := relabel t1
                u2 := relabel t2
                return (node u1 u2)


    relabel
        {A: Any}
        :   Tree A
            → HM
                (Top {ℕ})
                (λ n₀ t n₁ :=
                    n₁ = n₀ + size t
                    ∧
                    flatten t = seq n₀ (size t))
    := case  -- INCOMPLETE!!!!
        λ (leaf _) :=
            get
            >>=
            (λ n :=
                put (succ n)
                >>=
                (λ _ :=
                    return (leaf n)))
        λ (node t1 t2) :=
            do
                relabel t1
                >>=
                (λ u1 :=
                    relabel u2
                    >>=
                    (λ u2 :=
                        return (node  u1 u2)))
