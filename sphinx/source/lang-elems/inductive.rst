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

.. _Positivity Rule:

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







.. _Mutually Inductive:

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

- The constructors of the types must construct an object of the corresponding
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


We can use an already existing inductive type nestedly within a new
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
    formulated in the section :ref:`General Inductive Types <Positivity Rule>`
    above.

    Reason: The inductive type ``TreeL`` occurs in  a positive position of the
    second argument type of the constructor ``nodeL``. However it does not occur
    immediately as ``TreeL`` but nested as ``List TreeL``.

    This is legal provided that:

    - The wrapper type (in the example ``List``) is an inductive type which is
      not mutually defined.

    - The new inductive type (in the example ``TreeL``) occurs at a parameter
      position within the wrapper type in the same way as required by the
      :ref:`original positivity rule <Positivity Rule>`.

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







Why Positivity?
============================================================

In the chapter `General Inductive Types`_ there have been given an example of
what can go wrong, if positivity is violated -- a function with infinite
recursion. In this section we are going to show that positivity guarantees
absence of endless loop or guarantees strong normalization.


Alba's type system is a superset of the extended calulus of constructions as
presented in the thesis [LuoECC]_.

One way to show that Alba's type system is sound is to show that all constructs
which are not in the extended calculus of constructions can be reduced to
constructs in the extended calculus of constructions.

In the following we demonstrate that for each inductive object which can be
constructed by constructors of an inductive type there is a corresponding church
encoding in the calculus of constructions.

We have already shown that mutually defined inductive types and nested inductive
types can all be expressed as simple inductive types. Therefore it is sufficient
to show that there is a church encoding for all simple inductive types.





Evaluation of Inductive Types
--------------------------------------------------

The constructors on an inductive type define a term language. Here we use the
example of binary trees. ::

    class Tree :=
        empty: Tree
        node:  Tree → Char → Tree → Tree

in order to construct the terms ::

    empty

    node empty 'a' empty

    node (node (node empty 'a' empty) 'b'  (node empty 'c' empty))

Since constructors look like functions (or constants) without a definition, such
a term has no meaning. We can give the term a meaning if we define a way how to
evaluate the term. Let's find a way to evaluate any tree expression to a natural
number. Then we need a way to transform the empty tree to a number and a way to
transform the combination of a number a character and a number to a new number.

The signatures of the constructor types define the signatures of the evaluation
functions.

+-------------+--------------------------------+----------------------+
| constructor | signature                      | type for eval        |
+-------------+--------------------------------+----------------------+
| empty       | ``ℕ``                          | ``ℕ``                |
+-------------+--------------------------------+----------------------+
| node        | ``Tree → Char → Tree → Tree``  | ``ℕ → Char → ℕ → ℕ`` |
+-------------+--------------------------------+----------------------+

The recipi is quite simple. We just replace each occurrence of ``Tree`` by
``ℕ``.

Now we can write an evaluation function for binary trees ::

    eval (s: ℕ) (f: N → Char → ℕ → ℕ): Tree → ℕ := case
        \ empty                 :=  s
        \ (node left c right)   :=  f (eval left) c (eval right)


Let's try the same for a type with violated positivity ::

    class Bad :=
        make: (Bad → Bad) → Bad

+-------------+--------------------------------+----------------------+
| constructor | signature                      | type for eval        |
+-------------+--------------------------------+----------------------+
| make        | ``(Bad → Bad) → Bad``          | ``(ℕ → ℕ) → ℕ``      |
+-------------+--------------------------------+----------------------+

::

    eval (e: (ℕ → ℕ) → ℕ): Bad → ℕ := case
        \ make f :=
            e (\ n := ???)

            {:  We have
                - f:    Bad → Bad
                - eval: Bad → ℕ
                There is no way to construct a natural number :}


A more complicated but well behaved type is the type of ordinal numbers ::

    class Ord :=
        start: Ord
        next:  Ord → Ord
        lim:   (ℕ → Ord) → Ord


+-------------+--------------------------------+----------------------+
| constructor | signature                      | type for eval        |
+-------------+--------------------------------+----------------------+
| start       | ``Ord``                        | ``ℕ``                |
+-------------+--------------------------------+----------------------+
| next        | ``Ord → Ord``                  | ``ℕ → ℕ``            |
+-------------+--------------------------------+----------------------+
| lim         | ``(ℕ → Ord) → Ord``            | ``(ℕ → ℕ) → ℕ``      |
+-------------+--------------------------------+----------------------+



Having this we create the evaluation function ::

    eval (z: ℕ) (n: ℕ → N) (l: (ℕ → ℕ) → ℕ): Ord → ℕ := case
        \ start     :=  z
        \ (next o)  :=  n (eval o)
        \ (lim f)   :=  l (\ n := eval (f n))

Do you see the difference to ``Bad``? In the third case we have the pattern ``l (\
n := ??)``. There is a number ``n`` which we can turn by ``f`` from the ``lim``
constructor into an ordinal number and then we use a recursive call to ``eval``
to transform the ordinal number to a natural number.


