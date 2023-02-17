Set Printing Universes.

Polymorphic Inductive
    DList@{u} (A: Type@{u}) (P: A -> Type@{u}): list A -> Type@{u}
:=
    | dnil: DList A P nil
    | dcons: forall x xs, P x -> DList A P xs -> DList A P (x :: xs).


Print DList.
(*
Polymorphic Fixpoint
    dappend (A: Type) (P: A -> Type)
    (a: DList (list A)) (b: DList (list A))
    : DList (list A)
:=
    match a with
    | dnil => dnil
    end.*)
