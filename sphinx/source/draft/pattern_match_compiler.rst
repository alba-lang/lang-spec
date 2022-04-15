********************************************************************************
Pattern Match Compiler
********************************************************************************

Mikael Pettersson (Sweden)


Basics
============================================================

A pattern match expression has the general form:

.. code::

    case
        \ p11 p12 ... := e1
        \ p21 p22 ... := e2
        ...
        \ pn1 pn2 ... := en

We convert the case expression step by step into a case tree.


The first *m* rows begin with a variable pattern:
    (assume *0 < m < n*)
    In that case all rows above *m* are not reachable. This is an error for the
    whole pattern match expression, if the not reachable rows do not occur in
    other branches.

All pattern in the first column are variable pattern:
    We have to rename the variable such that the same variable appears in all
    rows and then collapse the first column into one case.

    .. code::

        \ x :=
            case
                \ p12 ... := e1
                \ p22 ... := e2
                ...
                \ pn2 ... := en


The first column contains constructor pattern:
    Pattern with the same constructor have to be renamed such that the same
    variables occur in the corresponding positions. If the first row has
    variable pattern, then the same variable has to be chosen and this variable
    has to appear in all constructor pattern. Assume we have

    .. code::

        case
            \ []        p12 ... := e1
            \ x         p22 ... := e2
            \ (x :: xs) p32 ... := e3

        -- rename
        case
            \ (a := [])         p12 ... := e1
            \ a                 p22 ... := e2
            \ (a := x :: xs)    p32 ... := e3

    If the constructors are exhaustive, no default case is needed. Otherwise a
    default case is needed. The rows with a variable pattern belong to all
    cases.

    .. code::

        case
            \ (a := []) :=
                case
                    \ p12 ... := e1
                    \ p22 ... := e2     -- duplicated
            \ (a := x :: xs) :=
                case
                    \ p22 ... := e2     -- duplicated
                    \ p32 ... := e3

    If the constructors are not exhaustive and the column has no variable
    pattern, then the whole pattern match is not exhaustive.




?
============================================================

Renaming of the variables ensures that each pattern in different rows which
matches the same part of the input object has the same variable name. Algebraic
data types construct tree like objects. Therefore we can use the Dewey decimal
notation to have a canonical naming of the variables.

Canonical naming: xijk...

- i: constructor (with some arity)
- j: j-th argument of the constructor

Other namings are possible as long as the same part of the input object gets the
same variable. E.g. in lists the constructor nil does not have arguments. The
constructor cons has 2 arguments, the head and the tail. Therefore x1 can be the
name of the head and x2 the name of the tail, if x ist the root.


Example ``nodups``
============================================================


.. code::

    nodups: List Int -> List Int := case
        \ (x :: y :: ys)    := e1
        \ xs                := xs


        e1 := if x =? y then res else x :: res
        where
            res := nodups (y :: ys)



Introduce root variables and rename the variables consistently.

.. code::

    nodups:
        all (x: List Int): List Int
    :=
        \ (x = x1 :: (x2 = (x21 :: x22)))               := q1

        \ x                                             := q2


Now we have two rows and one pattern column and one result column::

    match0: {x = x1 :: (x2 = (x21 :: x22))}     {q1}
            {x}                                 {q2}



The constructor *::* matches row1 and row2. It is not exhaustive, therefore we
need a default case. The first case distinction is between the *::* constructor
and *otherwise*.

.. code::

    q0: inspect x case
            \ (x1 :: x2)    := match1
            \ _             := match2

*match1* can be entered if *x* has been constructed by the *::* constructor. The
remaining pattern is *x2* which is either the constructor pattern *x2 = x21 ::
x22* pattern or the variable pattern *x2*.

.. code::

    match1: {x2 = x21 :: x22}       {q1}
            {x2}                    {q2}

*match1* is not final i.e. we need a new state *q3*.

*match2* can be entered if *x* has not been constructed by the *::* constructor.
There is no remaining pattern.

.. code::

    match2: {}  {q2}                -- reduces to q2


*match2* immediately reduces to *q2* i.e. it is a final state.

The complete *q0* state looks like::

    q0: inspect x case
            \ (x1 :: x2)    := q3
            \ _             := q2

