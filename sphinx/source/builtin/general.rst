********************************************************************************
Module: alba.core.general
********************************************************************************

.. code-block::

    class Void: Any :=              -- no constructor


    class Unit: Any := (): Unit


    class Bool: Any :=
        true
        false


    class Reflect (A: Prop): Bool -> Any :=  -- NEEDED?
        true:  A        ->   Reflect true
        false: Not A    ->   Reflect false


    class (,) (A B: Any): Any :=            -- own module 'tuple' ?
        (,): A -> B -> (,)


    class Result (A B: Any): Any :=
        ok      :   A -> Result
        error   :   B -> Result


    class Either (α β: Any): Any :=
        left    :   A -> Either
        right   :   B -> Either


    Decision (A: Prop): Any :=
        Either A (Not A)


    class Maybe (A: Any): Any :=
        nothing : Maybe
        just    : A -> Maybe


    class Refine {A: Any} (P: Predicate A) :=
        refine x: P x -> Refine


    (|>)
        {A: Any}
        {F: A -> Any}
        (x: A)
        (f: ∀ x: F x)
        : F x
        -- 'x |> f': Apply the function 'f' to the argument 'x'.
    :=
        f x


    (<|)
        {A: Any}
        {F: A -> Any}
        (f: ∀ x: F x)
        (x: A)
        : F x
        -- 'f <| x': Apply the function 'f' to the argument 'x'.
    :=
        f x

    (>>)
        {A B C: Any}
        (f: A -> B)
        (g: B -> C)
        : A -> C
        -- 'f >> g': Apply 'f' and then 'g'.
    :=
        λ x := g (f x)

    (<<)
        {A B C: Any}
        (g: B -> C)
        (f: A -> B)
        : A -> C
        -- ' g << f': Apply 'f' and then 'g'.
    :=
        λ x := g (f x)
