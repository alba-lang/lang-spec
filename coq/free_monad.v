Require Import List.
Import ListNotations.


Fail
Inductive Free (F: Type -> Type) (A: Type): Type :=
| pure: A -> Free F A
| roll: F (Free F A) -> Free F A.
(*        ^ not strictly positive occurrence of 'Free' *)


Inductive Algebra (F: Type -> Type) (A: Type): Type :=
| phi: F A -> Algebra F A.

Arguments phi [_ _].





Inductive Free (F: Type -> Type) (A: Type): Type :=
| free: (forall X, Algebra F X -> (A -> X) -> A) -> Free F A.

Check phi [1;2;3].
