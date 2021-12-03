****************
Basic Types
****************


General
========================================


Logical
----------------------------------------

.. code-block::

    Predicate (A: Any): Any := A → Prop

    Relation (A B: Any): Any := A → B → Prop

    Endorelation (α: Any): Any := Relation α α

    class (=) {A: Any} (x: A): Predicate A :=
        identical: (=) x

    class Exist {A: Any} (P: Predicate A): Prop :=
        exist {x}: P x → Exist

    class False: Prop :=     -- no constructor

    class True: Prop  := trueValid: True

    (¬) (A: Prop): Prop := A → False

    class (∧) (A B: Prop): Prop :=
        (,): A → B → (∧)

    class (∨) (A B: Prop): Prop :=
        left  : A → (∨)
        right : B → (∨)

    class Accessible {A: Any} (R: Endorelation A): Predicate A :=
        access {x}: (∀ y, R y x → Accessible y) → Accessible x


Remark on existential quantification:
    Existential quantification is often needed for more than one variable. E.g. if
    we have a relation ``R: A → B → Prop`` we can write::

        exAB: Exist (λ a := Exist (λ b := R a b)) :=
            exist (exist rab)

        -- with shorthand
        exAB: some a b: R a b :=
            exist (exist rAB)
            -- with implicit variables made explicit
            exist {a} (exist {b} rAB)

    where ``exAB`` is a proof that ``a`` and ``b`` satisfying ``R a b`` exist and
    ``rAB`` is a proof that some values ``a``  and ``b`` in the context satisfy ``R
    a b``. We can pattern match on ``exAB``::

        inspect
            exAB
        case
            λ (exist {a0} (exist {b0} rAB0)) :=
                -- Now we have variables 'a0' and 'b0' in the context and a proof
                -- 'rAB0' that 'R a0 b0' is satisfied. :}


General
----------------------------------------

.. code-block::

    class Void :=              -- no constructor

    class Unit := unit

    class Bool := true; false

    class Reflect (A: Prop): Bool → Any :=
        true:  A        →   Reflect true
        false: Not A    →   Reflect false

    class List {A: Any} := ([]); (::): A → List → List

    class (,) (A B: Any): Any :=
        (,): A → B → (,)

    class Result (A B: Any): Any :=
        ok      :   A → Result
        error   :   B → Result

    class Either (α β: Any): Any :=
        left    :   A → Either
        right   :   B → Either

    Decision (A: Prop): Any :=
        Either A (Not A)

    class Maybe (A: Any): Any :=
        nothing : Maybe
        just    : A -> Maybe

    class Refine {A: Any} (P: Predicate A) :=
        refine x: P x → Refine

    (|>)
        {A: Any}
        {F: A → Any}
        (x: A)
        (f: ∀ x: F x)
        : F x
    :=
        f x

    (<|)
        {A: Any}
        {F: A → Any}
        (f: ∀ x: F x)
        (x: A)
        : F x
    :=
        f x

    (>>)
        {A B C: Any}
        (f: A → B)
        (g: B → C)
        : A → C
    :=
        λ x := g (f x)

    (<<)
        {A B C: Any}
        (g: B → C)
        (f: A → B)
        : A → C
    :=
        λ x := g (f x)



Natural and Integer
----------------------------------------

There are arbitrary sized natural numbers and integer numbers. Both are given a
definition as an inductive type. However they are compiled to more efficient
types in the runtime.

Therefore the basic arithmetic functions and decision procedures are also
defined in terms of the inductive types. But these arithmetic functions and
decision procedures are compiled to more efficient runtime representations.

.. code-block::

    -- Natural Numbers
    class ℕ: Any := zero: ℕ; succ: ℕ → ℕ

    (=?): ℕ → ℕ → Boolean := case
        λ zero      zero        := true
        λ (succ n)  (succ m)    := n =? m
        λ _         _           := false

    (<?): ℕ → ℕ → Boolean := case
        λ _         zero        := false
        λ zero      (succ _)    := true
        λ (succ n)  (succ m)    := n <? m

    (+): ℕ → ℕ → ℕ := case
        λ n zero        := n
        λ n (succ m)    := succ (n + m)

    (-): ℕ → ℕ → ℕ := case
        λ n         zero        :=  n
        λ n         (succ _)    :=  zero
        λ (succ n)  (succ m)    :=  n - m

    (*): ℕ → ℕ → ℕ := case
        λ zero      m           :=  zero
        λ (succ n)  m           :=  n * m + m

    (^): ℕ → ℕ → ℕ := case
        λ n         zero        := succ zero
        λ n         (succ m)    := n * (n ^ m)

    divAux: ℕ → ℕ → ℕ → ℕ → ℕ := case
            -- n / (succ m) = divAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  divAux (succ k) m n m
        λ k m   (succ n)    (succ j):=  divAux k m n j

    modAux: ℕ → ℕ → ℕ → ℕ → ℕ := case
            -- n % (succ m) = modAux 0 m n m
        λ k m   zero        j       :=  k
        λ k m   (succ n)    zero    :=  modAux 0 m n m
        λ k m   (succ n)    (succ j):=  modAux (succ k) m n j


