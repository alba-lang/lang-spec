.. _Inductive Types:

****************************************
Inductive Types
****************************************


General Inductive Types
============================================================


.. rubric::  Syntax and Rules

The fully elaborated form of the definition of an inductive type looks like
::

    -- skeleton
    class <name> <params> : <kind> :=
        <constructor>
        ...

    -- fully elaborated
    class
        Name
            (p₁: P₁) (p₂: P₂) ...           -- parameters
            :   all (i₁: I₁) ...            -- indices
                : Sort                      -- 'Any or Prop'
    :=
        -- zero or more constructors
        c₁:
            all (b₁₁: B₁₁) (b₁₂: B₁₂) ...   -- constructor arguments
            : Name a₁₁ a₁₂ ...              -- constructed type

        c₂:
            all (b₂₁: B₂₁) (b₂₂: B₂₂) ...
            : Name a₂₁ a₂₂ ...

        ...

Inductive type:
    - There can be zero or more parameters. The parameters are constant for all
      constructors.


    - The ``: <kind>`` is optional. If not present the elaborator adds ``: Any``.


    - ``: <kind>`` might not have the form ``all (i₁: I₁) ... : Sort``, but it has
      to reduce to this form.


    - There can be zero or more indices. The indices can vary in the
      constructors.

    - The declaration of an inductive type ``Name`` creates a new namespace
      ``Name`` nested within the surrounding module. All constructors are
      declared to be in that namespace.

    - Viewed from the outside world, the inductive type has the type ::

        Name: all (p₁: P₁) (p₂: P₂) ... (i₁: I₁) (i₂: I₂) ... : Sort

Constructors:
    - There can be zero or more constructors. A type with zero constructors cannot
      be inhabited.


    - Each constructor must construct an object of type ``Name a₁₁ a₁₂ ...``
      where the actual index arguments are expressions of the corresponding
      index type (i.e. ``a₁₂: I₂``). The index arguments can use the constructor
      arguments ``b₁₁ b₁₂ ...`` and can be different for each constructor.

      Note that the parameters are not present in ``Name a₁₁ a₁₂ ...``. Viewed
      from the outside world, the constructor constructs an object of type
      ``Name p₁ p₂ ... a₁₁ a₁₂ ...``


    - Viewed from the outside world, the constructors have the type::

        c₂:
            all
                (p₁: P₁) (p₂: P₂) ...           -- all parameters
                (b₂₁: B₂₁) (b₂₂: B₂₂) ...
            : Name p₁ p₂ ... a₂₁ a₂₂ ...


    - The inductive type ``Name`` either does not occur in the constructor
      argument types ``B₁₁ B₁₂ ...`` or occurs only positively.


    - The following constructor declarations are equivalent ::

        c₁: all (b₁₁: B₁₁) (b₁₂: B₁₂) ... : Name a₁₁ a₁₂ ...

        c₁ (b₁₁: B₁₁): all (b₁₂: B₁₂) ... : Name a₁₁ a₁₂ ...

        c₁ (b₁₁: B₁₁) (b₁₂: B₁₂) ... : Name a₁₁ a₁₂ ...

    - If the inductive type has no indices, then the constructors can be
      declared as ::

        c₁ (b₁₁: B₁₁) (b₁₂: B₁₂) ...        -- without 'Name'

      The elaborator adds ``: Name``. Since there are no indices, no ambiguity
      exists.


Positivity:
    In case that the inductive type ``Name`` appears in the constructor
    argument type ``B₁₂`` it must occur only positively in it. There are two
    cases possible.

    - The constructor argument type ``B₁₂`` is a simple type: Then it has to be
      ``Name ...``.

    - The constructor argument type ``B₁₂`` is a function type: Then ``Name``
      must not appear in the argument types of the function type and the result
      type of the function type must have the form ``Name ...``.

    Positivity is necesary to avoid a declaration of the following type ::

        class Bad :=
            make: (Bad → Bad) → Bad
            --     ^     ^ positive occurrence
            --     \- negative occurrence

    which can be used to define a function with infinite recursion ::

        run: Bad → Bad := case
            \ (make f) :=
                f (make f)

        -- expression which runs forever
        run (make run)

    Note that these declaration pass the type checker except for the violated
    positivity condition.


.. rubric:: Examples

Some examples of inductive types::

    class False: Prop :=            -- No constructors!

    class Color :=
        red
        green
        blue

    class ℕ :=
        zero: ℕ
        succ: ℕ → ℕ

    class Vector (A: Any): ℕ → Any :=
        []:
            Vector zero         -- Parameter 'A' does not appear

        (::):
            all {n}: A → Vector n → Vector n

    class (≤): ℕ → ℕ → Prop :=
        start {n}: zero ≤ n
        next  {n m}: n ≤ m → succ n ≤ succ m

    class
        Accessible {A: Any} (R: A → A → Prop): A → Prop
    :=
        access {x}: (all {y}: R x y → Accessible y) → Accessible x








Mutually Inductive Types
============================================================

Inductive types can have a mutual dependency. In that case they have to be
declared in the following form ::

    -- skeleton
    mutual
        <params>                -- common parameters
    :=
        class T₁: K₁ :=
            <constructor>
            ...
        class T₂: K₂ :=
            <constructor>
            ...
        class T₃ K₃ :=
            <constructor>
            ...

    -- example
    mutual
        (A: Any)                -- common parameter
    :=
        class Tree :=
            node: A → Forest → Tree

        class Forest :=
            []      : Forest
            (::)    : Tree → Forest → Forest

Rules:

- The constructors of in the types must construct an object of the corresponding
  type.

- In the constructor argument types the mutually defined types can occur, but
  only positively.



Nested Inductive Types
============================================================


Positivity
============================================================



.. note::
    The following is DRAFT


Draft
========================================



Examples
------------------------------


.. code-block::

    mutual
        (α: Any)            -- common parameter
    :=
        class Tree :=
            node: α → Forest → Tree
        class Forest :=
            []      : Forest
            (::)    : Tree → Forest → Forest


    mutual :=
        class Even: Predicate ℕ :=
            zero        : Even zero
            even1 {n}   : Odd n → Even (succ n)
        class Odd:  Predicate ℕ :=
            odd1 {n}    : Even n → Odd (succ n)


Violated Positivity
------------------------------

::

    class Bad :=
        make: (Bad → Bad) → Bad
        --   ^ violated positivity

    run: Bad -> Bad := case
        λ (make f) := f (make f)

    -- non terminating expression

    run (make run)
