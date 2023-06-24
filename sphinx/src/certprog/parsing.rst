********************************************************************************
Parsing
********************************************************************************

In this section we describe monadic parsing. Recursion relies on progress
indicators. The type ``Progress`` is a builtin type and it can be used only in
monadic types which are some specific forms of functions.

.. code::

    Progress: Any

    yes:   Progress
    no:    Progress
    (and): Progress -> Progress -> Progress
    (or):  Progress -> Progress -> Progress



String Parser
================================================================================

.. code::

    Parser (A: Any) (_: Progress): Any :=
        String -> (Maybe A, String)

    section {A B: Any} {i j: Progress} :=

        (>>=) (m: Parser A i) (f: A -> Parser B j): Parser B (i or j) :=
            \ s :=
                match m s case
                    \ (just a, s2)  :=  f a s2
                    \ (empty,  s2)  :=  (empty, s2)

        return (a: A): Parser A no :=
            \ s := (just a, s)

        map (f: A -> B) (m: Parser A i): Parser B i :=
            \ s :=
                match m s case
                    \ (just a, s2)  :=  (just (f a), s2)
                    \ (empty,  s2)  :=  (empty, s2)

        </> (p: Parser A i) (q: Parser A j): Parser A (i and j) :=
            \ s :=
                match p s case
                    \ (just a, s2)  := (just a, s2)
                    \ (empty,  s2)  := q s

        char (d: Char -> Bool): Parser Char yes := case
            \ (s := [])      :=  (empty, s)     -- string not decreased
            \ (s := c :: s2) :=
                if d c then (just c, s2)        -- string decreased
                else        (empty, s)          -- string not decreased

Remarks:

- ``(>>=)`` is recognized by the compiler as a monadic bind operator. This
  recognition enables ``do`` expressions with the monad ``Parser``.

- The parser monad has a progress indicator. The progress indicator makes the
  definition opaque and there must not be any function returning a parser which
  does increase the string. I.e. all function returning a parser have to either
  decrease the string or leave it unchanged.

- The bind operator has the correct signature (result type with index ``i or
  j``)

- The bind operator defines the success case ``just a`` and the failure case
  ``empty``. All parser which return ``just a`` must decrease the string.


Recursive functions:

.. code::

        many (p: Parser A yes): Parser (List A) no :=
            do [a := p] map ((::) a) many
            </>
            return []

        many1 (p: Parser A yes): Parser (A, List A) yes :=
            do [a  := p]
               map (\ as := (a, as)) (many p)






Incremental Parsers
================================================================================
