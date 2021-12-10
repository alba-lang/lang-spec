********************************************************************************
Module: alba.core.logic
********************************************************************************

.. code-block::

    Predicate (A: Any): Any := A → Prop

    Relation (A B: Any): Any := A → B → Prop

    Endorelation (α: Any): Any := Relation α α

    class (=) {A: Any} (x: A): Predicate A :=
        identical: (=) x

    class Exist {A: Any} (P: Predicate A): Prop :=
        exist {x}: P x → Exist

    class False: Prop :=     -- no constructor

    class True: Prop  := trueValid: True

    (¬) (A: Prop): Prop := A → False

    class (∧) (A B: Prop): Prop :=
        (,): A → B → (∧)

    class (∨) (A B: Prop): Prop :=
        left  : A → (∨)
        right : B → (∨)

    class Accessible {A: Any} (R: Endorelation A): Predicate A :=
        access {x}: (∀ y, R y x → Accessible y) → Accessible x
