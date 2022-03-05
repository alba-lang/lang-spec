.. _Pattern Match:

********************************************************************************
Pattern Match
********************************************************************************


Syntax
================================================================================

The general form of a pattern match expression:

.. code-block::

    case
        { ∀ (x₁: A₁) (x₂: A₂) ... : R }             -- optional type
        λ (p₁₁: A₁₁) (p₁₂: A₁₂) ... : R₁ := e₁      -- pattern clauses
        λ (p₂₁: A₂₁) (p₂₂: A₂₂) ... : R₂ := e₂
        ...


Type annotations for the pattern and the results in the pattern match expression
are optional. Note that ``R`` can be a function type of the form ``∀ (y: B):
C``.

Pattern can be explicit (``p`` or ``(p: A)``) or implicit (``{p}`` or ``{p:
A}``.



Syntax for pattern::

    p   ::=     identifier/operator
        |       _
        |       constant            -- number, character, string
        |       p p


I.e. a pattern is a head term (identifier, operator, _, constant) followed by
zero or more argument pattern with the restriction that ``_`` and constants
cannot have arguments. Operators can be used in prefix or infix form. In the
abstract syntax we use only the prefix form.

Example::

    case
        { List (ℕ, String) → ℕ }

        λ (::) ((,) (succ i) "hello") ((::) ((,) x _) _     -- prefix form
        :=
            i + x

        λ (succ i, "hello") :: (x,_) :: _                   -- infix form
        :=
            i + x



Type
================================================================================


The type of a pattern match
expression is a function type which has the general form

.. code-block::

    ∀ (x₁: A₁) (x₂: A₂) ... : R

    -- example

    ∀ {n m}: succ n ≤ succ m → n ≤ m

    -- in long form

    ∀ {n m: ℕ} (_: succ n ≤ succ m): n ≤ m


Note that type annotations can be ommitted as long as the compiler can infer
them and ``A → B`` is a shorthand for ``∀ (_: A): B``. Braces are used to mark
implicit arguments.

Variables which occur in types are inferrable variables and the corresponding
types are dependent types. In the example ``n`` and ``m`` are inferrable
variables and ``succ n ≤ succ m`` and ``n ≤ m`` are dependent types.

In a type of a pattern match expression, all implicit variables must be
inferrable variables. The reverse is not true in general.




Rules
================================================================================

Distinct pattern variables:
    All variables used in the explicit pattern of the same pattern clause have
    to be distinct.

    Variables in inferable pattern of the same pattern clause need not be
    distinct.


Number of pattern:
    The number of arguments in the type and the number of matched patterns in
    each line must be the same.

    However if there are implicit arguments in the type, the corresponing pattern
    in the pattern match lines can be ommitted because the compiler can infer
    them.

    The compiler adds wildcard arguments ``{_}`` for the missing implicit
    arguments in the pattern clauses.


Implicit arguments in braces:
    The pattern corresponding to implicit arguments in the type of the pattern
    match expression have to be put in braces.


Type completeness:
    All variables occuring in the types ``A₁, A₂, ..., R`` (i.e. all *inferable*
    variables) of the type must occur as variables in the type. E.g. the type
    ``n ≤ m`` is not a legal type of a pattern match expression. ``∀ {n m}: n ≤
    m`` is a legal type.


Welltyped:
    The types in the ``i``\ th pattern clause (``Ai₁ Ai₂ ... Ri``) must be
    unifiable with the corresponding types (``A₁ A₂ ... R``) of the type of the
    pattern match expression where all inferable variables are considered as
    unification variables.

    This consistency requirement excludes pattern clauses with some pattern
    combinations where the types of the pattern clause are not unifiable with the
    corresponding types in the type of the pattern match. In the extreme case
    there are no allowed pattern clauses and the pattern match is empty.

    For the details of type checking see section :ref:`welltyped`.


Exhaustive:
    For all possible arguments which do not contain variables at least one of
    the pattern clauses must match. The check for being exhaustive can be done
    by transforming a pattern match expression into its canonical form (see
    section :ref:`canonical-forms`). For the details to check exhaustiveness see
    section :ref:`exhaustiveness`.

Reachable:
    All clauses must be reachable. I.e. for each clause there is at least one
    set of arguments which matches the clause and fails to match all previous
    clauses.





.. _welltyped:

Welltyped
================================================================================

The general form of a pattern match expression is ::

    case
        { ∀ (x: A) (y: B) ... : R}
        λ p q ... := e
        ...

where ``p`` and ``q`` are pattern. For each argument in the type ``(x: A)``
there is a corresponding pattern ``p``.

In order to typecheck a clause we typecheck from left to right all arguments and
finally the result type. We consider all variables in the type as substitutable.
Each typecheck step for one argument replaces the coresponding variable in the
type by an expression from the pattern.

At the start of the checking we have all variables in the type unassigned. In
the ``i``\ th step all variables before the ``i``\ th variable of the type are
assigned. We look at the ``i``\ th argument and the corresponding pattern. ::

    -- explicit argument                    implicit argument
    ∀ (x: A): R                             ∀ {x: A}: R
    λ p := ...                              λ {p}

Note that the variables in the type before ``x`` can occur in the type ``A`` and
they have already been replaced by their corresponding expressions. ``R``
represents the remaining type where all substitutions have been done as well.

If an implicit argument in the type does not have a corresponding pattern, we
add the wildcard pattern ``_``.

In order to elaborate the pattern we have to distinguish various cases:

- Head term is a constant: For a number ``A`` has to be a numerical type.
  For a character ``A`` has to be ``Char``. For a string ``A`` has to be
  ``String``. Constants cannot have argument pattern.

- Head term is a wildcard ``_``: In that case no argument pattern are allowed.
  We introduce a metavariable ``?m: ∀ (v0: V0) (v1: V1) ... : A`` where ``v0``,
  ``v1``, ... are all pattern variables introduced up to now and the pattern
  ``p`` is elaborated as ``?m v0 v1 ...``. The elaborated pattern has the type
  ``A`` by construction.

- Head term is an identifier which is an already introduced pattern variable:
  This is allowed only if the type of the pattern variable is unifiable with
  ``A`` and the identifier represents an implicit argument. The implicitness is
  necessary in order to have some unification which will verify the sameness of
  the pattern in both positions.

- Head term is an identifier which is not a constructor of the type ``A``: In
  that case no argument pattern are allowed. We introduce a new pattern variable
  ``v`` of type ``A``. The elaborated pattern has the type ``A`` by
  construction.

- Head term is an indentifier which is a constructor of the inductive type
  ``A``. The implicit arguments which represent the parameters of the inductive
  type have to match exactly the parameters of the inductive type ``A``.

  Then we construct recursively each argument pattern of the constructor
  arguments.

  Finally we unify the actual type of the expression ``id p0 p1 ...`` with the
  required type ``A`` and in case of success replace the variable ``x`` in
  the type by the elaborated expression ``id p0 p1 ...``.


After the successful elaboration of all pattern there might remain some
unassigned metavariables. Unassigned metavariables ``?m`` occur only in the form
``?m v0 v1 ...`` where ``v0``, ``v1`` are pattern variables which existed at the
point of the introduction of the metavariable. For each pattern ``?m v0 v1 ...``
we introduce a new pattern variable of the correponding type and replace the
pattern by the pattern variable.

As a last step the expression ``e`` has to be elaborated with the required type
``R``. Note that at that point of the elaboration all variables in the type of
the whole pattern match expression have already been replaced by expressions
depending only on pattern variables.




.. _canonical-forms:

Canonical Forms
================================================================================

The transformation into canonical form works by case splitting on variable
pattern, reordering of the pattern clauses and dropping of non reachable
clauses.



Focus of Subsequent Clauses
---------------------------

We consider two pattern as equivalent if the have the same structure and only
have different variables at the same position. Furthermore inferable pattern are
always considered as equivalent.

The pattern in focus of two subsequent clauses is the first pattern on which
both clauses are different. If there is no focal pattern, then the second one is
unreachable.

The focal point of two pattern is the first subpattern when scanned from left to
right where they are different. The difference can be because of two different
constructors at the focal point or a constructor and a variable at the focal
point.




Reorder Clauses
---------------

We reorder clauses in order to transform them into the lexicographic order. The
order is induced by the order in which the constructors are introduced in the
corresponding inductive type.

We swap the order of two subsequent clauses if there is a focal pattern where
both have a constructor at the focal point and the constructor of the second
clause comes before the constructor in the first clause in the corresponding
inductive type.

Examples of *out of order* clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...
    --           ^ focal point with out of order constructors

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ zero    ) ...     := ...
    --                ^ focal point with out of order constructors

The swapping of the clauses does not change the semantics of the pattern match
expression.



Split a Variable Pattern
------------------------

Case splitting of a variable occurs if we have two subsequent clauses with a
focal point where one has a constructor at the focal point and the other
has a variable at the focal point.


Examples of overlapping clauses::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...
    --          ^ focal point with overlap

    λ p₁ p₂ ... (succ m       ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    --                ^ focal point with overlap

We do a case split on the variable. The case splitting does not change the
semantics of the pattern match expression.


Example 1::

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... m               ...     := ...
    --          ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (zero         ) ...     := ...
    λ p₁ p₂ ... (succ m       ) ...     := ...


Example 2::

    λ p₁ p₂ ... (succ m       ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    --                ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... (succ zero    ) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...
    λ p₁ p₂ ... (succ (succ n)) ...     := ...



Example 3::

    λ p₁ p₂ ... zero        ...                := ...
    λ p₁ p₂ ... m           ...     := ...
    --          ^ focal point with overlap

    -- case split 'm'

    λ p₁ p₂ ... zero        ...     := ...
    λ p₁ p₂ ... zero        ...     := ...
    λ p₁ p₂ ... (succ m)    ...     := ...





Transform into Canonical Form
------------------------------

Definition of *canonical form*:
    A pattern match expression is in canonical form if there are no two
    subsequent clauses with a focal pattern where the pattern are out of order
    or overlapping.


Transformation into *canonical form*:
    Search for a focal pattern in two subsequent clauses and do a reordering or
    a case splitting until no more focal pattern which are out of order or
    overlapping can be found in subsequent clauses.


It remains to be shown that the algorithm terminates.

The pattern match expression has an initial maximal constructor nesting
:math:`m`. This maximal constructor nesting :math:`m` remains constant during
the algorithm

Proof:
    A reordering does not change the maximal constructor nesting.

    A variable case split does not change the maximal constructor nesting.
    During a variable case split, the splitted clauses have a new constructor at
    the place of the variable. At that place the other clause had already a
    constructor.  Therefore the maximal constructor nesting does not change.


Now we create a sequence of numbers :math:`n_0 n_1 n_2 \ldots n_m i` for each
step. :math:`n_k` is the number of variables which are nested below :math:`k`
constructors and :math:`i` is the number of out of order clauses in the pattern
match expression. Clearly there cannot be any variable nested below more than
:math:`m` constructors, because :math:`m` is the maximal constructor nesting
during the algorithm.

We consider a lexicographic order on the sequence :math:`n_0 n_1 n_2 \ldots n_m
i` and claim that this sequence decreases lexicographically at each step of the
algorithm.

Proof:
    Reordering does not change :math:`n_0 n_1 \ldots n_m`, it only decreases
    :math:`i`.

    Variable case splitting decreases the sequence lexicographically. The
    case splitted variable occurs at a certain nesting depth :math:`k`. After
    the split the number :math:`n_k` has decreased by one. The numbers
    :math:`n_{k+1} \ldots n_m i` might increase. But the number :math:`n_k` has
    higher significance in the lexicographic order.





Reachability
================================================================================

Reachability can be checked by transforming a pattern match expression into its
canonical form. Clauses which are unreachable follow immediately the clause
which shadows the unreachable clauses. The unreachable clauses have to be
eliminated.

Each clause in the canonical form stems exactly from one original clause. If all
clauses stemming from the same original clause are unreachable, then the
original clause is unreachable which has to be flagged as an error.






.. _exhaustiveness:

Exhaustiveness
================================================================================

Exhaustiveness can be easily checked in the canonical form where all
nonreachable clauses have been removed.

In the canonical form the sequence of clauses are nicely grouped. The pattern
vary from left to right from low frequency to the highest frequence. Therefore
missing variations can be easily spotted.

We can ignore all missing variations in inferable pattern. We concentrate only
on the non inferable pattern. If a clause is missing and it is unifiable with
the type, then the pattern match is not exhaustive. If all missing clauses are
not unifiable, then the pattern match is exhaustive even if not all combinations
are present.

We demonstrate the check on the following inductive types::

    class (=) {α: Any} (x: α): α → Prop :=
        identical: (=) x

    class (≤): Endorelation ℕ :=
        start {n}   : zero ≤ n
        next  {n m} : n ≤ m → succ n ≤ succ m

    class Vector (α: Any): ℕ → Any :=
        []      : Vector zero
        (::)    : ∀ {n}: α → Vector n → Vector (succ n)


We look at the follwing pattern match expressions in canonical form


Example 1::

    case
        { ∀ {n: ℕ}: zero = succ n → False }
        -- no clauses

Since there are no clauses, the expression is certainly in canonical form. The
missing clause has the form::

    λ {i} identical    :=  ...

Typechecking of the first argument leads to the substitution ``n := i``.
Therefore the type of the second argument is ``zero = succ i``. However the
typing judgement ::

    identical: zero = succ i

is invalid because the only valid typing judgement is ::

    identical: zero = zero

Therefore the clause is not really missing. It is not typable.

The same reasoning applies if we flip the arguments::

    case
        {∀ {n: ℕ}: succ n = zero → False }
        -- no clauses

    -- missing clause
    λ {i} identical

    -- type check the first argument
    n := i

    -- required typing judgement for the second argument
    identical: succ i = zero

    -- actual typing judgement for the second argument
    identical: succ i = succ i



Example 2::

    case
        { ∀ {n m: ℕ}: succ n ≤ succ m → n ≤ m }
        λ {i j} (next {i j} le) := le

The obviously missing clause has the form::

    λ {i j} (start {k})   :=

Typechecking of the first two arguments leads to the substitutions ``n := i``
and ``m := j`` and the required type ``succ i ≤ succ j`` for the third argument
i.e. the required typing judgement::

    start {k}: succ i ≤ succ j

However the only valid typing judgment is::

    start {k}: zero ≤ k

There is no possible substitution for the variables ``i``, ``j`` and ``k`` which
unifies the types ``succ i ≤ succ j`` and ``zero ≤ k``.

Therefore the obviously missing clause is not really missing.



Example 3::

    case
        { ∀ {n: ℕ}:
            Vector ℕ n → Vector ℕ n → Vector ℕ n
        }
        λ {zero}    []              []                  :=  ...
        λ {i}       ((::) {j} x xs) ((::) {k} y ys)     :=  ...


The obviously missing clauses are the *mixed* cases::

    λ {i}       []                  ((::) {k} y ys)     :=  ...
    λ {i}       ((::) {j} x xs)     []                  :=  ...


Let's look at the unification problems generated by the first seemingly missing
case. Type checking of the first argument leads to::

    n := i              -- substitution
    Vector ℕ i          -- required type for the second argument

Typechecking of the second argument leads to::

    []: Vector ℕ i      -- required typing judgement
    []: Vector ℕ zero   -- actual typing judgement
    i := zero           -- substitution
    Vector ℕ zero       -- required type for the third argument

However the required typing judgement for the third argument::

    (::) {k} y ys:  Vector ℕ zero

is not satisfiable because the constructor ``::`` constructs an object of type
``Vector ℕ (succ k)``.

A similar reasoning applies to the second missing case::

    -- type check the first argument
    n := i              -- substitution
    Vector ℕ i          -- required type for the second argument

    -- type check the second argument
    (::) {j} x xs: Vector ℕ i           -- required typing judgement
    (::) {j} x xs: Vector ℕ (succ j)    -- actual typing judgement
    i := succ j                         -- substitution
    Vector ℕ (succ j)                   -- required type for the third argument

    -- type check the third argument
    []: Vector ℕ (succ j)           -- required typing judgement
    []: Vector ℕ zero               -- actual typing judgment
    -- unsatisfiable !!






Pattern Match Compiler
============================================================

A pattern expression is a function with one or more arguments. In order to
execute an pattern match expression in the runtime efficiently, the pattern
match expression has to be compiled into a branching with e.g. a switch case.

Each branching step can decide only on one object by looking at the tag.


.. code-block::

    -- In the source code
    (<=?): Natural -> Natural -> Bool := case
        (succ n)    (succ m)    := n <=? m
        zero        _           := true
        _           _           := false

    -- More efficient
    (<=?): Natural -> Natural -> Bool := case
        zero :=
            \ _ := true
        (succ n) := case
            zero :=
                false
            (succ m) :=
                n <=? m

Compilation to javascript:

.. code-block:: javascript

    function le (a, b) {
        switch (a[0]) {
            case 'zero':
                return true
            case 'succ':
                switch (b[0]){
                    case 'zero':
                        return false
                    case 'succ':
                        return le (a[1], b[1])
                }
        }
    }

In order to get the more efficient form  we can transform the original cases
into its canonical form.

.. code-block::

   -- original
        (succ n)    (succ m)    := n <=? m
        zero        _           := true
        _           _           := false

    -- swap
        zero        _           := true
        (succ n)    (succ m)    := n <=? m
        _           _           := false

    -- split
        zero        _           := true
        (succ n)    (succ m)    := n <=? m
        zero        _           := false
        (succ _)    _           := false

    -- swap
        zero        _           := true
        zero        _           := false
        (succ n)    (succ m)    := n <=? m
        (succ _)    _           := false

    -- remove shadowed
        zero        _           := true
        (succ n)    (succ m)    := n <=? m
        (succ _)    _           := false

    -- split
        zero        _           := true
        (succ n)    (succ m)    := n <=? m
        (succ _)    zero        := false
        (succ _)    (succ _)    := false

    -- swap
        zero        _           := true
        (succ _)    zero        := false
        (succ n)    (succ m)    := n <=? m
        (succ _)    (succ _)    := false

    -- remove shadowed
        zero        _           := true
        (succ _)    zero        := false
        (succ n)    (succ m)    := n <=? m

This pattern match can be directly compiled into the nested branching where all
cases are covered. I.e. the pattern match is exhaustive. Each of the original
clauses occurs at least once, therefore there are no non-reachable clauses.


.. code-block::

    nodups: List Nat -> List Nat := case
        (x :: y :: tl) :=
            if x =? y then res else y :: res where
                res := y :: tl
        xs :=
            xs

    nodups: List Nat -> List Nat := case
        [] :=
            []
        (x :: xs) :=
            inspect xs case
                [] :=
                    [x]
                (y :: tl) :=
                    if x =? y then res else y :: res where
                        res := y :: tl



Transformation into canonical form:

.. code-block::

    -- original
        (x :: y :: tl)  := exp
        xs              := xs

    -- split
        (x :: y :: tl)  := exp
        []              := []
        (x :: xs)       := x :: xs

    -- swap
        []              := []
        (x :: y :: tl)  := exp
        (x :: xs)       := x :: xs

    -- split
        []              := []
        (x :: y :: tl)  := exp
        (x :: [])       := x :: []
        (x :: y :: tl)  := x :: y :: xs

    -- swap
        []              := []
        (x :: [])       := x :: []
        (x :: y :: tl)  := exp
        (x :: y :: tl)  := x :: y :: xs

    -- remove shadowed
        []              := []
        (x :: [])       := x :: []
        (x :: y :: tl)  := exp


.. code-block::

    map2 {A B C: Any} (f: A -> B -> C): List A -> List B -> List C
    := case
        (x :: xs) (y :: ys) :=
            f x y :: map2 xs xs
        _ _ :=
            []

    map2 {A B C: Any} (f: A -> B -> C): List A -> List B -> List C
    := case
        [] _ :=
            []
        (x :: xs) :=
            case
                [] :=
                    []
                (y :: ys) :=
                    f x y :: map2 xs ys



Transformation into canonical form

.. code-block::

    -- original
        (x :: xs) (y :: ys) := exp
        _ _  := []

    -- split
        (x :: xs) (y :: ys) := exp
        []        _  := []
        (x :: xs) _  := []

    -- swap
        []        _  := []
        (x :: xs) (y :: ys) := exp
        (x :: xs) _  := []

    -- split
        []        _  := []
        (x :: xs) (y :: ys) := exp
        (x :: xs) []  := []
        (x :: xs) (y :: ys) := []

    -- swap
        []        _   := []
        (x :: xs) []  := []
        (x :: xs) (y :: ys) := exp
        (x :: xs) (y :: ys)  := []

    -- remove shadowed
        []        _   := []
        (x :: xs) []  := []
        (x :: xs) (y :: ys) := exp




Modified Pattern Compiler
============================================================

Let's revisit the example::

    (<=?): Natural -> Natural -> Bool := case
        (succ n)    (succ m)    := n <=? m
        zero        _           := true
        _           _           := false

The first and the second case are inverted. Since the constructors are
different, we can swap them::

    zero        _           := true
    (succ n)    (succ m)    := n <=? m
    _           _           := false


Now for the first argument sufficient cases are available. Looking only at the
first argument, the last case is redundant. However the second argument still
needs a case for ``zero``. I.e. we have to factor out the corresponding case::

    zero        _           := true
    (succ n)    (succ m)    := n <=? m
    _           zero        := false
    _           _           := false


We cannot yet swap. Before we have to put in the third line the same constructor
as in the previous line because we don't have catch all cases (i.e. variable
pattern) not as the last case.::

    -- split
    zero        _           := true
    (succ n)    (succ m)    := n <=? m
    (succ n)    zero        := false
    _           _           := false

    -- and then swap
    zero        _           := true
    (succ n)    zero        := false
    (succ n)    (succ m)    := n <=? m
    _           _           := false

Now the last case is unreachable and can be deleted::

    zero        _           := true
    (succ n)    zero        := false
    (succ n)    (succ m)    := n <=? m
