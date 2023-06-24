********************************************************************************
Monad Recursion
********************************************************************************


Parsing Monad
================================================================================

Here we assume that a string is a list of characters and define a parser which
returns in case of success something of type ``A`` as a function which takes a
string as input and returns a ``Maybe A`` and the not yet consumed part of the
string.

.. code::

    Parser (A: Any): Any :=
        String -> (Maybe A, String)

From our intuition it should clear that the output string is always a tail part
of the input string (proper or not proper) and the returned value in case of
success represents the consumed part of the input string. However this intuition
is not reflected in the type.


.. code::

    section "Basic Functions"
        {A B: Any}
    :=
        run  (s: String) (p: Parser A): (Maybe A, String) :=
            p s

        return (a: A): Parser A :=
            \ s := (just a, s)

        (>>=) (p: Parser A) (f: A -> Parser B): Parser B :=
            \ s :=
                match p s case
                    \ (just a, s2) :=
                        f a s2
                    \ (nothing, s2) :=
                        (nothing, s2)

        (</>) (p q: Parser A): Parser A :=
            \ s :=
                match p s case
                    \ (nothing, _) :=
                            -- note: automatic backtracking
                        q s
                    \ x :=
                        x


Now we define a parser which parses a single character, if it satisfies a
certain criterion.

.. code::

    section "Progress Maker" :=
        char (d: Char -> Bool): Parser Char :=
            case
                \ [] :=
                    (nothing, [])
                \ (orig := c :: rest) :=
                    if d c then
                        (just c, rest)
                    else
                        (nothing, orig)


It is easy to form a parser which parses one or more occurrences of a certain
character.

.. code::

    section "Parsing Sequences"
    :=
        many (p: Parser Char): Parser String :=
            -- monadic notation
            (do
                c    := p
                rest := many    -- recursive call without
                                -- decrementing argument
             :=
                return (c :: rest))
            </>
            return []

Unfortunately this combinator contains an illegal recursive call. Intuitively
the recursion terminates. The combinator ``p`` consumes in case of success one
character from the input string. The recursive call ``many`` happens only if
``p`` succeeds and gets an input string which is shorter than the original call.

However our intuition is not precise enough. If we call ``many (return 'a')``
i.e. ``p = return 'a'``, then the combinator ``p`` does not consume anything and
the recursion runs into an infinite loop. Therefore we need the

rule:
    A recursive call is allowed only after a combinator which has consumed at
    least one character from the input string.





Monadic Parser with Progress Indicator
================================================================================


Idea: We use a *progress indicator* as an index in the type to describe, when a
combinator has made progress.

.. code::

    type Progress: Any := [yes, no]     -- builtin type, like a boolean

    (or) Progress -> Progress -> Progress := case
        \ yes _   := yes
        \ _   i   := i

    (and) Progress -> Progress -> Progress := case
        \ yes i   := i
        \ no  _   := no

The progress indicator is used as an index to a type e.g. ``Parser A yes`` is
the type of a parser which returns an object of type ``A`` in the success case
and is guaranteed to make progress in the success case.

As an example we study a monadic parser with the following signature

.. code::

    module "Parser Monad"
        Parser: Any -> Progress -> Any  -- Type constructor without
                                        -- definition with a 'Progress'
                                        -- argument.

        section
            {A B: Any} {i j: Progress}
        :=
            run: String -> Parser A i -> (Maybe A, String)

            return: A -> Parser A no        -- no progress

            (>>=): Parser A i -> (A -> Parser B j) -> Parser B (i or j)
                -- Progress, if one of the arguments have progress in
                -- the success case.

            </> (p: Parser A i) (q: Parser A j): Parser A (i and j)
                -- Progress only if both have progress.

            char: (Char -> Bool) -> Parser Char yes
                -- Operation with guaranteed progress in the success case

    :=
        -- see below

In the implementation we first define the type ``Parser``:

.. code::

        -- Implementation of the module "Parser Monad"
        Parser (A: Any) (i: Progress): Any
        :=
            String -> (Maybe A, String)     -- 'i' is not used!


I.e. a ``Parser A i`` is a function which takes a string argument and returns a
``Maybe A`` and a string.


The following functions might need some standard arguments. Therfore we put all
the standard arguments into a section.

.. code::

        section
            {A B: Any} {i j: Progress}
        :=
            ...

