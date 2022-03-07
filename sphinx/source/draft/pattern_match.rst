********************************************************************************
Pattern Match
********************************************************************************

Ideas from "Implementation of Functional Languages" of Simon Peyton Jones.

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
