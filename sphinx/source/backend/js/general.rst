************************************************************
General
************************************************************


Primitives
==================================================

Javascript has the following primitives:

- undefined
- null
- boolean
- number
- string

Primitive values are immutable.



Arithmetic
============================================================

Numbers in javascript are 64 bit floating point numbers according to IEEE 754.



Floating Point
============================================================

IEEE 754 floating point values have some peculiarities which has to be corrected
to fit into the alba semantics. In alba

- equality is reflexive, but in IEEE ``! (NaN === NaN)`` and ``! (NaN == NaN)``

- equality is leibniz equality, but in IEEE ``- 0 == 0`` and ``- 0 === 0``, but
  ``1/0 ~> Infinity`` and ``1/(-0) ~> - Infinity``

Therefore we have to implement the equality function on floating point values by
hand and not use the javascript ``==`` or ``===``.

.. code-block:: javascript

    function float_equal (a,b) {
        Object.is(a,b)      /* 'Object.is(a,b)' test, if 'a' and 'b' are the
                                same value. */
    }

IEEE floating point values have no linear order because of NaN. NaN is neither
smaller nor greater than any other floating point value. Javascript returns
false in comparing any number with NaN. Unfortunately ``NaN <= NaN`` returns
false as well, which violates reflexivity of equality.

Without NaN, the floating point values have a linear order. However with -0 and
+0 the javascript implementation returns false on the question ``-0 < 0`` and
true on ``-0 <= 0``. This violates antisymmetry of a partial order, because ``-0
<= 0`` and ``0 <= -0`` implies ``-0 = 0``.

A reasonable correction of the IEEE semantics:

.. code-block:: javascript

    function float_less_equal (a,b) {
        return (
            a <= b          // returns false if a or b is NaN
            &&
            ! (Object.is(a,0) && Object.is(b, -0))
            // 0 <= -0 shall return false
        )
    }




Integer 32 Bit Arithmetic
============================================================

Javascript treats numbers as 64 bit floating point numbers by default. 64 bit
floating point numbers can safely represent integer numbers *n* only if
:math:`- 2^{53} < n < 2^{53}`.

.. code-block:: javascript

    Number.MAX_SAFE_INTEGER == Math.pow(2,31) - 1  // 9_007_199_254_740_991
    Number.MIN_SAFE_INTEGER == - Number.MAX_SAFE_INTEGER

Overflow is not handled correctly in the sense of modulo arithmetic. Adding 1 to
the maximal safe integer returns the same value.

A number *x* can be converted to a 32 bit integer value by ``x|0``. In order to
get 32 bit modulo arithmetic with addition and substraction it is necessary to
add the conversion ``|0`` after each addition and substraction.

Standard multiplication can cause an overflow into floating point
numbers because multiplying two 32 bit values can result in values below
:math:`- 2^{53}` or above :math:`2^{53}`. In order to do integer modulo
multiplication correctly in javascript there is the function ``Math.imul(a,b)``.

Division cannot overflow, but produces a fractional number represented as a
floating point number. Converting back to modulo arithmetic is done by ``(a / b)
| 0``.  The same applies to the modulo operation ``(a % b) | 0``.

Mathematically there is no difference between signed and unsigned modulo
arithmetic. Therefore it is possible to represent unsigned 32 bit values as
signed 32 bit values. What is different is the order relation. We can map the
unsigned order relation to the signed order relation by adding the smallest
signed number ``0x8000_0000`` (which is :math:`- 2^{31}`) to both operands and
then do the signed comparison. With that *0* is mapped to :math:`- 2^{31}` i.e.
the smallest signed 32 bit number and *-1*  is mapped to :math:`2^{31} - 1` i.e.
the biggest signed 32 bit number.

.. code-block:: javascript

    // unsigned comparison a <= b
    ((a + 0x80000000)|0) <= ((b + 0x80000000)|0)







Big Numbers (BigInt)
============================================================


