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
corresponding remainder of the type. If the expression ``congruence eq`` appears
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

``B := Nat`` is the trivial solution for the first constraint.

For the second constraint we try projection which results in

.. code::

    X2 + succ Y2  ~ succ (k + succ y)

which fails immediately because to different rigid head terms. Note that
projection on the third constraint fails because it generates the constraints

.. code::

    succ (X2 + Y2)  ~  succ (succ (k + y))
    X2 + Y2         ~  succ (k + y)

Alternatively we try imitation ``F X := succ (F1 X)`` on the second constraint
and get

.. code::

    succ (F1 (X2 + succ Y2))   ~ succ (k + succ y)
    succ (F1 (succ (X2 + Y2))) ~ succ (succ (k + y))

    F1 (X2 + succ Y2)   ~  k + succ y
    F1 (succ (X2 + Y2)) ~  succ (k + y)


Now imitation fails because of the different head terms on the right hand sides.
So only projection ``F1 X := X`` is left which yields

.. code::

    X2 + succ Y2   ~  k + succ y
    succ (X2 + Y2) ~  succ (k + y)

with the only solution ``X2 := k`` and ``Y2 := y``.

The final solution is

.. code::

    pull-succ: all {x y: Nat}: x + succ y = succ (x + y)
    := case
        {zero} {_} :=
            refl

        {succ k} {y} :=
            congruence
                {Nat} {Nat} {k + succ y} {succ (k + y)}
                {\x := succ((\y := y) x}
                (pull-succ {k} {y})



Example: Transitivity of Equality
================================================================================

We want to prove transitivity of equality

.. code::

    (,): all {A: Any} {a b c: A}: a = b -> b = c -> a = c :=
        eq-flip >> eq-cast

using

.. code::

    (>>) {A B C: Any} (f: A -> B) (g: B -> C): A -> C

    eq-flip {A: Any} {a b: A}: a = b -> b = a

    eq-cast {A: Any} {a b: A} {F: A -> Any}: a = b -> F a -> F b


We introduce metavariables for the implicit variables

.. code::

    (,): all {A: Any} {a b c: A}: a = b -> b = c -> a = c
    :=
        (>>)
            {A1} {B1} {C1}
            (eq-flip {A2} {x2} {y2}
                :   (=) {A2} x2 y2 -> (=} {A2} y2 x2
                <=  A1             -> B1
            )
            (eq-cast {A3} {F} {x3} {y3}
                :   x3 = y3 -> F x3 -> F y3
                <=  B1      -> C1
            )
            :   A1    -> C1
            <=  a = b -> b = c -> a = c

with the immediate instantiations and constraints

.. code::

    A1 := (=) {A} a b
    C1 := (=) {A} b c -> (=) {A} a c
    B1 := (=) {A3} x3 y3

    F x3 -> F y3     <=  (=) {A} b c -> (=) {A} a c
    (=) {A2} y2 x2   <=  (=) {A3} x3 y3
    (=) {A2} x2 y2   <=  (=) {A} a b

    -- by unification we obtain
    A2 := A
    A3 := A
    x2 := a
    y2 := b
    x3 := b
    y3 := a

    F b  <=  (=) {A} b c
    F a  <=  (=) {A} a c

Projection for ``F`` fails because of different head terms. Immitation yields
``F x := (=) {F1 x) (F2 x) (F3 x)`` which results in the constraints

.. code::

    F1 b   ~  A
    F1 a   ~  A
    F2 b   ~  b
    F2 a   ~  a
    F3 b   ~  c
    F3 a   ~  c

    -- resulting

    F1 x := A       -- projection fails
    F2 x := x       -- imitation  fails
    F3 x := c       -- projection fails

    -- result for F

    F x := (=) {A} x c  -- after beta reduction
