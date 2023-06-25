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


All the following code is within a section

.. code::

    section {A B R: Any} {i j: Progress}
    :=
        ...

A parser is an object which is either done with a number of consumed characters
and an optional result, or it needs more input. In the second case it contains a
function which accepts more input and returns a new incremental parser.

.. code::

    -- Parser

    type Parser (A: Any) :=
        done: Nat -> Maybe A -> Parser
        more: (String -> Parser) -> Parser

    put: String -> Parser A -> Parser A
    := case
        \ _,  (p: = done _ _ )  := p
        \ s,  more f            := f s


A partial parser is a continuation monad with state where the state consists of
the number of consumed characters and a lookahead string. The lookahead string
is a prefix of the remainder of input which is not yet consumed.

A partial parser receives the state, parses a certain part of the lookahead and
then calls the continuation with success or failure and the new state.

.. code::

    Mon (A R: Any) (_: Progress): Any
        -- Continuation Monad
    :=  Nat                                        -- consumed characters
        -> String                                  -- lookaheads to parse
        -> (Maybe A -> Nat -> String -> Parser R)  -- continuation
        -> Parser R


    (>>=) (m: Mon A R i) (f: A -> Mon B R j): Mon B R (i or j)
        -- monadic bind
    :=
        \ n s k :=
            m n s (case
                    \ just a, n, s := f a n s k
                    \ empty,  n, s := k empty n s)


Recursion rule: Whenever there is a recursive call, then the continuation
function is called in the success case with a structurally smaller argument and
in failure cases the string argument is not increased.


.. code::

    -- Elementary monads

    return (a: A): Mon A R no :=
        \ n s k := k (just a) n s

    fail: Mon A R no :=
        \ n s k := k empty n s

    char (d: Char -> Bool): Mon Char R yes
    := case
        \ n, (s := []),      k := more (\ s := char s k)
                                  --           ^^^^ no recursion, partial call
        \ m, (s := c :: s2), k :=
            if d c then k (just c) (1 + n) s2
            else        k empty    n       s

The monad ``char d`` is a function which makes progress. It calls the
continuation function with a shorter string in the success case and with the
original string in the failure case.




.. code::

    -- Biased choice

    (</>) (p: Mon A R i) (q: Mon A R j): Mon A R (i and j) :=
        \ n s k :=
            p n s (case
                    \ just a, n2, s2 :=
                            -- 'p' has succeeded
                        k (just a) n2 s2
                    \ empty,  n2, s2 :=
                        if n = n2 then
                                -- no consumption, try 'q'
                            q n2 s2 k
                        else
                                -- 'p' has consumed and failed
                            k empty n2 s2)

.. code::

    -- Make the parser from a partial parser

    make (m: Cont R R i): Parser R :=
        m 0 "" (\ res n _ := done res n)