Javascript has ``BigInt``. Objects of that type implement arbitrarily sized
whole numbers. BigInt literals are just numbers with the suffix *n* (e.g.
``100n, 0n, -1n``.

All modern browsers and nodejs support BigInts.

BigInts can be used directly to implement the type ``Integer``. They can be used
to implement ``Natural`` as well with the exception of substraction. When
substraction of two natural numbers results in a negative number, the result has
to be replaced by zero.



Names
==================================================

The names used in the source language might interfere with the javascript
keywords and operators. Since javascript does not allow to define functions with
an operator name, operators of the source language have to be represented by
valid javascript identifiers.

Javascript allows identifiers to begin with ``_`` and to contain ``$``. Dots
``.`` are not allowed.

The following encodings are used:

- ``add`` ~>  ``_add``

- ``+`` ~> ``o_2B`` where ``2B`` is the hexadecimal encoding of the ascii
  character ``+``.

- Nameless variables (only local variables): The backend can invent numbers and
  encode them as ``i_24``. Note that the numbers must be de Bruijn levels and
  not indices in order to be unique.


Modules, Packages, ...
============================================================

A module can be compiled into a javascript module (extension ``*.mjs``). E.g.

.. code-block:: javascript

    // module alba.core.list
    function make () {
        const List = {
            nil: ['nil'],
            cons: (hd, tl) => ['cons', hd, tl]
        }

        function singleton (e){ return List.cons(e, List.nil)}

        function append (xs, ys) {
            switch (xs[0]) {
                case 'nil':
                    return ys
                case 'cons':
                    return List.cons(xs[1], append(xs[2], ys))
            }
        }

        function reverse (lst) {
            switch (lst[0]) {
                case 'nil':
                    return lst
                case 'cons':
                    return append(reverse(lst[2]), singleton(lst[1]))
            }
        }

        return {List: List, singleton: singleton, append: append, reverse: reverse}
    }

    export const list = make ()


A using module imports the module

.. code-block:: javascript

    import {alba$core$list} from 'alba.core.list.mjs'


The compiler has to generate an object containing all used functions/constants
used within the program. Each namespace gets its own object.

For the namespace ``prelude`` we get the object:

.. code-block:: javascript

    function make_prelude () {
        function make_Integer () {
            let _add = (_a, _b) => _a + _b
            let _minus = (_a, _b) => _a + _b
            let _le = (_a, _b) => _a <= _b
            return {_add: _add, _minus: _minus, _le: _le}
        }

        function make_Int (_Integer) {
            let add = (_a, _b) => (_a + _b)|0;
            let minus = (_a, _b) => (_a - _b)|0;
            let le = (_a, _b) => _a <= _b
            return {_add: _add, _minus: _minus, _le: _le}
        }

        function make_UInt () {
            let add = (_a, _b) => (_a + _b)|0;
            let minus = (_a, _b) => (_a - _b)|0;
            let le = (_a, _b) => _add(_a,0x8000_0000) <= _add(_b,0x8000_0000);
            return {_add: _add, _minus: _minus, _le: _le}
        }

        let _Integer = make_Integer ()
        let _Int = make_Int(_Integer)
        let _UInt = make_UInt ()

        return {_Integer: _Integer, _Int: _Int, _UInt: _UInt}
    }

A namespace using another namespace get in its *make* function a reference to
the used namespace.






Strings and Characters
==================================================

The elements of javascript strings are 16 bit unsigned integer values. Each
element is treated as a UTF-16 code unit value.


There is no character object in javascript. Characters can be represented by one
element strings (or two elements strings in case of surrogat pairs).


Two subsequent elements ``c₁`` and ``c₂`` can be a surrogate pair. This is the
case if ``c₁`` is in the range ``0xd800 - 0xdbff`` and ``c₂`` is in the range
``0xdc00 - 0xdfff``. In that case both represent the unicode code point ``(c₁ -
0xd800) * 0x400 + (c₂ - 0xdc00) + 0x10000``.

All elements which are not part of a surrogate pair are interpreted as the
corresponding unicode code point.




Currying (Partial Application)
==================================================

In javascript there is no partial application. If a function is called with
missing arguments, then the arguments are initialized as ``null``.

.. code-block::

    append {A: Any}: List A -> List A -> List A := case
        \ [] ys := ys
        \ (x :: xs) ys := x :: append xs ys

    -- partial application
    append ['a', 'b', 'c']: List Char -> List Char


In javascript::

    ((ys) => append ... ys)


Algebraic Types
==================================================

Objects of algebraic types can be implemeneted by arrays. For each constructor
we use an :math:`n+1`\ ary array where :math:`n` is the number of runtime
arguments the constructor takes. The first element of the array is tag i.e. a
number :math:`i` which says that the :math:`i`\ th constructor has been used to
construct the object. The other array elements are arguments to construct the
object.

E.g. to encode a list we use::

    [0]                         // empty list

    [1, 'a', [1, 'b', [0]]]     // the list ["a", "b"]




.. code-block:: javascript

    // encoding as an object (better readable)
    var List = {nil: [0], cons: (hd, tl) => [1, hd, tl]}

    // encoding as an array (faster access)
    val List = [ [0], (hd, tl) => [1, hd, tl] ]



Pattern Match
==================================================

The most straightforward way is to use a ``switch/case`` expression.

Example: List append and reverse

.. code-block:: alba

    append {α: Any}: List α → List α → List α :=
        λ []            ys  := b
        λ (x :: xs)     ys  := x :: (append xs ys)

    reverse {α: Any}: List α → List α :=
        λ []        :=  []
        λ (x :: xs) :=  append (reverse xs) [x]

.. code-block:: javascript

    function append (xs, ys) {
        switch(xs[0]) {
        case 'nil':
            return ys
        default:
            return [1, xs[1], append (xs[2], ys)]
        }
    }

    function reverse (xs) {
        switch (xs[0]) {
        case 'nil':
            return xs
        default:
            return append (reverse (xs[2]), [1, xs[1], [0]])
        }
    }







Tail Recursion
==================================================

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


.. code-block:: javascript

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
            case 'nil':
                return e1               // non recursive call
            ...
            case 5:
                state = next1 ( state )
            }
            ...
        }
    }

