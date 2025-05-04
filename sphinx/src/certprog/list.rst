********************************************************************************
List
********************************************************************************





Basics
================================================================================

.. code::

    type List (A: Any): Any :=
        []: _
        (::): A -> _ -> _


Via pattern match we can define a recursor and an induction principle over lists.

.. code::


    recurse
        {A}
        {P: List A -> Any}
        (start: P [])
        (next: all x xs: P xs -> P (x :: xs))
        :all xs: P xs
    := case
        []        := start
        (x :: xs) := next x xs (rec xs)


    induce
        {A}
        {P: List A -> Prop}
        (start: P [])
        (next: all {x xs}: P xs -> P (x :: xs))
        :all {xs}: P xs
    := case
        {[]}      := start
        {x :: xs} := next ind





Append Lists
================================================================================


.. code::

    (+) {A}: List A -> List A -> List A
    := case
        [] b        := b
        (x :: xs) b := x :: xs + b




The empty list is right neutral with respect to appending.

.. code::

    nilRightNeutral {A}: all {a: List A}: a + [] = a
    :=
        induce
            refl
            (\ {x xs} := congruence (\xs := x :: xs) nilRightNeutral






Appending lists is an associative operation. This can be proved by induction.
The base case is trivially proved by ``refl`` because both ``[] + b + c`` and
``[] + (b + c)`` normalize to ``b + c``.

For the induction step we have to prove the equality the two expressions on the
left side.

.. code::

    -- expression                               normal form
    (x :: xs) + b + c                           x :: (xs + b + c)
    (x :: xs) + (b + c)                         x :: (xs + (b + c))

By looking at the normal forms it is clear that we can use the induction
hypothesis and the congruence law of equality with the function
``\ xs := x :: xs``
to prove the goal.



.. code::

    associate {A}: all {a b c: List A}: a + b + c = a + (b + c)
    := case
        {[]}      {b} {c} :=
            refl

        {x :: xs} {b} {c} :=
            congruence (\ xs := x :: xs) associate



List Reversal
================================================================================


.. code::

    reverse {A}: List A -> List A
    :=
        case
            []        := []
            (x :: xs) := reverse xs + [x]

List reversal shall distribute over list appending with the arguments reversed

.. code::

    reverse (a + b) = reverse b + reverse a

This can be proved by induction on ``a``. The base case requires the equality of
``reverse b`` and ``reverse (b + [])`` which can be proved by the right
neutrality of the empty list with respect to list concatenation.

The induction step requires the equality of the two expression on the left side.

.. code::

    -- expression                               normal form
    reverse ((x :: xs) + b)                     reverse (xs + b) + [x]
    reverse b + reverse (x :: xs)               reverse b + (reverse xs + [x])

The equality of the normal forms can be proved by the following steps

.. code::

    reverse (xs + b) + [x]
    =                                   -- induction hypothesis + congruence
    reverse b + reverse xs + [x]
    =                                   -- associative laww
    reverse b + (reverse xs + [x])

The complete proof

.. code::

    distribute {A}: all {a b: List A}: reverse (a + b) = reverse b + reverse a
    := case
        {[]} {b} :=
            flip (nilRightNeutral)

        {x :: xs} {b} :=
            (   congruence (\xs := xs + [x]) distribute
            ,   associate
            )


Furthermore we want to prove that list reversal is an involution.

.. code::

    reverse (reverse a) = a

The prove is done by induction on ``a``. The base case is trivial. The induction
step requires to prove the equality of ``reverse (reverse (x :: xs)`` and ``x ::
xs``. The normal form of the left hand side is

.. code::

    reverse (reverse xs + [x])

Its equality with ``x :: xs`` can be shown by the steps

.. code::

    reverse (reverse xs + [x])
    =                                   -- distribution
    reverse [x] + reverse (reverse xs))
    =                                   -- normalization
    x :: reverse (reverse xs)
    =                                   -- induction hypothesis + congruence
    x :: xs


The complete proof reads like

.. code::

    involute {A}: all {a}: reverse (reverse a) = a
    := case
        {[]} :=
            refl

        {x :: xs} :=
            (   distribute
            ,   congruence (\ xs := x :: xs) involute
            )
