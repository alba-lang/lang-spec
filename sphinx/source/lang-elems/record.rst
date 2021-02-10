.. _Records:

************************************************************
Records
************************************************************



Simple Records
============================================================


Record Declaration
------------------------------------------------------------


Records are just :ref:`inductive types <Inductive Types>` with one nameless
constructor. Therefore it is sufficient to list the arguments with their names.

General form of a record definition::

    record
        Name <params>: Sort     -- The optional sort is 'Prop' or 'Any'
    :=                          -- If ommitted 'Any' is used.
        field₁: Type₁
        field₂: Type₂
        ...

    -- equivalent inductive type
    class
        Name <params>: Sort
    :=
        _: all (field₁: Type₁) (field₂: Type₂) ... : Name
    --  ^  nameless constructor


For a record definition the compiler declares the field accessor functions ::

    Name.field₁: Name <params> → Type₁
    Name.field₂: Name <params> → Type₂
    ...

The field accessor functions are declared in the namespace of the record.



E.g. the declaration

::

    record Person :=
        firstName: String
        lastName: String
        age: Int

defines the algebraic type
::

    class Person :=
        mk: String -> String -> Person
    --  ^ just an arbitrary constructor name chosen

with the additional functions
::

    Person.firstName: Person -> String := case
        λ (mk name _ _) := name

    Person.lastName: Person -> String := case
        λ (mk _ name _) := name

    Person.age: Person -> String := case
        λ (mk _ _ age) := age





Record Expressions
------------------------------------------------------------

There are no constructor names for records. But there are record expressions
which allow the construction or record objects.

::

    record ["John", "Boy", 5]           -- exact order, like a list.

    record {age := 5, lastName := "Boy", firstName := "John"}
        -- arbitrary order, like a set.



In case of ambiguity we add a type or a namespace annotation
::

    record ["Billy", "Boy", 3]: Person

    Person.record ["Billy", "Boy", 3]



Updating record fields is nondestructive and is done with the syntax:
::

    record {person; age := age person + 1}

This expression creates a copy of the record ``person`` with the field ``age``
updated. One or more fields can be updated.





Record Pattern Match
------------------------------------------------------------

Since records are just a special kind of inductive types, they can be
:ref:`pattern matched <Pattern Match>`. Because of the absence of a constructor
name, record expressions of the form ``record [field₁, field₂, ...]`` can be
used as pattern.

E.g. with the record ::

    record Refine {A: Any} (P: A → Prop) :=
        value: A
        proof: P value

we can pattern match
::

    f {A: Any} {P: A → Prop}
    : Refine P → T
    := case
        \ record [v, prf] :=
            expr            -- any expression using 'v' and 'prf'
                            -- and returning a 'T'




Dependent Records
============================================================

Records can have dependent types
::

    record Sigma {A: Any} (P: A → Prop) :=
        value: A
        proof: P value

    -- corresponding inductive type
    class Sigma {A: Any} (P: A -> Prop) :=
        _ x: P x -> Sigma

    -- field accessor functions
    value {A: Any} {P: A → Prop}: Sigma P → A := case
        λ record [x, _] := x

    proof {A: Any} (P: A → Prop}: all (s:Sigma P) → P (value s) := case
        λ record [_, p] := p



Field update of dependent records have to be done consistently. I.e. if the type
of one field depends on the value of another field, then both have to be
updated.

It is possible to mark some fields as implicit. Then the corresponding values in
record constructions or record updates have to be ommitted or marked as
implicit.
