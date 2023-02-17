.. _Universes:

****************************************
Universes / Sorts
****************************************




Basics
========================================


Universes and sorts are the same thing. There are the following universes::

    Prop            -- Impredicate universe of propositions
    Any level       -- Stratified predicative universes
    Level           -- The type of predicative levels

    --
    once  Any level -- Universe for resource types
    ref   Any level -- Universe for reference types (shared references)
    ghost Any level -- Universe of ghost types

where ``level`` is defined by the grammar::

    level ::=
        i               -- Fixed universe levels 0 1 2 ...
    |   u               -- Universe level variables
    |   u + i           -- Universe level 'i' above 'u'
    |   max u v ...     -- The maximum of the levels 'u', 'v', ...
    |   ω               -- The highest possible level

Examples of predicative universes::

    Any 0
    Any 10
    Any (u + 4)
    Any (max u (v + 3))


The levels have a partial order::

    0 < 1 < 2 < ... < ω

    0 ≤ u < ω

    u < u + i       -- for 0 < i

    v ≤ max . . . v . . .

Different universe variables are unrelated. The partial order on the levels
induces a partial order on the universes::

    Prop < Any 0 < Any 1 < ... < Any ω

    Any u < Any v       -- if u < v

    Any u ≤ Any v       -- if u ≤ v

    Any u < Any ω

    Level < Any ω

All universes except ``Any ω`` have types with the typing rules::

    s₁  <   s₂
    ----------
    s₁  :   s₂

where ``s₁`` and ``s₂`` are universes (or sorts). Since ``Any ω`` is the highest
possible universe, there is no higher universe and therefore ``Any ω`` does not
have a type.

Because of the typing rule for variable introduction::

    Γ ⊢ A : s
    ------------------
    Γ, x: A ⊢ x : A

we can substitute all universes except ``Any ω`` for ``A`` and
define variables which have the corresponding universes as type. E.g.::

    α: Prop

    β: Any u

    u: Level


All fully elaborated polymorphic types and functions use universes and universe
levels::

    class List₀ (α: Any 0): Any 0 :=
        []      :   List₀
        (::)    :   α → List₀ → List₀

    append {α: Any 0}: List₀ α → List₀ α → List₀ α := case
        λ []        ys  :=  ys
        λ (x :: xs) ys  :=  x :: append xs ys

    class List₁ (α: Any 1): Any 0 :=
        []      :   List₁
        (::)    :   α → List₁ → List₁

    class List {u: Level} (α: Any u): Any 0 :=
        []      :   List
        (::)    :   α → List → List

    append {u: Level} {α: Any u}: List α → List α → List α
    := case
        λ []        ys  :=  ys
        λ (x :: xs) ys  :=  x :: append xs ys


The last two definitions are universe polymorphic. They can be instantiated at
any universe level.

Some illegal and legal types::

    List₀ ℕ                 -- Legal: List of natural numbers. 'ℕ : Any 0' is valid

    List₀ (Any 0)           -- Illegal, because 'Any 0 : Any 0' is invalid

    List₁ (Any 0)           -- Legal, because 'Any 0 : Any 1' is valid

    List {1} (Any 0)        -- Legal, because 'Any 0 : Any 1' is valid


Using ``List₁`` or ``List`` it is possible to construct a list of types::

    [Int, String, Bool] : List₁ (Any 0)

    [Int, String, Bool] : List {1} (Any 0)

    -- because of
    Int     :   Any 0
    String  :   Any 0
    Bool    :   Any 0

Usually it is not necessary to spell out the universes in the source code,
because the elaborator can derive the most general fully elaborated definition.
E.g. if the compiler is fed with the definition::

    class List (α: Any) :=
        []      :   List
        (::)    :   α → List → List

it generates the above fully elaborated definition of ``List``.



Subtyping
========================================

The type system has the subtyping rule::

    Γ ⊢ x : T
    T < U
    -------------------
    Γ ⊢ x : U



