Inductive Term@{i}: Type@{i} -> Type@{i+1} :=
    (*                                ^ Type@{i} would cause
                                        a universe inconsistency. *)
    | nat_: nat -> Term nat
    | add: Term (nat -> nat -> nat)
    | app {A B: Type@{i}}: Term (A -> B) -> Term A -> Term B.
    (*                ^ constraint i < i+1 ! *)


Fixpoint eval {A: Type} (t: Term A): A :=
    match t with
    | nat_ i  => i
    | add     => (fun x y => x + y)
    | app f t => (eval f) (eval t)
    end.



Inductive SmallTerm@{i}: Type@{i} -> Type@{i} :=
    (*                                     ^
                        no universe inconsistency,
                        because 'Type@{i}' is not used
                        as a type of constructor
                        arguments. *)
    | nat__: nat -> SmallTerm nat
    | add_: SmallTerm (nat -> nat -> nat).
