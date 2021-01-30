.. _Types:

************************************************************
Types
************************************************************

A type in head normal for is either a simple type or a function type. ::

    -- Simple types
    Prop
    Any
    Any <level>
    Level
    <name> ...                  -- zero or more arguments

    -- function type
    all <telescope>: <simple type>      -- function type



For details of levels see chapter :ref:`Universes`.



A type in head normal form is either a **proper type** or a **kind**. A proper
type is either ``<name> ...`` or ``all <telescope>: name ...``. The other types
are kinds.

The typing rules do not allow types of the form ``all <telescope>: Level``.

In case that variables in a function type do not occur in other argument types
or in the return type, arrow notation can be used as an abbreviation. ::

    all (_: A) (_: B) ... : R
    --   ^      ^   variables do not occur in the remainder of the type

    -- equivalent type
    A → B → ... → R

I.e. ``A → B`` is just an abbreviation for ``all (_: A): B``.


The following type expressions are equivalent::

    all (x₁: A₁) (_: A₂) (x₃: A₃) ... : R

    all (x₁: A₁): all (_: A₂): all (x₃: A₃): ... : R

    all (x₁: A₁): A₂ → all (x₃: A₃): ... : R