We can instantiate this rule for sorts::

    Γ ⊢ α : s₁
    s₁ < s₂
    -------------------
    Γ ⊢ α : s₂

and specifically for predicative universes::

    Γ ⊢ α : Any u
    -------------------
    Γ ⊢ α : Any (u + i)

I.e. any type in the universe at level ``u`` is also a type in the universe at
level ``u + i`` for any ``0 < i``.

This eliminates the need to define e.g. tuples with two universe levels::

    -- Definition with two universe levels
    class
        Tuple {u v: Level} (α: Any u) (β: Any u): Any (max u v)
    :=
        (,): α → β → Tuple

    -- Equivalent definition with one universe level
    class
        Tuple {u: Level} (α β: Any u): Any u
    :=
        (,): α → β → Tuple


    -- Typing judgements
    1       : ℕ
    Bool    : Any 0

    (1, Bool): Tuple ℕ (Any 0)

    ℕ       : Any 1
    Any 0   : Any 1

    Tuple ℕ (Any 0): Any 1





Dependent Lists
============================================================

.. code::

    -- All 'Any' are 'Any u' at the same universe level
    type
        DList {A: Any} (P: A -> Any): List A -> Any
    :=
        []: DList []
        (::) {a} {as}: P a -> DList as -> DList (a :: as)


.. code::

    (+)
        {A} {P} {as} {bs}: DList {A} P as -> DList P bs -> DList P (as :: bs)
    := case
        \ [], ys :=
            ys

        \ x :: xs, ys :=
            xs + (x :: ys)

        -- long form
        \ (::) {a} {as) x xs, ys :=
            (xs: DList P as) + ((::) {a} {bs} x ys: DList P (a :: bs))





Heterogeneous Lists
============================================================

Example from Idris.

.. code-block::

    type
        HList {u: Uni}: List (Any u) -> Any (u + 1)
    :=
        []:
            HList []
        (::)
            {T: Any u} {TS: List (Any u)}
            : T -> HList TS -> HList (T :: TS)


    -- Note: 'List (Any u): Any (u + 1)'


.. code::

    type
        ElemAt: Natural -> Any -> List Any -> Any
            -- ElemAt i T TS: The 'i'th element of list 'TS' is 'T'.
    :=
        atZero {T TS}: ElemAt zero T (T :: TS)

        atSucc {k T U TS}: ElemAt k T TS -> ElemAt (succ k) T (U :: TS)

    lookup
        {T: Any} {TS: List Any}
        : all {i}: ElemAt i T TS -> HList TS -> T
    := case
        \ atZero        (x :: xs) :=
            x
        \ (atSucc atk)  (x :: xs) :=
            lookup atk xs

Note that types are erased in the runtime. Therefore an object of type ``ElemAt
i T TS`` is only the number ``i`` i.e. we are looking up the ``i``\ th element
of the list with ``lookup at_i hlst``.




Draft
========================================




Using universe levels it is possible to define dependent lists::

    type
        DList {u: Level} {A: Any u} (P: A → Any u): List A → Any u
    :=
        dnil    : DList []
        dcons   : ∀ {x: A} {xs: List A}: P x → DList xs → Dlist (x :: xs)


Let ``A`` be ``Any 0``. This requires ``0 < u``. Then we can use ::

    \ (T: Any 0): Any u := T

for the predicate ``P``. This gives ``P ℕ ~~> ℕ``, ``P Bool ~~> Bool`` etc. i.e.
``P`` is the identity function on types. In that case we can form ::

    hcons 5 (hcons true hnil): DList (\ T := T) [ℕ, Bool]


An easier to unserstand type is the type of heterogenious lists::

    type
        HList {u: Level}: List (Any u) → Any (u + 1)
    :=
        []:   HList []
        (::): ∀ {T: Any u} {Ts: List (Any u)}: T → HList Ts → Hlist (T :: Ts)

Having this we can form ::

    [1, true]: HList [ℕ, Bool]
