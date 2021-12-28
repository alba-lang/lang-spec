Inductive Bounce (A: Type): Type :=
    | done: A -> Bounce A
    | more: (unit -> Bounce A) -> Bounce A.

Arguments done {_} _.
Arguments more {_} _.


Fixpoint iter {A: Type} (b: Bounce A): A :=
    match b with
    | done a =>
        a
    | more f =>
        iter (f tt)
    end.
