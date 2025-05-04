********************************************************************************
Vector
********************************************************************************





Basics
================================================================================


A vector is a list where its length is part of the type. I.e. ``List A`` is a
list of elements of type ``A`` and ``Vector A n`` is a list of ``n`` elements of
type ``A``.

.. code::

    type Vec (A: Any): Nat -> Any :=
        []: _ zero
        (::) {n}: A -> _ n -> _ (succ n)


    rec
        {A n}
        {P: all {n}: Vec A n -> Any}
        (start: P [])
        (next: all x xs: P xs -> P (x :: xs))
        : all {n} xs: P {n} xs
    :=
        case
            []         := start
            (x :: xs)  := next x xs (rec xs)


    ind
        {A n}
        {P: all {n}: Vec A n -> Any}
        (start: P [])
        (next: all {n x xs}: P {n} xs -> P {succ n} (x :: xs))
        : all {n xs}: P {n} xs
    :=
        case
            {[]}       := start
            {x :: xs}  := next ind









Concatenate Vectors
================================================================================


.. code::

    (+) {A: Any}: all {na nb}: Vector A na -> Vector A nb -> Vector A (na + nb)
    := case
        [] b :=
            b

        (x :: xs) b :=
            x :: xs + b

The empty vector is right neutral with respect to concatenation.

.. code::

    rnNat {n: Nat}: n + zero = n :=
        rightNeutral

    rightNeutral {A: Any}: all {n} {a: Vector A n}: cast rnNat (a + []) = a
    := case
        {[]} :=
            refl

        {x :: xs} :=
            -- goal case rnNat ((x :: xs) + []) = x :: xs
    
    --
        (x :: xs) + []: Vector A (succ n + 0)
        ~>
        x :: xs + []:   Vector A (succ (n + 0))

        x :: xs: Vector A (succ n)
                    
            
            
