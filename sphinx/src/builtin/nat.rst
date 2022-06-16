********************************************************************************
Module: alba.core.nat
********************************************************************************




Axioms and Builtin Definitions
================================================================================

.. code-block::

    Nat: Any

    Nat.zero: Nat
    Nat.one:  Nat

    Nat.toNatural:   Nat -> Nat
    Nat.fromNatural: Natural -> Nat

    Nat.embed (a: Nat): fromNatural (to natural a) = a

    Nat.(+): Nat -> Nat -> Nat
    Nat.(*): Nat -> Nat -> Nat

    Nat.(=?): all (a b: Nat): Decision (a = b)

    Nat.(<=): Nat -> Nat -> Prop
    Nat.(<=?): all (a b: Nat): Decision (a <= b)

    Nat.zeroDefinition: zero = fromNatural zero
    Nat.oneDefinition:  one  = fromNatural one

    Nat.plusDefinition {a b: Nat}:
            a + b = fromNatural (toNatural a + toNatural b)

    Nat.multDefinition {a b: Nat}:
            a * b = fromNatural (toNatural a * toNatural b)

    Nat.leDefinition {a b: Nat}: a <= b <-> toNatural a <= toNatural b


Embedding into Natural Numbers
================================================================================

An embedding is always injective. Therefore we can prove that ``toNatural`` is
injective by the embedding property and properties of equality.

.. code-block::

    Nat.injective {a b: Nat}: toNatural a = toNatural b -> a = b
    :=
        \ eq :=
            (=).(
                flip (embed {a})            -- a = fromNatural (toNatural a)
                +
                inject fromNatural eq
                +
                embed {b}                   -- fromNatural (toNatural b) = b
            )
