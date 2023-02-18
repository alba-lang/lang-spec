Inductive RSet@{i} : Type@{i} :=
    ens_intro : forall A : Type@{i}, (A -> RSet) -> RSet.

Definition TypeOf (s : RSet) : Type :=
    match s with
        ens_intro T _ => T
    end.

(* Element of 'S' where 'i' is an object of 'TypeOf S'. *)
Definition elem (s : RSet) (i : TypeOf s) : RSet :=
    match
        s as s' return TypeOf s' -> RSet
    with
        ens_intro A f => f
    end i.



(* Is s1 an element of s2? *)
Definition IsElem (s1 s2 : RSet): Prop :=
    exists a: TypeOf s2, elem s2 a = s1.




Definition Union {T: Type} (f : T -> RSet): RSet :=
    ens_intro
        {x : T & TypeOf (f x)} (* Pairs (x: T, y: TypeOf (f x)) *)
        (fun u => elem (f (projT1 u)) (projT2 u)).




Lemma
    IsElem_union {T} (f : T -> RSet) (s: RSet)
    : IsElem s (Union f) <-> exists t, IsElem s (f t).
Proof.
 split.
 - intros [[z idx] Hzidx]; exists z, idx; assumption.
 - intros [z [idx Hzidx]]; exists (existT _ z idx); assumption.
Qed.




Definition singleton_if (s : RSet) (P : Prop) : RSet :=
    ens_intro {_ : unit | P} (fun _ => s).



Lemma
    IsElem_singleton_if (a b: RSet) (P: Prop) : (P /\ a = b) <-> IsElem b (singleton_if a P).
Proof.
 split.
 - intros [HP ->].
   exists (exist _ tt HP); reflexivity.
 - intros [[z Hz1] Hz2]; tauto.
Qed.



Definition Russel : RSet :=
    Union (fun A : RSet => singleton_if A (not (IsElem A A))).



Theorem
    Russel's_Paradox : IsElem Russel Russel <-> not (IsElem Russel Russel).
Proof.
 split.
 - intros Helem.
   apply IsElem_union in Helem as [t Ht].
   apply IsElem_singleton_if in Ht as [? ->].
   assumption.
 - intros Hnelem.
   apply IsElem_union.
   exists Russel.
   apply IsElem_singleton_if; split; [assumption|reflexivity].
Qed.


Lemma absurd: False.
Proof.
 generalize Russel's_Paradox. intuition.
Qed.


(*Print absurd.*)
