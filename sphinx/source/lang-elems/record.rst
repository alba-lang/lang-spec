.. _Records:

************************************************************
Records
************************************************************



Simple Records
============================================================



Records are just :ref:`inductive types <Inductive Types>` with one nameless
constructor. Therefore it is sufficient to list the arguments with their names.

The declaration

::

    record Person :=
        (firstName: String)
        (lastName: String)
        (age: Int)

defines the algebraic type
::

    class Person :=
        mk: String -> String -> Person
    --  ^ just an arbitrary constructor name chosen

with the additional functions
::

    firstName: Person -> String := case
        λ (mk name _ _) := name

    lastName: Person -> String := case
        λ (mk _ name _) := name

    age: Person -> String := case
        λ (mk _ _ age) := age



We construct records with a record expression
::

    record ("John", "Boy", 5)       -- exact order!

    record (age := 5, lastName := "Boy", firstName := "John")



In case of ambiguity we add a type annotation
::

    record ("Billy", "Boy", 3): Person

Updating record fields is easy
::

    record (p; age := age p + 1)





Dependent Records
============================================================

Records can have dependent types
::

    record Sigma {A: Any} (P: A → Prop) :=
        (value: A)
        (proof: P value)

    -- corresponding inductive type
    class Sigma {A: Any} (P: A -> Prop) :=
        sigma x: P x -> Sigma

    -- field accessor functions
    value {A: Any} {P: A → Prop}: Sigma P → A := case
        λ (sigma x _) := x

    proof {A: Any} (P: A → Prop}: all (s:Sigma P) → P (value s) := case
        λ (sigma _ p) := p



Field update of dependent records have to be done consistently. I.e. if the type
of one field depends on the value of another field, then both have to be
updated.

It is possible to mark some fields as implicit. Then the corresponding values in
record constructions or record updates have to be ommitted or marked as
implicit.