Key idea in ``divAux`` and ``modAux``: The number ``k`` is initialized to
``zero`` and incremented in some cases such that at the end it is either the
quotient or the remainder. Both are total functions have efficient runtime
representations.





.. code-block::

    -- Integer Numbers
    class ℤ: Any :=
        positive:  ℕ → ℤ
        negative1: ℕ → ℤ    -- 'negative1 n' represents '- (succ n)'

    (+): ℤ → ℤ → ℤ := ...
    (*): ℤ → ℤ → ℤ := ...

    ...         -- details left out here


.. note::

    Missing: We have to include definitions of all arithmetic operators and
    decision procedures (equality, order relation) which have an efficient
    builtin representation.








Scalar Types
================================

Integer Types
----------------------------------------

There are signed and unsigned integers for various bitsizes

``Byte``
    8 bit unsigned integer

``Int32, UInt32``
    32 bit signed and unsigned integer

``Char``
    32 bit unicode code point

``Int64, UInt64``
    64 bit signed and unsigned integer

``Int, UInt``
    architecture dependent signed and unsigned integer



Semantics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The semantics of builtin unsigned and signed integers is defined via an
embedding into ℕ or ℤ. This embedding is defined by an embedding function and a
proof that it is an embedding (i.e. it is injective).

In the following we show the necessary definitions for ``UInt32``.

.. code-block::

    UInt32.toNatural:   UInt32 → ℕ
    UInt32.fromNatural: ℕ → UInt32        -- modulo 2^32

    UInt32.embedded: ∀ n: fromNatural (toNatural n) = n
    UInt32.embedded: ∀ n m: toNatural n = toNatural m → n = m

    UInt32.(≤) (n m: UInt32): Prop :=
        toNatural n ≤ toNatural m

    UInt32.(≤?) (n m: UInt32): Bool

    Unit32.bitSize: ℕ      -- bitsize is 'n + 1', cannot be zero

    UInt32.(+) (n m: UInt32): UInt32 :=
        fromNatural (toNatural n + toNatural m)

    UInt32.(-) (n m: UInt32): UInt32 :=
        fromNatural (toNatural n + 2^(succ bitsize)- toNatural m)






Compile to Javascript
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the node platform and the browser, scalar values up to the bitsize of 32 can
be represented as javascript numbers. 64 bit scalars have no direct
representation in javascript. We have to generate an object with two 32 bit
sized numbers.

This workaround is necessary although javascript numbers are 64 bit floating
point values. However it is not possible to do 64 bit integer arithmetic in
javascript on 64 bit floating point values.

With the ``x|0`` annotation we can force javascript to do signed 32 bit integer
arithmetics on javascript numbers. The expression ``x >> 0`` converts 32 bit
integer as well. ``x >>> 0`` converts to an unsigned 32 bit integer (i.e. ``-1
>>> 0`` is converted to ``0xff_ff_ff_ff``).

Signed and unsigned integer arithmetic is the same. Only the javascript
comparison operators ``<=``, ``<``, ... give wrong results. Before doing the
comparisons, it is necessary to add the lowest negative number
``0x8000_0000`` which is :math:`-2^{31}`. This shifts the number zero to the
lowest negative number, i.e. all other numbers are greater or equal to this
number.


Compile to Machine Code
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


If compiling to machine code (e.g. via LLVM or Rust) the situation is different.

Scalar types can be allocated on the stack. This is possible to bitsizes up to
128 (or maybe in LLVM even more).

The code is fastest if all scalar objects are allocated on the stack and scalar
objects within other objects are completely within the surrounding object. I.e.
there are no pointers to scalar objects (they are *unboxed*). This creates two
possible problems:

Garbage collection:
    Pointer occupy a machine word and the machine number occupies a machine word
    as well. The runtime cannot distinguish between a machine number and a
    pointer into the heap.

    Ocaml resolved this problem by making the machine numbers of size
    :math:`2^{31}` or :math:`2^{63}` and representing the number :math:`i` by
    the number :math:`2i + 1`. Therefore in machine numbers the least
    significant bit has always the value 1. Since heap locations are always word
    aligned the corresponding pointers have a least significant bit of 0. The
    garbage collector can recognize pointer into the heap by looking at the
    least significant digit.

Polymorphic Functions:
    Generic functions on objects pointing into the heap need only one machine
    code representation for all its possible types.

The most efficient and closest to compilable mainstream languages would be to
represent all scalar types which can fit into a machine word by the
corresponding machine word and represent scalar types which cannot fit into a
machine word (e.g. ``Int64`` on 32 bit machines) by pointer to a boxed value on
the heap.

Polymorphic arrays are then always sequences of machine words. Character arrays
on 64 bit machines need 64 bits per character (however strings remain packed).

The garbage collector needs type information. It cannot know by just looking at
a word if it represents a scalar value or a pointer into the heap. It has to
know the layout of each stack frame and the layout of all objects on the heap.

.. note::
    More detailed analysis needed!




Floating Point
----------------------------------------
