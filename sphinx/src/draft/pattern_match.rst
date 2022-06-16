********************************************************************************
Pattern Match
********************************************************************************


Ideas from "Implementation of Functional Languages" of Simon Peyton Jones.
================================================================================

We transform a pattern match expression::

    case
        \ p11 p12 ... p1m := e1
        ...
        \ pn1 pn2 ... pnm := e2

into::

    \ x1 x2 ... xm :=
        inspect
            x1 x2 ... xm
        case
            \ p11 p12 ... p1m := e1
            ...
            \ pn1 pn2 ... pnm := e2


- All ``p11``, ``p21``, ... and ``pn1`` are variable pattern (say ``y``)::

        \ x1 x2 ... xm :=
            inspect
                x2 ... xm
            case
                \ p12[y:=x1] ... p1m[y:=x1] := e1[y:=x1]
                ...
                \ pn2[y:=x1] ... pnm[y:=x1] := en[y:=x1]


- All ``p11``, ``p21``, ... and ``pn1`` are constructor pattern::

        \ x1 x2 ... xm :=
            inspect
                x1
            case
                \ p11 :=
                    inspect x2 ... xm case
                        \ p12 ... p1m := e1
                        ...
                        \ pn2 ... pnm := en
                \ p21 :=
                    -- same
                ...



Examples
================================================================================

Less equal and greater equal:

.. code::

    (<=?): Natural -> Natural -> Bool := case
        \ zero :=
            \ _ := true
        \ succ n := case
            \ zero   := false
            \ succ m := n <=? m

    (>=?): Natural -> Natural -> Bool := case
        \ zero := case
            \ zero   := true
            \ succ m := false
        \ succ n := case
            \ zero   := true
            \ succ m := n >=? m


map2:

.. code::

    map2 {A B C: Any} (f: A -> B -> C): List A -> List B -> List C
    := case
        \ [] :=
            \ _ := []
        \ x :: xs := case
            \ []        := []
            \ y :: ys   := f x y :: map2 xs ys

    -- the same with vectors
    map2
        {A B C: Any} (f: A -> B -> C)
        : all {n}: Vector A n -> Vector B n -> Vector C n
    :=
        \ {_} := case
            \ [] := case
                \ [] := []
            \ x :: xs := case
                \ y :: ys :=
                    f x y :: map2 xs ys


nodups:

.. code::

    nodups {A: Any} ((=?): A -> A -> Bool): List A -> List A := case
        \ [] := []
        \ x :: xs :=
            inspect xs case
                \ [] := [x]
                \ y :: ys :=
                    (if x =? y then res else x :: res)
                    where
                        res := nodups (y :: ys)



A data type for a bounded natural number::

    type Below: Natural -> Any :=
        start {k}: Below (succ k)
        next  {k}: Below k -> Below (succ k)

Look up in a vector::

    -- cascaded form
    at {A: Any}: all {n}: Below n -> Vector A n -> A :=
        \ {k} := case
            \ (start {k}) := case
                \ x :: _ := x
            \ (next {k} below) :=
                \ _ :: xs := at below xs

    -- flat form
    at {A: Any}: all {n}: Below n -> Vector A n -> A := case
        \ start (x :: _) :=
            x
        \ (next below) (_ :: xs) :=
            at below xs
