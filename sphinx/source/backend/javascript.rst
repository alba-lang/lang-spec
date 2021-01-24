.. _Javascript:

****************************************
Javascript
****************************************


.. highlight:: javascript


General
============================================================

Names
--------------------------------------------------

The names used in the source language might interfere with the javascript
keywords and operators. Since javascript does not allow to define functions with
an operator name, operators of the source language have to be represented by
valid javascript identifiers.



**DETAILS MISSING!!**

Draft:

Javascript allows identifiers to begin with ``_`` and to contain ``$``. Dots
``.`` are not allowed.





Strings and Characters
--------------------------------------------------

The elements of javascript strings are 16 bit unsigned integer values. Each
element is treated as a UTF-16 code unit value.


There is no character object in javascript. Characters can be represented by one
element strings (or two elements strings in case of surrogat pairs).


Two subsequent elements ``c₁`` and ``c₂`` can be a surrogate pair. This is the
case if ``c₁`` is in the range ``0xd800 - 0xdbff`` and ``c₂`` is in the range
``0xdc00 - 0xdfff``. In that case both represent the unicode code point ``(c₁ -
0xd800) * 0x400 + (c₂ - 0xdc00) + 0x10000``.

All elements which are not part of a surrogat pair are interpreted as the
corresponding unicode code point.



Algebraic Types
--------------------------------------------------

Objects of algebraic types can be implemeneted by arrays. For each constructor
we use an :math:`n+1`\ ary array where :math:`n` is the number of runtime
arguments the constructor takes. The first element of the array is tag i.e. a
number :math:`i` which says that the :math:`i`\ th constructor has been used to
construct the object. The other array elements are arguments to construct the
object.

E.g. to encode a list we use::

    [0]                         // empty list

    [1, 'a', [1, 'b', [0]]]     // the list ["a", "b"]







Pattern Match
--------------------------------------------------

The most straightforward way is to use a ``switch/case`` expression.

Example: List append and reverse

.. code-block:: alba

    append {α: Any}: List α → List α → List α :=
        λ []            ys  := b
        λ (x :: xs)     ys  := x :: (append xs ys)

    reverse {α: Any}: List α → List α :=
        λ []        :=  []
        λ (x :: xs) :=  append (reverse xs) [x]

.. code-block::

    function append (xs, ys) {
        switch(xs[0]) {
        case 0:
            return ys
        default:
            return [1, xs[1], append (xs[2], ys)]
        }
    }

    function reverse (xs) {
        switch (xs[0]) {
        case 0:
            return xs
        default:
            return append (reverse (xs[2]), [1, xs[1], [0]])
        }
    }







Tail Recursion
--------------------------------------------------

The javascript engines in the browser and node cannot handle deep recursion
well. Therefore compiling recursive Alba functions to recursive javascript
functions is not efficient and might frequently cause stack overflows.
Therefore we have to avoid deep recursion.

If a function is tail recursive, it can be easily implemented by a javascript
loop.

The general format of the definition of a tail recursive function looks like

.. code-block:: alba

    f params: args := case
        \ pattern₁  :=  e₁          -- non recursvive
        \ pattern₂  :=  e₂          -- non recursvive
        ...
        \ pattern₅  :=  f ...       -- recursive
        ...

where some clauses are non recursive i.e. their right hand side does not call
``f`` and some clauses are recursive where the right hand side of the clause is
a direct recursive function call of ``f``. The tail calls might be nested within
other pattern match, inspect or branching expressions. This does not change the
situation as long as the recursive call is a tail call.

Definition of a *tail* call: The call of a recursive function within its body is
a tail call if and only if the return value of the recursive call in the body is
the return value of the calling function.

The return value of a tail recursive function does not process any data of the
call stack. The return value is just passed through to the callers.

We assume that all pattern match expressions are in canonical form. In the
chapter :ref:`Pattern Match` it has been shown that the canonical form exists
for all valid pattern match expressions.


A tail recursive function can be compiled to a javascript loop.


.. code-block::

    function f (p1, p2, ..., a1, a2, ...) {
        var state =                     // represents stack
            {a1: a1, a2: a2, ... }

        function next1 ( state ) {      // one update function per rec call
            return {a1: ..., a2: ..., ... }
        }
        function nextr2 ( state ) {
            return {a1: ..., a1: ..., ... }
        }
        ...
        for(;;) {
            switch (a1[0]) {            // might be deeper nested
            case 0:
                return e1               // non recursive call
            ...
            case 5:
                state = next1 ( state )
            }
            ...
        }
    }

It the pattern match matches on more than one pattern, the corresponding
``switch/case`` has to be nested deeper.

We use an object ``state`` to represent the arguments which are passed from any
call to a tail recursive call. For each tail recursive call, there is one update
function which computes the arguments for the recursive call from the original
arguments.

As long as the update functions do not construct closures which might reference
``state``, the above translation scheme is an overkill.

