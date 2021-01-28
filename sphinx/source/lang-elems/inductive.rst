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

.. _Positivity:

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
        class T₃: K₃ :=
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



Mutually defined inductive types are just a convenience. They do not make the
language more expressive. For each set of mutually defined inductive types there
exists one inductive type with one index more than the mutually defined
inductive types which is isomorphic to the mutually defined inductive types.

For the above examples of ``Tree`` and ``Forest`` we define and index type and a
type which includes both ::

    class Index := tree; forest

    class TF (A: Any): Index → Any :=
        tf_nil  :   TF forest

        tf_node :   A → TF forest → TF tree

        tf_cons :   TF tree → TF forest → TF forest


In order to show that both definition are isomorphic we make functions
``treeToTF`` and ``treeToForest`` which transform ``Tree`` and ``Forest`` into
``TF`` and the functions ``tfToTree`` and ``tfToForest`` which do the
transformation in the other direction.

First ``treeToTF`` and ``forestToTF`` which must be mutually recursive, because
``Tree`` and ``Forest`` are mutually defined ::

    mutual {A: Any}
    :=
        treeToTF: Tree A → TF A tree := case
            \ (node a f) :=
                tf_node a (forestToTF f)

        forestToTF: Forest A → TF A forest := case
            \ [] :=
                tf_nil
            \ (t :: f) :=
                tf_cons (treeToTF t) f


Then the backward direction ::

    mutual {A: Any}
    :=
        tfToTree: TF A tree → Tree A := case
            \ (tf_node a t) :=
                node a (tfToForest f)

        tfToForest: TF A forest → Forest A := case
            \ tf_nil :=
                []
            \ (tf_cons t f) :=
                (tfToTree t) :: (tfToForest f)


Note that in the backward direction only the pattern clauses which are possible
have to be present. For details see chapter :ref:`Pattern Match`.












Nested Inductive Types
============================================================


We can use an already existing inductive type use it nestedly within a new
inductive type. A simple example is a tree whose children (aka forest) are
implemented as a list of trees.

::

    class TreeL (A: Any) :=
        nodeL: A → List TreeL → TreeL
    --                  ^^^^^
    --                  positive occurrence of 'TreeL', but nested
    --                  within 'List'


Modified Positivity:
    The above definition of ``TreeL`` violates the positivity condition
    formulated in the section :ref:`General Inductive Types <Positivity>` above.

    Reason: The inductive type ``TreeL`` occurs in  a positive position of the
    second argument type of the constructor ``nodeL``. However it does not occur
    immediately as ``TreeL`` but nested as ``List TreeL``.

    This is legal provided that:

    - The wrapper type (in the example ``List``) is an inductive type which is
      not mutually defined.

    - The new inductive type (in the example ``TreeL``) occurs at a parameter
      position within the wrapper type in the same way as required by the
      :ref:`original positivity rule <Positivity>`.

    - The used parameter of the wrapper type appears in all arguments of all
      constructors of the wrapper type only positively.


As with mutually defined inductive types, nested inductive types do not make the
language more expressive. The nesting is just for convenience. There is always a
collection of mutually inductive types which are equivalent with the nested
inductive type.


Construction of the Equivalent Types:
    - Add the wrapper type applied to the newly defined inductive type as an
      additional mutually defined type.

    - The constructors of the wrapper type become constructors of the added
      inductive type with the parameter properly substituted.


For the example ``TreeL`` the equivalent mutual definition is ::

    mutual (A: Any) :=
        class Tree :=
            node: A → Forest → Tree
        class Forest :=
            []: Forest
            (::): Tree → Forest → Forest

In order to prove the equivalence we define functions which do the forward and
backward transformation between the types ::

    mutual {A: Any} :=
        treeToTreeL: Tree A → TreeL A := case
            \ (node a f) :=
                nodeL a (forestToTreeL f)

        forestToTreeL: Forest A → List (TreeL A) := case
            \ [] :=
                List.[]
            \ (t :: f) :=
                List.( treeToTreeL t :: forestToTreeL f)

    mutual {A: Any} :=
        treeLtoTree: TreeL A → Tree A := case
            \ (nodeL a f) :=
                Tree.(node a (treeLtoForest f))

        treeLtoForest: List (TreeL A) → Forest A := case
            \ [] :=
                Forest.[]
            \ (t :: f) :=
                treeLtoTree f :: treeLtoForest f







Positivity
============================================================
