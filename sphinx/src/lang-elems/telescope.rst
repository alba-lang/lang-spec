.. _Telescopes:

************************************************************
Telescopes / Formal Arguments
************************************************************

A *telescope* is a list of formal arguments declared with a name and a
type ::

    (x₁: A₁) (x₂: A₂) ...

where the argument type ``An`` can depend on the arguments ``x_i`` coming before
the ``n``\ th argument.

Telescopes are used in various constructs ::

    -- function type
    all <telescope>: <type>

    -- anonymous function
    \ <telescope> : <type> := <expression>

    -- named function
    name <telescope>: <type> := <expresssion>

    -- inductive type
    class <name> <telescope>: <kind> :=
        ...
        ...

Sometimes an empty telescope is possible, sometimes the telescope must be
nonempty.

Some of the arguments might be marked as :ref:`implicit <Implicit Arguments>`
i.e. enclosed within braces ::

    (x₁: A₁) ... {x₄: A₄} (x₅: A₅) ...
    --            ^ implicit argument 'x₄'


In not fully elaborated telescopes the types can be omitted. In case of an
untyped argument, the parentheses (but not the braces) can be omitted as well.

If some subsequent arguments have the same type, they can be grouped. Examples
::

    {A B: Any} (xs ys: List A) ...

    {A B} (xs ys: List A) ...       -- grouping of implicits without type
                                    -- is allowed
