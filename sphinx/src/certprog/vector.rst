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



    length {A}: all {n}: Vector A n -> Nat
    := case
        []        := zero
        (_ :: xs) := succ (length xs)


    vectorLength {A}: all {n} {a: Vector A n}: length a = n
    := case
        [] :=
            refl

        {_ :: xs} :=
            congruence succ vectorLength


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




Reverse Vectors
================================================================================


.. code::

    reversePrepend {A}: all {n m}: Vector A n -> Vector A m -> Vector A (n + m)
        -- 'reversePrepend a b': Prepend the reversed vector 'a'
        --                       in front of the vector 'b'. 
    := case
            [] b :=
                b

            (x :: xs) b :=
                x :: reversePrepend xs b


    reverse {A}: all {n}: Vector A n -> Vector A n :=
        \ {_} a :=
            reversePrepend a [] |> cast zeroRightNeutral



    (+) {A}: all {n m}: Vector A n -> Vector A m -> Vector A (n + m)
    :=
        \ {_} {_} a b :=
            reversePrepend (reverse a) b