The call ``run s p`` executes the parser ``p`` on the input string ``s``.

.. code::

            run (s: String) (p: Parser A i): (Maybe A, String)
            :=
                p s

The compiler has to guarantee that ``p`` is a terminating function. The only
argument to the function is a string. In case of recursion it has to decrease
the imput string.

The expression ``return a`` is a parser which always succeeds and does not give
any guarantee for progress. Therefore the compiler accepts any function.

.. code::

            return (a: A): Parser A no
            :=
                \ s := (just a, s)

``fail`` is a parser which always fails and does not give any guarantee for
progress.

.. code::

            fail: Parser A no
            :=
                \ s := (nothing, s)

The monadic expression ``p >>= f`` receives two arguments. A parser ``p`` and a
function ``f`` which can operate on the result of the parser ``p`` in case of
success. It has type ``Parser B (i or j)``. The monadic operator ``>>=`` is a
sequence operator. It executes ``p`` and ``f a`` in sequence, if ``p`` succeeds.
Therefore the parser makes progress, if either ``p`` or ``f a`` makes progress
(or both). The compiler regards the branch in which the function ``f`` is called
as a success case. I.e. it looks into the return type and tries to find an
inductive type. If there are failure cases the body of ``>>=`` must have a
pattern match expression and the failure branch (in which ``f`` is not called)
must identify the constructor of the corresponding type which identifies the
failure case.

.. code::

            (>>=) (p: Parser A i) (f: A -> Parser B j): Parser B (i or j)
            :=
                \ s0 :=
                    -- This operation defines success and failure.
                    match p s0 case
                        \ (just a, s1)  := f a s1           -- success of 'p'
                        \ (nothing, s1) := (nothing, s1)    -- failure of 'p'

Here the compiler can see that the return type ``(Maybe A, String)`` contains
the type ``Maybe A`` and the constructor ``just`` identifies the success case
and the constructor ``nothing`` identifies the failure case.


The monadic value ``char d`` has type ``Parser Char yes``. The function which
implements ``char d`` has to decrease the same argument in all success cases.
All functions which return a value of the form ``Parser _ yes`` have to be
implemented as functions which decrease the same argument in the success case.

.. code::

            char (d: Char -> Bool): Parser Char yes
            := case
                \ orig := [] :=
                    -- failure; argument not decreased
                    (nothing, orig)
                \ orig := c :: rest :=
                    if c d then
                        -- success; must decrease the argument
                        (just c, rest)
                    else
                        -- failure; argument not decreased
                        (nothing, orig)


The expression ``p </> q`` first executes ``p`` and in case of failure it
executes ``q``. It makes progress only of both ``p`` and ``q`` make progress in
case of success because only one of them is executed with success.

.. code::

            (</>) (p: Parser A i) (q: Parser A j): Parser A (i and j)
            :=
                \ s0 :=
                    match p s0 case
                        \ (nothing, _)  := q s0     -- 'p' fails, try 'q'
                        \ (ja, s1)      := (ja, s1) -- 'p' succeeds, ready



The following observations are important:

- The public view of the type does not give any definition. In the private view
  the type is defined as a function type and in the definition it ignores the
  progress indicator.

- There is a bind operation ``(>>=)`` which defines the operation ``m >>= f``.
  The implementation of the bind operation applies ``m`` to its arguments and
  does a case split on the result. Only in one case the function ``f`` is
  called. This case defines the success of the monadic value ``m``. The progress
  of the operation ``m >>= f`` is given, if one of the monadic values ``m`` or
  ``f a`` is a computation with progress.

- There is no restriction on operations which are specified without progress.
  The compiler accepts all definitions which are welltyped.

