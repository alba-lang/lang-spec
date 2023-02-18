Inductive RSet@{i} : Type@{i} :=
    ens_intro : forall A : Type@{i}, (A -> RSet) -> RSet.

Definition idx (A : RSet) : Type :=
    match A with
        ens_intro T _ => T
    end.

Definition elem (S : RSet) (i : idx S) : RSet :=
    match
        S as S' return idx S' -> RSet
    with
        ens_intro A f => (fun (j: A) => f j)
    end i.

(*
Definition elem_of (S1 S2: RSet): Prop :=
    match S2 with
        ens_intro A f =>
            _
    end.
*)

Definition elem_of (x A : RSet): Prop :=
    exists a, elem A a = x.

Definition Union {T: Type} (f : T -> RSet): RSet :=
    ens_intro
        {x : T & idx (f x)}
        (fun u => elem (f (projT1 u)) (projT2 u)).

Lemma
    elem_of_union {T} (f : T -> RSet) A
    : elem_of A (Union f) <-> exists t, elem_of A (f t).
Proof.
 split.
 - intros [[z idx] Hzidx]; exists z, idx; assumption.
 - intros [z [idx Hzidx]]; exists (existT _ z idx); assumption.
Qed.


Definition singleton_if (a : RSet) (P : Prop) : RSet :=
    ens_intro {x : unit | P} (fun _ => a).

Lemma
    elem_of_singleton_if a b P : (P /\ a = b) <-> elem_of b (singleton_if a P).
Proof.
 split.
 - intros [HP ->].
   exists (exist _ tt HP); reflexivity.
 - intros [[z Hz1] Hz2]; tauto.
Qed.

Definition Russel : RSet :=
    Union (fun A : RSet => singleton_if A (not (elem_of A A))).

Theorem
    Russel's_Paradox : elem_of Russel Russel <-> not (elem_of Russel Russel).
Proof.
 split.
 - intros Helem.
   apply elem_of_union in Helem as [t Ht].
   apply elem_of_singleton_if in Ht as [? ->].
   assumption.
 - intros Hnelem.
   apply elem_of_union.
   exists Russel.
   apply elem_of_singleton_if; split; [assumption|reflexivity].
Qed.
