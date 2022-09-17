.. _E_pattern_match:

********************************************************************************
Pattern Match
********************************************************************************

Two tasks:

- Elaborate a pattern match expression

- Reduce a pattern match expression: The type of a pattern match expression is a
  function type. When a pattern match expression is applied to its arguments we
  have to be able to

  - decide the pattern clause
  - bind the pattern variables of the pattern clause to subexpressions of the
    arguments
  - evaluate the body of the pattern clause with the variables bound to
    subexpressions



Syntax
================================================================================

A pattern match expression consists of an optional name (to be used for
recursive calls), an optional type and a list of pattern clauses.

.. code::

    case
        f                                 -- optional name
        { all (x1: A1) (x2: A2) ... : R } -- optional type
        \ p11 p12 ... := e1         -- one pattern for each explicit argument
        \ p21 p22 ... := e2
        ...
        \ pn1 pn2 ... := en

Pattern match expressions can be mutually recursive:

.. code::

        mutual
            case f1 {T1}
                ...
                ...
            case f2 {T2}
                ...
                ...


Syntax of pattern:

.. code::

    pattern ::=
        | constant          -- "hello", 'A', -35, 1.0
        | name              -- variable or constructor
        | { name }          -- variable
        | ( compound )

    compound ::=
        | name := general   -- deep inspection, e.g. a := x :: b
        | general

    general ::=
        | pattern
        | name pattern+  -- or in operator form e.g. 'pattern :: pattern'




Pattern Reduction
================================================================================

A pattern match expression can be reduced if it is in the following form:

.. code::

    (case {all (x: A): R} [\ p1 := e1, \ p2 := e2, ... , \ x := ex])
        a1
        a2
        ...

    -- where 'a1 = c ...' if there are explicit pattern and 'c' is a constructor

- Only one pattern is allowed in each clause.

- If the pattern clauses are not exhaustive, then there has to be a final
  default clause.

- No nested pattern i.e. each pattern clause except the default clause matches
  on one constructor where all arguments are variables.

- If there constructor pattern, then the first argument ``a1`` has to be a
  constructor application.

In order to reduce the expression we have to distinguish the following 2 cases:

1. ``c`` does not match any explicit pattern or there are no explicit pattern.
   The pattern match expression reduces to

    .. code::

        ex[x := a1] a2 a3 ...

2. ``c`` matches the explicit pattern ``pi``. Then ``a1`` and ``pi`` have the form:

    .. code::

        pi = (y := c {q1} {q2} ... y1 y2 ...)
        a1 = c {q1} {q2} ... b1 b2 ...

    Note that the parameters in the pattern and the argument have to be
    equivalent. Otherwise the pattern match expression wouldn't be welltyped.
    The pattern match expression reduces to

    .. code::

        ei[y:=a1, y1:=b1, y2:=b2, ...] a2 a3 ...






Pattern Elaboration
================================================================================

Before elaborating a pattern match expression, the type of the pattern match
expression has to be elaborated. Here we assume that we have an elaborated type
of the pattern match expression::

    all (x1: A1) (x2: A2) ... : R

Some of the arguments in the type of the pattern match expression might be
implicit. All implicit arguments have to be inferable i.e. they have to occur
either in one of the subsequent argument types or in the result type::

    all ... {xi: Ai} ... : R                -- 'xi' occurs in 'R'
    all ... {xi: Ai} ... (xj: Aj) ... : R   -- 'xi' occurs in 'Aj'

Implicit arguments in the type can only be matched by variable patterns. Reason:
All values corresponding to implicit arguments are erased i.e. not availalble at
runtime. Therefore no branching can be done depending on the value of implicit
arguments.

There might be inferable variables which are not implicit. The values
corresponding to explicit variables are available at runtime. Therefore
constructor patterns are possible. However since they are inferable, there might
be constraints to be satisfied.

In order to elaborate a pattern match expression we have to elaborate each
pattern clause separately. For each pattern clause the elaboration generates:

- ``G = [v1: V1, v2: V2, ...]``: pattern variables. Each pattern variable is
  represented by a metavariable.

- ``[p1, p2, ...]``: list of pattern expressions using pattern variables

- ``e``: body of the clause using pattern variables




Data:
    .. code::

        all (x: A): R       -- type
             ^
             |
             p              -- pattern to elaborate


        G = [v1: V1, v2: V2, ... ]          -- pattern variables (metavariables)
        ps = [p1, p2, .... ]                -- elaborated pattern expressions

    We use metavariables as pattern variables because the pattern variables
    might be subject to constraints.

Start:
    .. code::

        all (x1: A1) (x2: A2) ... : R   -- type of the pattern match expression
             ^
             |
             p                          -- pattern to elaborate

        G =  []
        ps = []


The argument in the type is implicit, but the pattern not:
    I.e. the type has the form ``all {x: A}: R``. Since the pattern is not
    implicit, the pattern does not correspond to this type.

    - Introduce a fresh metavariable ``?m`` for the pattern.

    - Do the substitution ``R[x := ?m]``.

    - Add ``{ ?m }`` to the patterns ``ps``.


Pattern is an implicit argument:
    I.e. ``p = { name }``.

    In that case the type has the form ``all {x: A}: R``.

    - Introduce a metavariable ``name``.

    - Do the substitution ``R[x := name]``.

    - Add ``{ name }`` to the patterns ``ps``.


Pattern is a constant:
    I.e. it is either a string, a character or a number.

    The type ``A`` has to be compatible with the type of the constant. We make
    the substitution ``R[x := constant]``.


Pattern is a constructor name:
    This is possible only if ``A`` is an inductive type. Same as *constructor
    pattern* with zero arguments (see below).

Pattern is a name but not a constructor:
    The name is a pattern variable and added to the pattern
    variables i.e. we add ``name: A`` to the pattern variables and make the
    substitution ``R[x := name]``.


Pattern is a constructor pattern:
    I.e. the pattern has the form ``name p1 p2 ...``.

    In this case the type ``A`` must have or reduce to the form ``A = I
    q d`` where ``I`` is an inductive type, ``q`` are the actual parameter
    arguments and ``d`` are the actual index arguments.

    The name must be one of the constructor names of the inductive type.

    The type of the constructor has the general form ``all (b1: B1) (b2: B2) ...
    : I a`` where all formal parameters have been replaced by the actual
    parameters ``q``.

    - Elaborate ``p1``, ``p2``, ... iteratively starting with the type ``all
      (b1: B1): R`` where ``R = all (b2: B2) ... : I a``.

    - At the end of elaborating ``p1``, ``p2``, ... we get the constructed type
      ``I a`` where all arguments ``b1``, ``b2``, ... have been replaced by the
      corresponding pattern.

    - Unify ``a`` and ``d`` which might instantiate some pattern variables.

    - The pattern is ``c q p1 p2 ...`` where ``c`` is an expression
      representing the corresponding constructor, ``q`` are the actual
      parameters (usually implicit)  and ``p1``, ``p2``, ... are the constructed
      patterns.

    - Make the substitution ``R[x := c q p1 p2 ...]``.


At the end of the elaboration of the patterns we have for a pattern clause::

    G  = [v1: V1, v2: V2, ...]      -- a sequence of pattern variables
    ps = [p1, p2, ... ]             -- a sequence of elaborated pattern

It remains to elaborate the right hand side of the pattern clause.




Pattern Compilation
================================================================================
