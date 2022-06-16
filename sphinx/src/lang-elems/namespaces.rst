.. _Namespaces:

************************************************************
Namespaces
************************************************************


Each :ref:`package <Packages>` has a namespace of the form *author.package*.
Each :ref:`module <Modules>` within a package is has namespace of the form
*author.package.module*. Each :ref:`type <Types>` declared within a module has a
namespace of the form *author.package.module.Type*.



Declaration of Names
============================================================


All declarations within a module belong to the namespace of the module. If a
function is strongly associated with a type, it can be declared within the
namespace of the corresponding type. E.g. ::

    class ℕ := zero; succ (ℕ)

    ℕ.(+): ℕ → ℕ → ℕ := case
        λ n     zero        :=      n
        λ n     (succ m)    :=      succ (n + m)

Here the operation + is declared within the namespace ℕ which is also declared
within some package namespace. Since the natural numbers are builtin, they live
in the module *prelude* of the package *alba.standard*. I.e. the fully qualified
name of addition of natural numbers is *alba.standard.prelude.ℕ.(+)*.

There are some restrictions to putting a function name within a
namespace of a type:

- The type must appear in the signature of the function.

- The type must belong to a module namespace within the same package.

Each declaration of an :ref:`inductive type <Inductive Types>` puts implicitly
all constructors of the type into the namespace of the type. I.e. the fully
qualified names of the constructors for natural numbers are
*alba.standard.prelude.ℕ.zero*  and *alba.standard.prelude.ℕ.succ*.


All declarations within a namespace must be unique.


Usage of Names
============================================================

Names can be used in fully qualified form. But this is very tedious. The
language is quite liberal in using unqualified names. The :ref:`elaborator
<Elaboration>` has in many cases sufficient type information to figure out the
fully qualified name of a symbol.

In case where the type information is not sufficient to find out the fully
qualified name, the source code can be enriched with some path information. It
is not necessary to give the full path to disambiguate symbol. Only a substring
of the path which makes the symbol unique is sufficient. Examples::

    ℕ.(+) 1 2

    ℕ.(3 + 5 * 9)

    -- type annotation which achieves the same disambiguation
    3 + 5 * 9: ℕ