If all update functions do not construct closures we can ommit the state object
and the update functions and update the function arguments directly. I.e.
instead of
::

    state = next1 ( state )

we write
::

    a1 = ...                // use temporaries, if necessary
    a1 = ...



As an example we use the tail recursive function ``foldLeft``.

.. code-block:: alba

    foldLeft {α β: Any} (f: α → β → β): β → List α → β := case
        λ b     []          :=  b
        λ b     (x :: xs)   :=  foldLeft (f x b) xs


Instead of recursively calling ``foldLeft`` we just overwrite the original
arguments with the arguments of the recursive call and do the next iteration in
a loop.  In any pattern clause which does not have a recursive call, the
final result of the function can be returned.


.. code-block::

    function foldLeft (f, b, xs) {
        for (;;) {
            switch (xs[0]) {
            case 0:
                return b
            default:
                b  = f(xs[1], b)        // updates must be done in parallel!
                xs = xs[2]
            }
        }
    }

.. note::

    In the branches representing the recursive calls the updates of the original
    arguments must be done in parallel. I.e. the left hand sides of the
    assignments have to *see* the original values on the right hand side.
    Temporary variables have to be used, if the sequential assignments are not
    semantically equivalent to a parallel assignment.

.. warning::

    This does not work if one of the arguments is a function and the
    corresponding argument is updated with a function closure which can *see*
    the arguments. In that case we have a function closure which *sees* mutable
    objects. This violates the condition, that each recursive call sees only its
    own arguments.

    With function closures use the more complex translation at the start of the
    chapter.



Mutual Tail Recursion
--------------------------------------------------

The translation to a loop works in the case of mutually recursive functions as
well as long as the mutually recursive calls are tail calls.

We generate one javascript function for each mutually recursive function and one
javascript function which does the iteration. The state object is a tagged
object. The tag indicates which of the mutually recursive functions is called.
The remaining proporties of the object are the arguments of the call.

As an example we use the following mutually recursive functions which compute
the evenness or oddness of a natural number.

.. code-block:: alba

    mutual
        even: ℕ → Bool := case
            \ zero      :=  true
            \ (succ n)  :=  odd n

        odd: ℕ → Bool := case
            \ zero      :=  false
            \ (succ n)  :=  even n

In order to keep it simple we use the usual algebraic type in javascript (note
that natural number are normally represented as bignums in order to be
efficient).

The compiler generates the following javascript functions::

    function even (n) { return even_odd ([0, n]) }
    function odd  (n) { return even_odd ([1, n]) }

    function even_odd (a) {
        for(;;){
            switch (a[0]) {             // 'even'
            case 0:
                switch (a[1][0]) {
                case 0:
                    return true
                default:
                    a = [ 1, a[1][1] ]
            default:                    // 'odd'
                switch (a[1][0]) {
                case 0:
                    return fase
                default:
                    a = [ 0, a[1][1] ]
            }
        }
    }



Eliminate Recursion
--------------------------------------------------

.. note::
    DRAFT


.. code-block:: alba

    append {α: Any} (xs ys: List α): List α :=
        app xs identity where
            app: List α → (List α → List α) → List α := case
                λ [] k :=
                    k ys
                λ (x :: xs) k :=
                    app xs (λ r := k (x :: r))

    reverse {α: Any} (xs: List α): List α :=
        rev xs identity where
            rev: List α → (List α → List α) → List α := case
                λ []        k :=    k []
                λ (x :: xs) k :=    rev xs (λ r := k (append r [x]))



.. code-block::

    function identity (x) { return x }

    function append (xs, ys) {
        var k =
            (x) => {return x}
        function nextK (xs, k) {
            return (r) => {return k([1, xs[1], r])}
        }
        while(true){
            switch (xs[0]){
                case 0:
                    return k(ys)
                default:
                    k  = nextK(xs,k)
                    xs = xs[2]
            }
        }
    }

    function reverse (xs) {
        var k = identity
        function nextK (xs, k) {
            return (r) => {return k (append(r, cons (xs[1],nil)))}
        }
        while(true) {
            switch (xs[0]){
                case 0:
                    return k ([0])
                default:
                    k = nextK(xs,k)
                    xs = xs[2]
            }
        }
    }



An example with vectors:

.. code-block:: alba

    section {α β: Any} :=
        zip : ∀ {n}: Vector α n → Vector β n → Vector (α,β) n
        := case
            λ []          []          :=  []
            λ (x :: xs)   (y :: ys)   :=  (x,y) :: zip xs ys

        zipCPS
        : ∀ {n}:
            Vector α n
            → Vector β n
            → (Vector (α,β) n → Vector (α,β) n)
            → Vector (α,β) n
        := case
            λ [] [] k :=
                k []
            λ (x :: xs) (y :: ys) k :=
                zipCPS xs ys (λ r := k ((x,y) :: r))





Browser
============================================================


Node
============================================================
