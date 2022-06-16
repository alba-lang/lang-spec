.. _LLVM:

************************************************************
LLVM
************************************************************

.. warning::

    The content of this chapter is very draft. LLVM has low priority. Highest
    priority has javascript in the browser, second javascript in nodejs. LLVM
    has lowest.



Memory Representation
==================================================

The compiler can either target 32 bit machines or 64 bit machines (today the
most common architecture).

.. code-block:: llvm

    target datalayout = "layout specification"
    target triple = "x86_64-apple-macosx10.7.0"


All data which fit into a machine word are directly represented (expanded). Data
longer than a machine word are allocated on the heap and represented by a
pointer.

The first class types are perhaps the most important. Values of these types are
the only ones which can be produced by instructions.

First class types:

- LLVM has integers of any bit size (``i1``, ``i8``, ... , ``i32``, ``i64``,
  ``i1037``).

- Floating point types ``float``, ``double``

- Pointers ``<type> *``


Aggregate types:

- Array type ``[ 3 x [4 x i32]]``

- Structure type ``{i32, i32, i32}``, ``{float, i32 (i32) *}``


LLVM has bitcasts

.. code-block:: none

    <result> = bitcast <ty> <value> to <ty2>             ; yields ty2


Note: Only first class types, and pointers are casted to pointers. For other
casts there are the ``inttoptr`` and ``ptrtoint`` instructions.


Some Examples
==================================================

.. code-block:: llvm

    define i64 @factorial ( i64 %n ) {
        %count = alloca i64         ;allocate stack space and return pointer
        %result = alloca i64
        store i64 %n , i64 * %count
        store i64 1, i64 * %result
        br label %loop

        loop:
            %t1 = load i64 , i64 * %count
            %t2 = icmp sgt i64 %t1 , 1
            br i1 %t2 , label %body , label %exit

        body:
            %t3 = load i64 , i64 * %result
            %t4 = mul i64 %t1 , %t3
            store i64 %t4 , i64 * %result
            %t5 = sub i64 %t1 , 1
            store i64 %t5 , i64 * %count
            br label %loop

        exit:
            %t6 = load i64 , i64 * %result
            ret i64 %t6
    }






Algebraic Types
==================================================



Algebraic types are represented by a structure with a tag and the constructor
arguments. After allocation, the pointer is cast to a pointer to ``{i8}``. After
inspection of the tag, the pointer can be downcasted to the correct type for the
constructor.