Let's define the evaluation function for ordinals generically ::

    eval
        {G: Any}                        -- goal of evaluation
        (z: G)                          -- The 3 elementary
        (n: G → G)                      -- evaluation functions
        (l: (ℕ → G) → G)                -- one for each constructor
    : Ord → G
    := case
        \ start     :=  z
        \ (next o)  :=  n (eval o)
        \ (lim f)   :=  l (\ n := eval (f n))


Now the same for the more complicated accessibility type used to define
wellfounded relations ::

    class
        Acc {A: Any} (R: A → A → Prop): A → Prop
    :=
        acc {x}: (all y: R y x → Acc y) → Acc x

    eval
        {A: Any}
        {R: A → A → Prop}
        {G: A → Prop}                   -- goal of the evaluation
        (g: all y: R y x → G y)         -- elementary evaluator for 'acc'
    :
        all {x}: Acc R x → G x
    :=
    case
        \ (acc f) :=
            g (\ rYX := eval (f rYX))






General Scheme for Evaluation
--------------------------------------------------


In general an inductive type has the form::

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

Type signature of the generic evaluation function ::

    eval
        {p₁: P₁} ...                    -- The parameters of 'Name'
        {G: all (i₁: I₁) ... : Sort}    -- Goal of the elimination
        (e₁: ...)                       -- Elementary evaluation
        (e₂: ...)                       -- functions
        ....
    :
        all i₁ i₂ ... : Name p₁ p₂ ... i₁ i₂ ... → G i₁ i₂ ...
    :=
    case
        \ (c₁ ....) := e₁ ...
        \ (c₂ ....) := e₂ ...
        ...



The goal ``F`` of the elimination has the same type as the kind of the inductive
type. The elementary elimination functions ``e₁ e₂ ...`` have the same type as
the constructors with all ``Name a₁ a₂ ...`` replaced by ``F a₁ a₂ ...``.

Since the constructors and the elementary evaluation functions have the same
structure you can call the elementary evaluation functions with the constructor
arguments. In case the constructor argument is an object of the inductive type,
we call eval recursively to evaluate it and then feed it to the elementary
evaluation function.

Since we insist on positivity this works nicely in case that the constructor
argument is a function.



Church Encodings
--------------------------------------------------

An evaluation function associated with an inductive type can be used to
translate the inductive type into a Church encoding for the type.

Each Church encoding needs a type and a function for each constructor. Since
Church encodings require impredicativity all Church encoded types live in the
``Prop`` universe.

In the following examples we prefix each Church encoded type with ``C`` to
distinguish it from the inductive type.

Each Church encoded object is a function with :math:`n + 1` arguments where
:math:`n` is the number of constructors of the inductive type. The first
argument is the goal (or the goal predicate in case of indexed types). The
following :math:`n` arguments have the same type as the arguments give to the
evaluation functions.

A Church encoded object *implements* the evaluation function.

Since typed lambda calculus is *strongly normalizing* and the execution of an
evaluation function corresponds to reducing a term in typed lambda calculus, it
is guaranteed that the execution of an evaluation function always terminates and
cannot enter into an infinite loop.


Example: Natural Number
    ::

        class ℕ :=
            zero: ℕ
            succ: ℕ → ℕ

        eval {G: Any} (z: G) (s: G → G): ℕ → G := case
            \ zero :=
                z
            \ succ n :=
                s (eval n)

        Cℕ: Prop :=                 -- Type of the Church encoding
            all {G: Any}: G → (G → G) → G

        Cℕ.zero: Cℕ :=
            \ {G} z s := z

        Cℕ.succ: Cℕ → Cℕ :=
            \ n {G} z s :=
                s (n {G} z s)

Example: List
    ::

        class List (A: Any) :=
            []: List
            (::): A → List → List

        eval {A G: Any} (nil: G) (cons: A → G → G): List A → G := case
            \ [] :=
                nil
            \ (head :: tail) :=
                cons head (eval tail)

        CList (A: Any): Prop :=
            all {G: Any}: G → (A → G → G) → G

        Clist.nil {A: Any}: Clist A :=
            \ {G} n c := n

        CList.cons {A: Any}: A → Clist A → CList A :=
            \ head tail {G} n c :=
                c head (tail G n c)


Example: Tree
    ::

        class Tree (A: Any) :=
            empty: Tree
            node:  Tree → A → Tree → Tree

        eval {A G: Any} (e: G) (n: G → A → G → G)
        : Tree A → G
        := case
            \ empty :=
                e
            \ (node left a right) :=
                n (eval left) a (eval right)

        CTree {A: Any} : Prop :=
            all {G: Any}: G → (G → A → G) → G

        CTree.empty {A: Any}: CTree A :=
            \ {G} e n := e

        CTree.node {A: Any}: CTree A → A → CTree A → CTree A :=
            \ left a right {G} e n :=
                n
                    (left {G} e n)
                    a
                    (right {G} e n)
