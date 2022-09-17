.. _Compilation:

********************************************************************************
Compilation
********************************************************************************

.. toctree::

    elaboration/index

Context
================================================================================

A compilation context consists of a set of packages and each package consists of
a set of modules. A reference to a module has the form ::

    author.package.name

where ``author.package`` uniquely identifies the package. The author has to be
a valid github user and the package is the name of the repository.

Package dependencies and module dependencies have to be noncircular. The *alba*
packages must not depend on any other packages. The package ``alba.core``
depends on no other package.


A compilation context consists of a set of used modules. Each module has an
interface and an implementation. For the used modules only the interface part of
the used modules are important.

Each module is a set of global declarations. Definitions can be given in the
interface part or not depending on whether the definitions are exported.



Term Elaboration
================================================================================

The user term is given as an abstract syntax tree.



Elaboration Context
================================================================================

All terms are elaborated in an elaboration context. The elaboration context has
information about the implicit and explicit arguments to which the term to be
elaborated has to be applied and about the expected result. The expected result
might be an object of a certain type (maybe given with metavariables) or just
the information that a type is expected.

Sorts
================================================================================

The following are valid sorts and their corresponding types::

    Level                       : Any omega
    --                                  ^-- cannot appear in user code
    Prop                        : Any 0
    Any 10                      : Any 11
    Any (u + 4)                 : Any (u + 5)
    Any (max u (v + 3) z)       : Any (max u (v + 3) z + 1)

    Any     -- treated as 'Any u' with the default universe 'u'.

For all global declarations the elaborator adds the default universe::

    {u: Level}

All terms ``Any`` are elaborated in the default universe i.e. ``Any`` is
elaborated as ``Any 0`` and its type is ``Any 1``. In case that the default
universe ``u`` is not used, i.e. there is no ``Any`` in the gobal declaration
without a universe specification, the default universe can be removed and the
declaration is not universe polymorphic.



Types
================================================================================

All expressions to the right of a colon must be types. In the following ``A``,
``B`` and ``R`` are types::

    all (x: A) (y: B): R

    f (x: A) (y: B): R := e

All sorts are types by construction. They can be elaborated as shown above. All
other types must have the type ``Any u`` for some universe expression ``u``. The
elaborator introduces a metavariable::

    ?u: Level
    -- u0 u1 ... are all universe variables in the context.

and tries to elaborate the type ``T`` with the expected type ``?u``.




Products
================================================================================

A product has the general form::

    all (x: A) (y: B) ... : R

We treat ``A -> B -> ...`` as a shorthand for ``all (_: A) (_: B) ...``.

The type of a product is always a sort. I.e. a product can only be successfully
elaborated where a type is required. A product cannot be applied to arguments.

First the argument types have to be elaborated as types and the result type has
to be elaborated as type (see above).

After successful elaboration of each type a local variable with the elaborated
type and the corresponding name is shifted into the context. The following
type might depend on the variable.

After the successful elaboration of the types it has to be checked, which
variables are optionally (they occur in one of the following types) and
mandatory implicit (they occur in one of the following types and are kinds occur
in propositions). The user declaration has to respect the mandatory implicitness and the mandatory explicitness.



Identifier / Operator
================================================================================

If the identifier is a local name, then the identifier has to be elaborated as
the local variable (local variables are shadowing all other names).

If the identifier is a global name, then it can be ambiguous. There are the
following possibilities to disambiguate the name:

- Namespace specification

- Argument types and/or result type

In order to disambiguate through types each type of a global gets a signature
where we distinguish between unknowns ``U``, implicits ``I``, sorts ``S`` and
global names. Some examples::


    -- type                                     signature

    Any -> Any                                  [S, S]

    all {A: Any}: List A -> Natural             [I, List, Natural]

    Int -> Int -> Int                           [Int, Int, Int]

    all {A: Any}: A                             [I, U]

    all {A: Any}: A -> A                        [I, U, U]

    all {A: Any} {B: A->Any} (a: A) -> (all x: B x) -> B a
                                                [I, I, U, [U,U], U]

Having the signature we can check, if the global can accept sufficient
arguments. If yes, we can strip off the given arguments and get a signature for
the result type and can compare it with the signature of the expected result
type.

If there remain ambiguities we have to elaborate the arguments which can
distinguish the possibilities.

If we cannot resolve the ambituities neither by names space specifications nor
by the result type nor by argument types then the elaboration fails. The only
possibility to recover from this failure is when the result type could
distinguish the ambiguity but is not yet known (it is still described by a
metavariable). In the latter case we could resume the elaboration when the
result type is known exactly.



Function Application
================================================================================

Syntax::

    f a b ...

Every term is a function application even if there are no explicit arguments.
There can be implicit arguments.

First we elaborate ``f``.

Then forall given arguments (implicit or explicit) we introduce metavariables
for all not given implicit arguments and elaborate the argument with an expected
result type.

Finally we unify the actual result type with the expected result type.




Term
================================================================================
