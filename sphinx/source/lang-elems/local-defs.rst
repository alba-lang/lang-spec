.. _Local Definitions:

****************************************
Local Definitions
****************************************


It is possible to write terms with local definitions. There is a *let* form and
a *where* form.

::

    1 + f 10 where
        f x := 2 * g x                      -- inside out
        g x := x + 100

    let g x := x + 100                      -- outside in
        f x := 2 * g x
    :=
        1 + f 10

    -- The same with fully elaborated definitions
    1 + f 10 where
        f (x: Int): Int := 2 * g x
        g (x: Int): Int := x + 100

    let
        g (x: Int): Int := x + 100
        f (x: Int): Int := 2 * g x
    :=
        1 + f 10

A local definition has the same syntax as the global definition of a function /
constant. However the compiler has more context information, because the locally
defined symbol is used in the main expression. Therefore the compiler can infer
from the main expression typing information which need not be given by the user
in the local declaration.

The *where* form and the *let* form are fully equivalent. *where* works inside
out i.e. an inner (i.e. previous) definition can use outer definitions. *let*
works outside in i.e. outer (i.e. previous) definitions can be used by inner
definitions.

Choosing between both forms is a matter of taste. In many cases the *where* form
is preferable because it is more goal driven. You first write your main
expression with some unknowns and then you define successively the unknowns in
an inside out manner.


Like in :ref:`pattern match <Pattern Match>` expressions, implicit arguments can
be ommitted as long as the compiler can infer them from the usage. But for
reasons of :ref:`elaboration <Elaboration>` we insist that implicit arguments
are either not mentioned or all are mentioned in the corresponding local
definition.

The handling of implicit arguments is a subtle difference between local and
global definitions. Since there is no usage context in global definitions, all
implicit arguments must be mentioned in the definition. Their types might be
inferrable, but they must be mentioned. In local definitions the compiler might
be able to infer from the usage the type of a local definition. Having the type
information, it is clear that and where there are implicit arguments.
