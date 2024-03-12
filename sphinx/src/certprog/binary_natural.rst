********************************************************************************
Binary Natural Numbers
********************************************************************************





Basic Definitions
================================================================================


.. code::

    type BinNat :=
        zero:  BinNat
        odd2:  BinNat -> BinNat     -- odd:  2 * n + 1
        even2: BinNat -> BinNat     -- even: 2 * (n + 1)


The successor function is a recursive function

.. code::

    add1: BinNat -> BinNat :=
        case
        \ zero :=
                -- zero + 1 = 2 * zero + 1
            odd2 zero

        \ odd2 n :=
                -- (2 * n + 1) + 1 = 2 * (n + 1)
            even2 n

        \ even2 n :=
                -- (2 * (n + 1)) + 1 = 2 * (n + 1) + 1
            odd2 (succ n)


    add2: BinNat -> BinNat :=
        case
        \ zero :=
            even2 zero

        \odd2 n :=
                -- (2 * n + 1) + 2  = (2 * (n + 1)) + 1
            add1 (even2 n)

        \even2 n :=
                -- (2 * (n + 1)) + 2 = 2 * ((n + 1) + 1)
                even2 (add1 n)


In order to implement addition we need the following equalities

.. code::

    (2 * n + 1)   + (2 * m + 1)   = 2 * ((n + m) + 1)

    (2 * n + 1)   + (2 * (m + 1)) = 2 * ((n + m) + 1) + 1

    (2 * (n + 1)) + (2 * (m + 1)) = 2 * (((n + m) + 1) + 1)


    (+): BinNat -> BinNat -> BinNat :=
        case
        \ zero, b :=
            b

        \ odd2 n, odd2 m :=
            even2 (n + m)

        \ odd2 n, even2 m :=
            add1 (even2 (n + m))

        \ even2 n, odd2 m :=
            add1 (even2 (n + m))

        \ even2 n, even2 m :=
            even2 (add1 (n + m))


Doubling a number

.. code::

    double: BinNat -> BinNat :=
        case
        \ zero :=
            zero

        \ odd2 n :=
                -- 2 * (2 * n + 1) = 2 * ((2 * n) + 1)
                even2 (double n)

        \ even2 n :=
                -- 2 * (2 * (n + 1)) = 2 * (2 * n + 2)
                --                   = 2 * (((2*n) + 1) + 1)
            even2 (succ (double n))
