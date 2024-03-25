********************************************************************************
Logic
********************************************************************************





Propositions
================================================================================


.. code::

    False: Prop := all {P: Prop}: P

    (Not) (P: Prop): Prop := P -> False

    type (/\) (A B: Prop): Prop :=
        (,): A -> B -> _

    type (\/) (A B: Prop): Prop :=
        left:  A -> _
        right: B -> _


    type Exist {A: Any} (P: A -> Prop): Prop :=
        exist {w}: P w -> _



Equality
================================================================================


.. code::

    type (=) {A: Any}: A -> A -> Prop :=
        same {x}: x = x


    mapEquals
        {A B: Any}
        : all {a b: A} {f: A -> B}: a = b -> f a = f b
        -- Functions map same values to same values.
    := case
        \ same := same


    flip {A: Any}: all {a b: Any}: a = b  ->  b = a
        -- Equality is symmetric.
    :=  case
        \ same := same


    (,) {A: Any}: all {a b c: A}: a = b  ->  b = c  ->  a = c
        -- Equality is transitive.
    := case
        \ same, same := same


    replace {A: Any}: all {a b: A} {F: A -> Any}: a = b  ->  F a  ->  F b
        -- If two values are equal then the first value can be replaced
        -- by the second value in any type.
    := case
        \ same, x := x



Decisions
================================================================================

.. code::

    type Decision (A: Prop) :=
        true:  A     -> _
        false: Not A -> _


    Decider {A: Any} (P: A -> Prop): Any :=
            -- Type of a decider for a predicate
        all x: Decision (P x)

    Decider {A B: Any} (R: A -> B -> Prop) :=
            -- Type of a decider of a relation
        all x y: Decision (R x y)


A type is *decidable* if it is possible to decide if two object of that type are
equal. I.e. the type has a decider for equality.

.. code::

    abstract type Decidable (A: Any) :=
        (=): Decider ((=) {A})


If there is an endorelation between two objects of a certain type then it might
be possible to compare the two objects.

.. code::

    type Comparison {A: Any} (R: A -> A -> Prop) (x y: A) :=
        lt:  R x y -> Not R y x -> _
        eqv: R x y -> R y x     -> _
        gt:  R y x -> Not R x y -> _


    Comparer {A: Any} (R: A -> A -> Prop): Any :=
        all x y -> Comparison R x y


    abstract type Comparable {A: Any} (R: A -> A -> Prop) :=
        compare: Comparer R



Refinement
================================================================================

An object of a refinement type of type ``A`` is an object of type ``A`` and a
proof that the object satisfies a certain predicate ``P``. The refinement type
is like the exisitence type with the difference that the witness is not a ghost
object.

.. code::

    type Refine {A: Any} (P: A -> Prop): Any :=
        (,) {w}: P w -> Refine
