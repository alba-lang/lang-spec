********************************************************************************
Logic
********************************************************************************





Propositions
================================================================================


.. code::

    False: Prop := all {P: Prop}: P

    (Not) (P: Prop): Prop := P -> False




Equality
================================================================================


.. code::

    type (=) {A: Any}: A -> A -> Prop :=
        same {x}: x = x


    map
        {A B: Any}
        (f: A -> B)
        : all {a b: A}: a = b -> f a = f b
    := case
        \ same := same


    flip {A: Any}: all {a b: Any}: a = b  ->  b = a :=  case
        \ same := same


    (,) {A: Any}: all {a b c: A}: a = b  ->  b = c  ->  a = c := case
        \ same, same := same


    replace {A: Any} {P: A -> Prop}: all {a b}: a = b  ->  P a  ->  P b := case
        \ same, p := p