If the pattern match matches on more than one pattern, the corresponding
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

.. code-block:: javascript

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


.. code-block:: javascript

    function foldLeft (f, b, xs) {
        for (;;) {
            switch (xs[0]) {
            case 'nil':
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
==================================================

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

The compiler generates the following javascript functions

.. code-block:: javascript

    function even (n) { return even_odd ([0, n]) }
    function odd  (n) { return even_odd ([1, n]) }

    function even_odd (a) {
        for(;;){
            switch (a[0]) {             // 'even'
            case 'nil':
                switch (a[1][0]) {
                case 'nil':
                    return true
                default:
                    a = [ 1, a[1][1] ]
            default:                    // 'odd'
                switch (a[1][0]) {
                case 'nil':
                    return fase
                default:
                    a = [ 0, a[1][1] ]
            }
        }
    }



Eliminate Recursion
==================================================

Stack size is limited in javascript, heapsize is limited just by the available
memory in the javascript engine.

Recursion can be eliminated completely by shifting memory from the stack to the
heap. The cost of the elimination of recursion is a bounce object and a function
closure per recursive call.

It is possible to eliminate recursion by using *trampolines*. The key of
trampolines is the bounce object.

.. code-block:: alba

    class Bounce (A: Any) :=
        done: A -> Bounce
        more: (Unit -> Bounce) -> Bounce

A bounce object contains either a value or a function which computes the next
bounce object. We can iterate over a series of bounce objects.

.. code-block:: alba

    iter {A: Any}: Bounce A -> A := case
        \ (done x)  :=  x
        \ (more f)  :=  iter (f ())

Evidently ``iter`` is tail recursive and can be implemented by a javascript
loop.

.. code-block:: javascript


    function iter (b) {
        for(;;) {
            switch (b[0]){
            case 'nil':
                return b[1]         // return content
            default:
                b[1]()              // compute next bounce
            }
        }
    }


A recursive function where the recursive calls are not tail calls has the form
(without loss of generality we consider a function with one argument only and
two recursive calls).

.. code-block:: alba

    f: A -> R := case
        \ p₁    := e₁     -- non recursive case
        ...
        \ p₅    := r₅ x y where
                    x := f a₁
                    y := f a₂
        ...

``r₅`` is some simple function using the return values of the recursive calls as
arguments. ``r₅ x y`` represents the right hand side of the clause with
recursive calls which are not tail calls.

We convert the function ``f`` into the two functions ``fCPS`` and ``f`` which
are equivalent to the original function. Instead of feeding ``fCPS`` only with
the argument of ``f`` we use the argument of ``f`` and a continuation ``k``
which uses the result of ``f`` and computes the remaining bounce object.

.. code-block:: alba

    fCPS (a: A) (k: R -> Bounce R): Bounce R :=
        more (next a k)
        where
            next: A -> (R -> Bounce R) -> Unit -> Bounce R
            := case
                \ p₁ k _ := k e₁
                ...
                \ p₅ k _ :=
                    fCPS
                        a₁
                        (\ x :=
                            fCPS
                                a₂
                                (\ y := r₅ x y))


The function ``fCPS`` constructs one bounce object and two function closures per
call. The function ``f`` just uses ``fCPS`` and ``iter`` to compute the final
result via iteration.


.. code-block:: alba

    f (a: A): R :=
        iter (fCPS a done)


The stack size does not grow during the iteration. The translation of the
function ``fCPS`` to a javascript function is straightforward.


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



.. code-block:: javascript

    function identity (x) { return x }

    function append (xs, ys) {
        var k =
            (x) => {return x}
        function nextK (xs, k) {
            return (r) => {return k([1, xs[1], r])}
        }
        while(true){
            switch (xs[0]){
                case 'nil':
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
                case 'nil':
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




Javascript Values
============================================================

The application has to be able to decode and encode javascript objects. I.e. in
the alba application there is an builtin type ``JSObject`` and there are builtin functions to encode and decode javascript objects.

Decoder api ::

    -- General
    Decoder: Any → Any
    decode {A}: JSValue → Decoder A → Result String A
    return {A}: A → Decoder A
    (>>=) {A B}: Decoder A → (A → Decoder B) → Decoder B

    -- Primitives
    string: Decoder String
    bool:   Decoder Bool
    int:    Decoder Int
    float:  Decoder Float
    list {A}:     Decoder (List A)
    field {A}:    String → Decoder A → Decoder A
    nullable {A}: Decoder A → Decoder (Maybe A)
