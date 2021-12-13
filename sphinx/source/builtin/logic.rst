********************************************************************************
Module: alba.core.logic
********************************************************************************



Axioms and Builtin Definitions
================================================================================

.. code-block::

    Predicate (A: Any): Any := A -> Prop

    Relation (A B: Any): Any := A -> B -> Prop

    Endorelation (A: Any): Any := Relation A A

    class Exist {A: Any} (P: Predicate A): Prop :=
        exist {x}: P x -> Exist

    class False: Prop :=     -- no constructor

    class True: Prop  := trueValid: True

    (Not) (A: Prop): Prop := A -> False

    class (=) {A: Any} (x: A): Predicate A :=
        identical: (=) x

    (/=) {A: Any} (a b: A): Prop :=
        Not (a = b)

    class (/\) (A B: Prop): Prop :=
        (,): A -> B -> (/\)

    (<->) (A B: Prop): Prop
        -- 'A <-> B': 'A' and 'B' are logically equivalent
    :=
        (A -> B) /\ (B -> A)

    class (\/) (A B: Prop): Prop :=
        left  : A -> (\/)
        right : B -> (\/)

    class Accessible {A: Any} (R: Endorelation A): Predicate A :=
        access {x}: (∀ y, R y x -> Accessible y) -> Accessible x



Equality
================================================================================


.. code-block::

    (=).flip {A: Any}: all {a b: A}: a = b -> b = a
        -- Equality is symmetric.
    := case
        \ identical := identical


    (=).(+) {A: Any}: all {a b c: A}: a = b -> b = c -> a = c
        -- Equality is transitive.
    := case
        \ identical identical := identical


    (=).inject
        {A: Any} {P: A -> Any} (f: all x: P x)
        : all {a b}: a = b -> f a = f b
        -- Equal arguments to a function imply equal results.
    := case
        \ identical = identical
