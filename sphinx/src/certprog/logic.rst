********************************************************************************
Logic
********************************************************************************





Function Composition
================================================================================


.. code::

    (|>) {A: Any} {F: A -> Any} (a: A) (f: all x: F x): F a
            -- 'a |> f' is equivalent to 'f a'.
            -- It is left associative
    :=
        f a


    (<|) {A: Any} {F: A -> Any} (f: all x: F x) (a: A): F a
            -- 'f <| a' is equivalent to 'f a'
            -- It is right associative, therefore it can be composed
            -- 'g <| f <|a' instead of 'g (f a)'
    :=
        f a



    (>>) {A B C: Any} (f: A -> B) (g: B -> C): A -> C
            -- '(f >> g) x' is equivalent to 'g (f x)'
    :=
        \ x := g (f x)



    (<<) {A B C: Any} (f: B -> C) (g: A -> B): A -> C
            -- '(f << g) x' is equivalent to 'f (g x)'
    :=
        \ x := g (f x)






Propositions
================================================================================


.. code::

    type True: Prop :=
        (): True

    type False: Prop := -- no constructor


    (Not) (P: Prop): Prop := P -> False


    type (/\) (A B: Prop): Prop :=
            -- (/\) is right associative i.e.
            -- A /\ B /\ C = A /\ (B /\ C)
        (,): A -> B -> _

    type (\/) (A B: Prop): Prop :=
            -- (\/) is right associative i.e.
            -- A \/ B \/ C = A \/ (B \/ C)
        left:  A -> _
        right: B -> _


    type Exist {A: Any} (P: A -> Prop): Prop :=
        exist {w}: P w -> _


    All {A: Any} (P: A -> Prop): Prop :=
        all {x}: P x


Note that ``(,)``, ``left``, ``right`` and ``exist``  have the types

.. code::

    (,):   all {A B: Prop}: A -> B -> A /\ B
    left:  all {A B: Prop}: A -> A \/ B
    right: all {A B: Prop}: B -> A \/ B
    exist: all {A: Any} {P: A -> Prop} {w: A}: P w -> Exist P


The parameter arguments of an inductive type are all implicit and the same for
all constructors of the type.

It is a simple exercise to prove commutativity of conjunction and
disjunction.

.. code::

    flip {A B: Prop}: A /\ B -> B /\ A
    := case
        (p,q) := (q,p)

    flip {A B: Prop}: A \/ B -> B \/ A
    := case
        (left p)  := right p
        (right q) := left q


From a contradiction (represented by an inhabitant of ``False``) follows
anything (ex falso quodlibet). This can be proved by a pattern match on an
inhabitant of ``False``. Since the type ``False`` has no constructors, the
pattern match has no clauses.

.. code::

    exFalso: False -> all {A: Prop}: A
    :=
        case
            -- no constructors



In classical logic the following propositions are equivalent

.. code::

    A                   Not Not A           -- double negation

    Not (A /\ B)        Not A \/ Not B      -- de Morgan for and

    Not (A \/ B)        Not A /\ Not B      -- de Morgan for or

    A -> B              Not B -> Not A      -- modus tollens


We are in the domain of constructive logic. Therefore the double negation law
can be proved only in forward direction, the de Morgan law for conjunction can
be proved only in backward direction, the de Morgan law for disjunction can be
proved in both directions.

.. code::

    doubleNegation {A: Prop}: A -> Not Not A
    :=
        \ (pA: A) (pNotA: A -> False): False
        :=
            pNotA p


    deMorganAnd {A B: Prop}: Not A \/ Not B -> Not (A /\ B)
    :=
        (left pNotA)  (pA, pB) :=
            pNotA pA

        (right pNotB)  (pA, pB) :=
            pNotB pB


    deMorganOrFwd {A B: Prop}: Not (A \/ B) -> Not A /\ Not B
    :=
        \ pNotAOrB := (pNotAOrB << left, pNotAOrB << right)


    deMorganOrBwd {A B: Prop}: Not A /\ Not B -> Not (A \/ B)
    := case
        (pNotA, pNotB) (left pA)  := pNotA pA
        (pNotA, pNotB) (right pA) := pNotB pB


    modusTollens {A B: Prop}: (A -> B) -> Not B -> Not A
    :=
        \ ab notb := ab >> notb



In classical logic there are the de Morgans laws for universal and existential
quantification which state the equivalence of

.. code::

    Not (All P)                 Exist (Not << P)

    Not (Exist P)               All (Not << P)


As in the case of conjunction and disjunction, for universal quantification only
the backward direction can be proved.

