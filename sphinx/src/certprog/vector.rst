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
                reversePrepend xs (x :: b)


    reverse {A}: all {n}: Vector A n -> Vector A n :=
        \ {_} a :=
            reversePrepend a [] |> cast zeroRightNeutral



    (+) {A}: all {n m}: Vector A n -> Vector A m -> Vector A (n + m)
    :=
        \ {_} {_} a b :=
            reversePrepend (reverse a) b




Random Access
================================================================================


The indices of all elements of a vector of length ``n`` are strictly below
``n``. We define a type ``Below n`` whose inhabitants are indices strictly below
``n``.

.. code::

    type Below: Nat -> Any :=
        zero {n}: Below (succ n)
        succ {n}: Below n -> Below (succ n)


    toNat: all {n}: Below n -> Nat
        -- The natural number encoded in an object of type 'Below n'.
    := case
        zero     := zero
        (succ i) := i |> toNat |> succ


    below-<: all {n} {i: Below n}: toNat i < n
    := case
        {zero} :=
            z<=n |> s<=s

        {succ _} :=
            below-< |> s<=s



The index ``zero`` is strictly below ``succ n`` for all natural numbers ``n``.
The successor of an index ``Below n`` is strictly ``Below (succ n)``.

An index of type ``Below n`` can be used to index an element of a vector of
length ``n``.

.. code::

    get {A: Any}: all {n}: Below n -> Vector A n -> A
    :=
        zero     (x :: _ ) := x
        (succ i) (_ :: xs) := get i xs

Since ``Below zero`` is not inhabited, the vector cannot have type ``Vector A
zero``.

The function ``below`` maps all numbers ``a`` and a prove of ``a < b`` into an
inhabitant of ``Below b``.

.. code::

    below: all (a: Nat) {b}: a < b -> Below b
    := case
        zero (s<=s {_} {m} le) :=
                -- succ n = b
            zero

        (succ k) (s<=s {n} {m} le) :=

            below k le |> succ

The term ``a < b`` evaluates to ``succ a <= b``. The only possible constructor
is ``s<=s`` of the type ``<=``. Therefore the pattern match expression has only
two cases.

In the first case we have to construct an inhabitant of ``Below (succ m)``. This
is done by the constructor ``zero``.

In the second case we have to construct an inhabitant of ``Below (succ m)``.
With ``le`` we have a proof of ``n <= m`` where ``n`` unifies with ``succ k``
i.e. it is a proof of ``k < m``. ``below k le`` returns an object of type
``Below m`` which we convert via the constructor ``succ`` into an object of type
``Below (succ m)``.
