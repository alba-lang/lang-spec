********************************************************************************
Universe Pattern
********************************************************************************


From the paper "The Power of Pi" from Nicolas Oury and Wouter Swierstra.



Universes
================================================================================

.. code::

    type Bit: Any :=
        z: Bit  -- zero
        o: Bit  -- one

    type U: Any
        -- type universe
    :=
        bit:  U
        char: U
        nat:  U
        vec:  U -> Nat -> U

    El: U -> Any
    := case
        bit       := Bit
        char      := Char
        (vec u n) := Vec (El u) n


The pair of a type ``U`` and a function ``El`` is called a universe.

.. code::

    show: all u: El u -> String
    := case
        bit z :=
            "0"
        bit o :=
            "I"
        char c :=
            charToString c
        nat  zero :=
            "zero"
        nat  (succ k) :=
            "succ " + parens (show nat k)
        (vec u zero) [] :=
            "nil"
        (vec u (succ k)) (x :: xs) :=
            parens (show u x) + " :: " + parens (show (vec u k) xs)


    read: all u: String -> Maybe (El u, List Bit)
    := case
        _ [] := nothing
        bit       ('0' :: cs) := just (z, cs)
        bit       ('I' :: cs) := just (o, cs)
        char      ( c  :: cs) := just (c, cs)
        nat       ( 'z' :: 'e' :: 'r' :: 'o' :: cs) := just (zero, cs)
        -- how to treat parentheses??

        _         _           := nothing



File Formats
================================================================================

General definitions:

.. code::

    type Either (A B: Any): Any :=
        left:  A -> _
        right: B -> _

    type Sigma (A: Any) (P: A -> Any): Any :=
        sigma x: P x -> _

Format

.. code::

    mutual
        type Format: Any :=
            bad: Format
            end: Format
            base: U -> Format
            plus: Format -> Format -> Format    -- biased choice
            skip (f: Format): (TypF f) -> Format -> Format
            read (f: Format): (TypF f -> Format) -> Format

        TypF: Format -> Any := case
            bad          :=   Void
            end          :=   Unit
            (base u)     :=   El u
            (plus f1 f2) :=   Either (TypF f1) (TypF f2)
            (skip _ _ f) :=   TypF f
            (read f1 f2) :=   Sigma (TypF f1) (\x := f2 x)


Format combinators

.. code::

    char (c: Char): Format := base (char c)

    satisfy (f: Format) (p: TypF f -> Bool): Format :=
        read f (\ x := if p x then end else bad)
        
