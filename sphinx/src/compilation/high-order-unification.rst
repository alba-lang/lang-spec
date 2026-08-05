********************************************************************************
High Order Unification / Implicit Variables
********************************************************************************


Basics
================================================================================

C-Metavariables representing functions (i.e. of product type) are implicit
variables. An implicit variable must occur in the remainder of the type i.e.
the type ``all {A}: R`` is legal only if ``A`` occurs in ``R``. An example is
the theorem ``congruence``.

.. code::

    congruence {A B: Any} {x y: A} {f: A -> B}: x = y -> f x = f y

All implicit variables ``A``, ``B``, ``x``, ``y``, ``f`` occur in the
corresponing remainder of the type. If the expression ``congruence eq`` appears
in the source text, then the compiler introduces for each implicit variable a
metavariable i.e. it generates the following expression together with its actual
type

.. code::

    congruence {A} {B} {X} {Y} {F} eq: F X = F Y

The metavariables can occur only in the type of the expression and in the
required type for ``eq``. It is impossible that they occur in other expressions
of types because they have been generated only in the elaboration of the
expression ``congruence eq``.

The metavariables are solved by using the constraints

.. code::

    E           <=   X = Y
    F X = F Y   <=   R

where ``E`` is the actual type of ``eq`` and ``R`` is the required type of
``concgruence eq``.

``eq`` might be function application containing metavariables representing
implicit arguments and the expression ``congruence eq`` might appear as an
argument in a function expression containing metavariables for implicit
arguments. I.e. both ``E`` and ``R`` might contain metavariables representing
implicit arguments.



Example ``pull-succ``
================================================================================

The theorem ``pull-succ`` proves ``x + succ y = succ (x + y)``. The theorem has
the definition

.. code::

    pull-succ: all {x y: Nat}: x + succ y = succ (x + y)
    := case
        {zero} {_} :=
            refl

        {succ k} {y} :=
            congruence pull-succ
            : succ (k + succ y) = succ (succ (k + y))


The base case is trivial. The induction step is interesting. The compiler
generates metavariables for the impicit variables and constraints

.. code::

    congruence {A} {B} {X} {Y} {F} (pull-succ {X2} {Y2})
                                    :  (=) (Nat) (X2 + succ Y2) (succ (X2 + Y2))
                                    <= (=) A     X              Y

    :  (=) B   (F X)        (F Y)
    <= (=) Nat succ (k + succ y) (succ (succ (k + y)))


The first constraint results in the first order flex-rigid constraints

.. code::

    Nat            ~ A
    X2 + succ Y2   ~ X
    succ (X2 + Y2) ~ Y

which can only be solved by imitation and have trivial solutions.

The second constraint results in the following constraints

.. code::

    B                  ~  Nat
    F (X2 + succ Y2)   ~  succ (k + succ y)
    F (succ (X2 + Y2)) ~  succ (succ (k + y))
