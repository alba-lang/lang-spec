.. _Abstract Data Types:

************************************************************
Abstract Data Types
************************************************************


Abstract data types are a special kind of :ref:`records <Records>` with a
carrier type ::

    abstract class
        Monoid (A: Any)         -- 'A' is carrier type
    :=
        {unit: A}
        {(+): A -> A -> A}
        (leftNeutral:  all x: unit + x = x)
        (rightNeutral: all x: x + unit = x)
        (associative:  all x y z: x + y + z = x + (y + z))

Note that we have declared ``unit`` and ``+`` as implicit, since they are used
in the types of the laws.

Objects of an abstract type are constructed with a record expression ::

    record [{zero}, {(+)}, ...]: Monoid ℕ       -- proof objects ommitted


Declaring a record with a carrier type as an abstract type has the advantage to
declare nameless instantiation of the objects ::

    _: Monoid ℕ :=
        record (ℕ.zeroLeftNeutral, ℕ.zeroRightNeutral, ℕ.plusAssociative)

Arguments of an abstract type like ``Monoid A`` can be made implicit in
functions. The compiler finds the corresponding instantiation or reports an
error, if no instantiation is available for the actual carrier.

Rule:
    At most one instance can be defined of a specific carrier of an abstract
    type.