Now we have to construct *q3* from *match1*. *::* is the only constructor in
*match1*, but it is not exhaustive (i.e. we need a default case.

.. code::

    q3: inspect x2 case
            \ (x21 :: x22) :=   match3
            \ _            :=   match4

*match3* comes from *match1* where *x2* has been constructed by
*::*. This is possible for both rows. There is no more pattern to match.
Therefore we get::

    match3: {}  {q1}
            {}  {q2}

which reduces to *q1*.

*match3* comes from *match1* where *x2* has been constructed by anything
different from *::*. This is possible only for the second row::

    match4: {}  {q2}

which reduces to *q2*.

For *q3* we get::

    q3: inspect x2 case
            \ (x21 :: x22)  := q1
            \ _             := q2

*q2* occurs in *q0* and *q3*. In our simple case *q2 = x* but it might be a more
complicated expression which should not be repeated and the compiler should
generate a local abbreviation.

.. code::

    nodups:
        all (x: List Int): List Int
    := \ x :=
        inspect x case
            \ (x1 :: x2)    :=
                inspect x2 case
                    \ (x21 :: x22) :=
                        if x1 =? x21 then
                            nodups x2
                        else
                            x1 :: nodups x2
                    \ _ :=
                        abbr x
            \ _ :=
                abbr x
       where
        abbr x := x



Example: Eliminate Duplicates
============================================================


.. code::

    nodups: List Int -> List Int := case
        \ (a := x :: (b := y :: c))  :=  q1
        \ a                          :=  a

        -- where q1:
        --  if x =? y then
        --      nodups b
        --  else
        --      x :: nodups b

*::* is the only constructor, it is not exhaustive.

.. code::

    nodups: List Int -> List Int := case
        \ (a := x :: b) :=
            -- rows which fall into this case:
            -- \ (a := x :: (b := y :: c)) := q1
            -- \ (a := x :: b)             := a
            inspect b case
                \ (y :: c)  := q1
                \ _         := a
        \ a :=
            a


Examply *unwieldy*
============================================================


.. code::

    unwieldy {A: Any}: List A -> List A -> R := case
        \ [] [] := c
        \ a  b  := f a b

*[]* is the only constructor in the first column, it is not exhaustive.

.. code::

    \ (a := []) :=
        -- \ (a := []) (b := []) := c
        -- \ (a := []) b         := f a b
        case
            \ (b := [])     := c
            \ b             := f a b

    \ a :=
        -- \ a b := f a b
        case            -- 'case' not strictly needed, only variable pattern
            \ b := f a b



Example: *demo*
============================================================


.. code::

    demo {A: Any}: List A -> List A -> R := case
        \ []        b           := f b
        \ a         []          := g a
        \ (x :: xs) (y :: ys)   := h x xs y ys


First columns has both constructors *[]* and *::*, it is exhaustive.

.. code::

        \ (a := []) :=
            -- \ (a := [])  b   := f b
            -- \ (a := [])  []  := g a
            -- second case is shadowed
            case \ b := f b
        \ (a := x :: xs) :=
            -- \ (a := x :: xs)     []          := g a
            -- \ (a := x :: xs)     (y :: ys)   := h x xs y ys
            case
                \ [] := g a
                \ (y :: ys) := h x xs y ys


Example: *less equal*
============================================================

.. code::

    (<=?): Natural -> Natural -> Bool := case
        \ zero      _           := true
        \ _         zero        := false
        \ (succ n)  (succ m)    := n <=? m

.. code::

    \ zero :=
        -- \ (a := zero)    _       := true
        -- \ (_ := zero)    zero    := false
        -- second case is shadowed
        case \ _ := true

    \ (succ n) :=
        -- \ (_ := succ n)  zero            := false
        -- \ (a := succ n)  (b := succ m)   := n <=? m
        case
            \ zero          := false
            \ succ m        := n <=? m


Example: *greater equal*
============================================================


.. code::

    (>=?): Natural -> Natural -> Bool := case
        \ _             zero        := true
        \ zero          _           := false
        \ (succ n)      (succ m)    := n >=? m

.. code::

    \ zero :=
        -- \ (_ := zero)    zero    := true
        -- \ zero           _       := false
        case
            \ zero :=
                -- \ (b := zero)    := true
                -- \ (_ := zero)    := false
                true
            \ succ m :=
                -- \ (_ := succ m)  := false
                false

    \ succ n :=
        -- \ (_ := succ n)      zero        := true
        -- \ (a := succ n)      (succ m)    := n >=? m
        case
            \ zero      := true
            \ succ m    := n >=? m


After clean up:

.. code::

    (>=?): Natural -> Natural -> Bool := case
        \ zero :=
            case \ zero     := true
                 \ (succ m) := false
        \ succ n :=
            case \ zero     := true
            case \ (succ m) := n >=? m




Example: *map2*
============================================================


.. code::

    map2 {A B C: Any} (f: A -> B -> C): List A -> List B -> List C
    := case
        \ []        _           := []
        \ _         []          := []
        \ (x :: xs) (y :: ys)   := f x y :: map2 xs ys


    -- analysis:
    \ [] :=
        -- \ []         _       := []
        -- \ (_ := [])  []      := []
        -- first row shadows second row
        case \ _ := []

    \ (x :: xs) :=
        -- \ (_ := _ :: _)  []          := []
        -- \ (x :: xs)      (y :: ys)   := f x y :: map2 xs ys
        case \ []           := []
             \ (y :: ys)    := f x y :: map2 xs ys

    -- cleanup:
    case
        \ [] :=
            \ _ := []
        \ (x :: xs) :=
            case
                \ []        := []
                \ (y :: ys) := f x y :: map2 xs ys


The same with vectors:

.. code::

    map2
        {A B C: Any} (f: A -> B -> C)
        : all {n}: Vector A n -> Vector B n -> Vector C n
    := case
        \ []        []          := []
        \ (x :: xs) (y :: ys)   := f x y :: map2 xs ys

    -- Analysis:
    \ [] :=
        -- \ [] [] := []
        -- unification: n := 0, therefore second column is exhaustive
        case \ [] := []
    \ (x :: xs) :=
        -- \ (x :: xs) (y :: ys) := f x y :: map2 xs ys
        -- unification: n := succ m, therefore second column is exhaustive
        case \ (y :: ys) := f x y :: map2 xs ys

    -- cleanup:
    case
        \ [] :=
            \ _ := []
        \ (x :: xs) :=
            case \ (y :: ys) := f x y :: map2 xs ys
