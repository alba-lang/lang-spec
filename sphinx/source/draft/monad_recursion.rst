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
                inspect p s case
                    \ (just a, s2) :=
                        f a s2
                    \ (nothing, s2) :=
                        (noting, s2)

        (</>) (p q: Parser A): Parser A :=
            \ s :=
                inspect p s case
                    \ nothing :=
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





Progress Indicator
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


.. code::

    module "Parser Monad"
        Parser: Any -> Progress -> Any  -- Type constructor without
                                        -- definition with a 'Progress'
                                        -- argument.

        section {A B: Any} {i j: Progress} :=
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
        Parser (A: Any) (i: Progress): Any
        :=
            String -> (Maybe A, String)     -- 'i' is not used!

        section {A B: Any} {i j: Progress} :=
            run s p :=
                p s

            return a s := (just a, s)

            (>>=) p f s0 :=
                -- This operation defines success and failure.
                inspect p s case
                    \ (just a, s1)  := f a s1           -- success of 'p'
                    \ (nothing, s1) := (nothing, s1)    -- failure of 'p'

            (</>) p q s0 :=
                inspect p s0 case
                    \ (nothing, _)  := q s0     -- 'p' fails, try 'q'
                    \ x             := x        -- 'p' succeeds, ready

            char d := case
                \ [] :=
                    -- failure; argument not increased
                    (nothing, [])
                \ (orig := c :: rest) :=
                    if c d then
                        -- success; must decrease the argument
                        (just c, rest)
                    else
                        -- failure; argument not increased
                        (nothing, orig)



The following observations are important:

- The public view of the type does not give any definition. In the private view
  the type is defined as a function type and in the definition it ignores the
  progress indicator.

- There is a bind operation ``(>>=)`` which defines the operation ``m >>= f``.
  The implementation of the bind operation applies ``m`` to its arguments and
  does a case split on the result. Only in one case the function ``f`` is
  called. This case defines the success of the monadic value ``m``. The progress
  of the operation ``m >>= f`` is given, if one of the monadic values ``m`` or
  ``f a`` computations with progress.

- There is no restriction on operations which are specified without progress.
  The compiler accepts all definitions which are welltyped.

- All monadic values with progress have to decompose the same argument and put a
  structurally smaller value into the result in the success case. In the failure
  case only the original argument (or a structurally smaller argument can be put
  into the result.

- No monadic value puts a structurally greater element into the output. I.e. one
  argument of the function is either decreasing or stays the same. Therefore
  progress can never be *undone*.