- All monadic values with progress have to decompose the same argument and put a
  structurally smaller value into the result in the success case. In the failure
  case only the original argument (or a structurally smaller argument can be put
  into the result.

- No monadic value puts a structurally greater element into the output. I.e. one
  argument of the function is either decreasing or stays the same. Therefore
  progress can never be *undone*.


Now we can write the recursive parsing combinator ``many``.

.. code::

    section {A: Any} :=
        many (p: Parser A yes): Parser (List A) no :=
            (do
                hd := p             -- 'p' makes progress
                tl := many          -- recursive call allowed
             :=
                return (hd :: tl))
            </>
            return []


Furthermore a combinator which parses one or more of a certain item is making
prograss as well.

.. code::

    section {A: Any} :=
        many1 (p: Parser A yes): Parser (List A) yes :=
            do
                hd := p             -- progress
                tl := many p        -- progress not guaranteed
            :=
                return (p :: tl)








State and Continuation Monads and Progress
================================================================================

A monadic type constructor which allows recursion must be a function which has a
state ``S`` which is threaded through all function calls and a variable type ``A``. An
object of type ``M A yes`` returns in the success case an object of type ``A``
decreases the state structurally. An object of type ``M A no`` returns in the
success case an object of type ``A`` but does not guarantee that the state is
structurally decreased.

The operation ``m >>= f`` executes first ``m`` and in the success case executes
``f a`` where ``a`` is the object returned by the monadic operation ``m``.

In order for that to work the monadic type constructor must have the form

.. code::

    M ... (A: Any) (i: Progress): Any :=
        S -> Res

where and object of type ``Res`` is either an object containing optionally an
object of type ``A`` and an object of type ``S`` or a function operating on an
object of type ``A`` and an object of type ``S``.

The state ``S`` must contain an inductive type. At each execution step the
inductive type either decreases or remains the same. A combinator which makes
progress (``yes``) must decrease the inductive object in the state structurally.
A combinator without guaranteeing progress (``no``) either decreases the
inductive type structurally or it remains the same. It never increases the
object structurally.


The following types are possible (only the essential arguments of ``M`` are
listed here, there might be more arguments):

.. code::

    M (A: Any) (i: Progress): Any :=
            -- simple state monad without failure
        A -> A * S

    M (A: Any) (i: Progress): Any :=
            -- state monad with success and failure
        S -> Maybe A * S

    M (A: Any) (i: Progress): Any :=
        S -> Result A Error * S

    M (A: Any) (i: Progress): Any :=
        S -> Result (A * S) Error


    M (A: Any) (i: Progress): Any :=
            -- continuation monad
        S -> (Maybe A -> S -> R) -> R

        -- other variants of the continuation monad
        S -> (Result A Error -> S -> R) -> R

        S -> (Result (A * S) Error -> R) -> R


For the monadic type ``M`` there is a chaining operator ``>>=``.


.. code::


    -- simple state monad
    (>>=) (m: M A i) (f: A -> M B j): M B (i or j) :=
        \ s :=
            match m s case
                \ (just a, s2) :=
                    f a s2
                \ (nothing, s2) :=
                    (nothing, s2)

    -- continuation monad
    (>>=) (m: M A i) (f: A -> M B j): M B (i or j) :=
        \ s k :=
            m   s
                (case
                    \ just a, s2 :=
                            -- 'm' succeeds:
                            -- execute 'f a' with the new state
                            -- and the continuation
                        f a s2 k
                    \ nothing, s2 :=
                            -- 'm' fails:
                            -- execute the continuation with the new state
                        k nothing s2)

Recursion rule: In a construct of the form ``m >>= f`` recursion is allowed in
the function ``f`` only if ``m`` or any monadic application before in the chain
makes progress.


In order to make recursive calls possible we need some elementary monadic
operations which make progress i.e. some ``m: M A yes``. Such an ``m`` operates
on a state ``s`` i.e. ``m s`` (state monad) or ``m s k`` (continuation monad)
are monadic operations. Here is the rule:

If ``m s`` returns an object of type ``A`` or ``m s k`` calls the continuation
``k`` with an object of type ``A`` then it is obliged to decrement the state
structurally i.e. either return a structurally smaller state or call the
continuation with a structurally smaller state.




Progress in IO
================================================================================

Let's look at a simplified IO monad:

.. code::

    IO: Any -> Progress -> Any

    section {A B: Any} {i j: Progress}
    :=
        return: A -> IO A no
        (>>=) : IO A i -> (A -> IO B j) -> IO B (i or j)
        getc: IO Char yes           -- reading is progress
        putc: Char -> IO Unit no    -- writing not
        eof:  IO A i -> IO B j -> IO A (i and j)


A program to copy input to output.

.. code::

    copy: IO Unit no :=
        (do
            ch := getc          -- progress
            putc ch
            copy)               -- recursion allowed
        |>
        eof (return ())

        -- or in other syntax
        (do [ch := getc, putc ch, copy]) |> eof (return ())
