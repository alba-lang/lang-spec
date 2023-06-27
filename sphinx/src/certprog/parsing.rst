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

For a module we need one or more types, constructors of objects of the types,
combinators which combine objects of the types and eliminators which use objects
of the types to return objects which no longer contain the types.

.. code::

    -- module interface

    module "String Parser"
        
        -- Type
        Parser: Any -> Progress -> Any

        section {A B: Any} {i j}: Progress :=

            -- Elementary constructors for the parser
            return: A -> Parser A no
            fail:   Parser A no
            char:   (Char -> Bool) -> Parser Char yes

            -- Combinators
            (>>=):  Parser A i -> (A -> Parser B j) -> Parser B (i or j)
            (</>):  Parser A i -> Parser A j        -> Parser A (i and j)

            -- Run a parser
            run:    Parser A i -> String -> (Maybe A, String)

This interface declares ``Parser`` to be a type constructor. One of the type
arguments is ``Progress``. This is meaningful only if ``Parser A i`` is a
function type.

A string parser has a monadic bind operator ``>>=``. This enables the use of
``do`` expressions.

Next we define the module and start with the type

.. code::

    module "String Parser" :=

        Parser (A: Any) (_: Progress): Any :=
            String -> (Maybe A, String)

A parser is a function with a string argument (i.e. only one state) and the
string appears in the result. This imposes the requirement that no function is
allowed to increase the string and all progressing parser have to decrease the
string in the success case.

From the declaration of the monadic bind the compiler knows that `A` is the
monadic argument. The argument type ``A`` in the result type has to within a
container with two constructors, one for the success case and one for the
failure case. In the success case the result has to contain an object of type
``A``, in the failure case it must not contain an object of type ``A``. The
inductive type ``Maybe`` satisfies this requirement.

The remainder of the definition is understood to be within a section as in the
module interface in order to avoid repetition of formal arguments.

First we define the elementary constructors which construct non progresssing
parsers.

.. code::

    return (a: A): Parser A no :=
        \ s := (just a, s)

    fail: Parser A no :=
        \ s := (empty, s)

Both functions make non progressing parsers, they don't change the string.

Now the only constructor for a progressing parser.

.. code::

    char (d: Char -> Bool): Parser Char yes := case
        \ (s := [])      :=  (empty, s)     -- string not decreased
        \ (s := c :: s2) :=
            if d c then (just c, s2)        -- string decreased
            else        (empty, s)          -- string not decreased

In the failure cases the string is kept the same and in the success case the
string is decreased.

We have to define the monadic bind.

.. code::

    (>>=) (p: Parser A i) (f: A -> Parser B j): Parser B (i or j) :=
        \ s :=
            match p s case
                \ (just a, s2)  :=  f a s2
                \ (empty,  s2)  :=  (empty, s2)

The function ``f`` can be called only in the success case (otherwise there is no
object of type ``A``.

The parser ``p`` might make progress or not in the success
case. I.e. in the success case the function ``f`` is guaranteed to be called
with a string ``s2`` which is the same as ``s`` or decreased, depending on the
progress indicator ``i``. The parser ``f a`` makes progress depending on ``j``.
The combined parser makes progress if ``p`` or ``f a`` make progress.

In the failure case the parser ``p`` must not change the string. The combined
parser fails as well and does not change the string either.

The remaining combinator is the biased choice.

.. code::

    </> (p: Parser A i) (q: Parser A j): Parser A (i and j) :=
        \ s :=
            match p s case
                \ (just a, s2)  := (just a, s2)
                \ (empty,  s2)  := q s

If ``p`` makes progress in the success case, then the result parser makes
progress as well.

``p`` might make progress in the failure case. Therefore the progress of the
combined parser depends of the progress of ``q``.

The combined parser ``p </> q`` is guaranteed to make progress in the success
case only if both guarantee progress in the success case.

Running the parser.

.. code::

    run (p: Parser A i)  (s: String): (Maybe A, String) :=
        p s

This completes the definition of the string parser module. The next functions
are defined outside the module and therefore cannot use the knowledge that an
object of type ``Parser A i`` is a function. Outside the module an object of
type ``Parser A i`` can be applied to a string only by the function call
``run p s``.


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
            if d c then k (just c) (succ n) s2
            else        k empty    n        s

The monad ``char d`` is a function which makes progress. It calls the
continuation function with a shorter string in the success case and with the
original string in the failure case.




.. code::

    -- Biased choice

    (</>) (p: Mon A R i) (q: Mon A R j): Mon A R (i and j) :=
        \ n s k :=
            p zero (case
                    \ empty,    zero,     s2 :=
                            -- no consumption, try 'q'
                        q (zero + n) s2 k

                    \ empty,    succ n2,  s2 :=
                            -- 'p' has consumed and failed
                        k empty (n2 + n)

                    \ just a,   n2,       s2 :=
                            -- 'p' has succeeded
                        k (just a) (n2 + n) s2
            )


.. code::

    -- Make the parser from a partial parser

    make (m: Cont R R i): Parser R :=
        m 0 "" (\ res n _ := done res n)






Backtracking (DRAFT)
================================================================================

PROBLEM: When backtracking is possible we have to buffer some consumed
characters. The buffer has to be part of the state. When a parser which shall be
made backtrackable fails and consumes characters, then part of the consumed
characters have to be shifted back to the lookahead. This breaks the progress
and termination proof!!


.. code::

    char (d: Char -> Bool): Mon Char R yes
    := case
        \ pre, (la := c :: la2),  k :=

            if d c then
                k (just c) (c :: pre) la2
                    -- prefix increased by one constructor
                    -- lookahead decreased by one constructor
            else
                k empty pre la
                    -- prefix and lookahead unchanged

        \ pre, (la := ""), k :=

            more (\ la := char pre la k)
                -- Not a recursive call, just a closure.
                -- Continuation paused until a new lookahead is
                -- available. Prefix and continuation unchanged.


    backtrack (p: Mon A R i): Mon A R no :=
        \ pre la k :=
            p "" la
              (case
                \ empty,  "",    la2 :=
                            -- 'p' failed without consumption
                    k empty "" la2

                \ empty,  pre2,  la2 :=
                            -- 'p' failed and consumed
                            -- consumption is in 'pre2'
                        k empty pre (revPrepend pre2 la2)

                \ just a, pre2, la2 :=
                        -- 'p' has succeeded and consumed 'pre2' since its start
                        -- The continuation has to be called with a consumption
                        -- of 'pre2 + pre'.
                    k (just a) (pre2 + pre) la2
              )
