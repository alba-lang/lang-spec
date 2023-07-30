********************************************************************************
Logic
********************************************************************************





Propositions
================================================================================


.. code::

    False: Prop := all {P: Prop}: P

    (Not) (P: Prop): Prop := P -> False

    type (/\) (A B: Prop): Prop :=
        (,): A -> B -> (/\)

    type (\/) (A B: Prop): Prop :=
        left:  A -> (\/)
        right: B -> (\/)


    type Exist {A: Any} (P: A -> Prop): Prop :=
        (,) {w}: P w -> Exist



Decisions
================================================================================

.. code::

    type Decision (A: Prop) :=
        true:  A     -> Decision
        false: Not A -> Decision


    Decider {A: Any} (P: A -> Prop): Any :=
        all x: Decision (P x)




Refinement
================================================================================

An object of a refinement type of type ``A`` is an object of type ``A`` and a
proof that the object satisfies a certain predicate ``P``. The refinement type
is like the exisitence type with the difference that the witness is not a ghost
object.

.. code::

    type Refine {A: Any} (P: A -> Prop): Any :=
        (,) {w}: P w -> Refine



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