.. code::

    deMorganAll {A: Any} {P: A -> Prop}: Exist (Not << P) -> Not (All P)
    := case
        (exist xNotP) xP := xNot xP


    deMorganExistFwd {A: Any} {P: A -> Prop}: Not (Exist P) -> All (Not << P)
    :=
        \ noXinP xP := noXinP (exist xP)


    deMorganExistBwd {A: Any} {P: A -> Prop}: All (Not << P) -> Not (Exist P)
    :=
        \ allXnotinP (exist xP) := allXnotinP xP










Equality
================================================================================


.. code::

    type (=) {A: Any}: A -> A -> Prop :=
        refl {x}: x = x


The equality relation is the smallest reflexive relation. This fact can be
proved by pattern match.


.. code::

    recurse {A: Any} {R: A -> A -> Any} (f: all x: R x x)
    : all (x y: A): x = y -> R x y
    :=
        case
            (x) (_} refl := f x


The elaboration of the pattern match expression unifies ``x`` and ``y``.
Therefore ``f: R x x`` has the correct required type.

Note that ``R`` is not a propositional relation because it does not have the
type ``A -> A -> Prop``. However the function ``f`` is able to generate for each
``x`` an inhabitant of ``R x x``. Therefore ``R`` is in the nonpropositional
world the equivalent of a reflexive relation.

Note further that ``f`` is not a ghost function. Given a runtime object ``x`` it
returns a runtime object of type ``R x x``. However when fed with a ghost object
it returns only a ghost object. Since ``recurse`` has to return a runtime
object, the argument ``x`` cannot be implicit.

Even if the arguments ``x`` and ``y`` are not implicit, the are still derivable
by unification bcause they are contained in the result type ``R x y``.



More important than the recursor is the proof that ``(=)`` is leibniz equality
which says that equal terms are indistinguishable.

.. code::

    cast {A: Any} {F: A -> Any}: all {a b}: a = b -> F a -> F b
    := case
        refl x := x



Equality is a congruence as well.

.. code::

    congruence {A B: Any} {a b: A) {f: A -> B}: a = b -> f a = f b
                --             ^ mandatory implicit (propositional type)
    :=
        recurse (\ x : f x = f x := refl) a b

    -- higher order unification of the metavariable R:

        R x x ~ (f x = f x)
        R a b ~ (f a = f b)

        R x y := (f x = f y)


Congruence can be proven with leibniz equality as well.

.. code::

    congruence {A B: Any} {a b: A} {f: A -> B} (eq: a = b) -> f a = f b
    :=
        cast eq (refl {f a})

    -- higher order unification of the metavarialbe F

    F b ~ f a = f b

        F x := F1 x = F2 x
        F1 b ~ f a
            F1 x := f (F11 x)
            F11 b ~ a
                F11 x := a

            F2 x := f (F21 x)
            F21 b ~ b

        F2 b ~ f b

    F a ~ f a = f a
    f a = f (F21 a) ~ f a = f a
        F21 x := x



The most straighforward proof of leibniz equaility is by pattern match.

.. code::

    congruence {A B: Any}: all {a b} {f: A -> B}: a = b -> f a = f b
    := case
        refl := refl


Equality is symmetric and transitive.

.. code::

    flip {A: Any} {a b: A}: a = b -> b = a
    :=
        recurse (\ x : x = x := refl) a b

        -- type of refl

        refl : all {A: Any} {x: A}: x = x


    (,) {A: Any} {a b c: A}: a = b -> b = c -> a = c
    :=
        flip >> cast

        -- instantiation of F

        F b ~ b = c
        F a ~ a = c



Decisions
================================================================================

.. code::

    type Decision (A: Prop) :=
        true:  A     -> _
        false: Not A -> _


    Decider {A: Any} (P: A -> Prop): Any :=
            -- Type of a decider for a predicate
        all x: Decision (P x)

    Decider {A B: Any} (R: A -> B -> Prop) :=
            -- Type of a decider of a relation
        all x y: Decision (R x y)


A type is *decidable* if it is possible to decide if two object of that type are
equal. I.e. the type has a decider for equality.

.. code::

    abstract type Decidable (A: Any) :=
        (=): Decider ((=) {A})


If there is an endorelation between two objects of a certain type then it might
be possible to compare the two objects.

.. code::

    type Comparison {A: Any} (R: A -> A -> Prop) (x y: A) :=
        lt:  R x y -> Not R y x -> _
        eqv: R x y -> R y x     -> _
        gt:  R y x -> Not R x y -> _


    Comparer {A: Any} (R: A -> A -> Prop): Any :=
        all x y -> Comparison R x y


    abstract type Comparable {A: Any} (R: A -> A -> Prop) :=
        compare: Comparer R



Refinement
================================================================================

An object of a refinement type of type ``A`` is an object of type ``A`` and a
proof that the object satisfies a certain predicate ``P``. The refinement type
is like the exisitence type with the difference that the witness is not a ghost
object.

.. code::

    type Refine {A: Any} (P: A -> Prop): Any :=
        (,) {w}: P w -> Refine
