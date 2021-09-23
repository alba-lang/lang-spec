******************************************************
Resources
******************************************************


STATUS: VERY DRAFT !!!!


Basics
==================================================

Files, buffers etc. are considered as resources. Resources must be acquired,
used and finally released. The acquisition and the release must happen in the
same stackframe. ::

    class File:   once Any
               -- ^ the keyword 'once' indicates a resource
    class Buffer: once Any

    Buffer.allocate: UInt -> IO Buffer
    Buffer.release:  Buffer -> IO Unit

    File.open:  String -> IO File
    File.close: File -> IO Unit

A resource has only functions to acquire them and functions to release them.
The usage happens only through references. A variable of type ``ref Buffer`` is
a reference to a buffer object. ::

    Buffer.clear: ref Buffer -> IO Unit
              --  ^ the keyword 'ref' indicates a reference
    Buffer.append: String -> ref Buffer -> IO Unit

    File.write: ref Buffer -> ref File -> IO Unit


Resources are represent objects of the external world and are therefore executed
only in the ``IO`` monad. I.e. they can be created only by functions with the
signature::

    A₁ → A₂ → ... → IO Resource

They can be released only by functions with the signature::

    A₁ → A₂ → ... → Resource → ... → IO R

They can be used only by functions with the signature::

    A₁ → ... →  ref Resource → ... → IO R

**Problem:**
    The whole thing might not work in the type system, because we have ::

        IO: Any -> Any

    i.e. ``IO`` cannot handle resources. And if it could, it would have to
    handle resources and non resources at the same time.

**Brute force solution:**
    Don't make special types for resources. Equip all functions handling
    resources with error codes (e.g. file not open, buffer not allocated) and
    free all allocated resources at the end of the program.


* * * * *

The basic idea has been developed in the Rust programming language.

Three kinds of types:

Normal:
    Objects of normal types can be used arbitrarily often and can be shared.
    The livetime of objects of normal types are potentially infinite. In order
    to clean up objects which are no longer in use, a reference count is needed.

    Passing a normal object as an argument to a function increases the reference
    count. The reference count of a normal object created within a function is
    decreased at the end of the function.

    As soon as the reference count reaches zero, the memory of the object can be
    deallocated.

Resources:
    Objects of a resource type are always owned by exactly one
    variable/reference. They can be used only once and have to be used exactly
    once. After usage they are no longer usable.

Shared references:
    A shared reference to a resource can be shared arbitrarily. However the
    shared reference to a resource cannot live longer than the resource.

    A shared reference to a normal object does not increase the reference count
    of the object. However the shared reference must not live longer than the
    normal object to which it refers.



Linear Types
============


Some kind of linear types can be useful to implement interactions with the io
system or the runtime system.

A file descriptor and a buffer descriptor can be considered as a resource. To
open and close a file and to allocate and release a buffer we can have the
interface

.. code-block:: alba

    File.open (name: String) (mode: Mode): IO (once FileHandle)
    File.close (fd: once FileHandle): IO Unit


    Buffer.allocate (length: Uint): IO (once Buffer)
    Buffer.release (bd: once Buffer): IO Unit

The annotation ``once`` means that the type ``FileHandle`` is a resource
which has to be used exactly once. With these annotations, the compiler can check
that each opening of a file is followed by a closing of the file.

The functions to read and write a file should not be considered as *using* the
file descriptor. We can similar to rust introduce some reference type.

.. code-block:: alba

    File.write (bd: ref BufferHandle) (fd: ref FileHandle): IO Unit
    File.read  (bd: ref BufferHandle) (fd: ref FileHandle): IO Unit


A programm which opens a file reads to and then closes it has the form (error
handling ommitted)

.. code-block:: alba

    do
        fd := open "my-file" read
        bd := allocate 1024
        ...                     -- fill the buffer
        write (ref bd) (ref bd) -- 'ref' converts from 'once' to 'ref'
        ...                     -- fill the buffer again
        write (ref bd) (ref fd)
        release bd
        close fd


Language Elements
=================

.. only:: draft

  My personal thoughts


Type attributes:

``once T``
    The type ``once T`` considered as a linear type, i.e. it has to be used
    exactly once. An object of type ``once T`` can only be passed as an actual
    argument to functions if the type of the formal argument is also ``once
    T`` or if the formal argument is declared as ``once name: T``.

    ``once T`` does not conform to ``T``, because the receiving function can
    use the object arbitrarily often and does not guarantee the *once* usage
    constraint.

    .. note::
        Open question: Does ``T`` conform to ``once T``?

        .. only:: draft

            It might be possible. But it is more conservative to not allow
            objects of type ``T`` to given as arguments to functions expecting a
            ``once T``. At first sight there are no problems, because the
            function treats the object like a resource.

            However problems might arise, if the function uses a ``T`` which it
            thinks is a ``once T`` creates other once objects with it.




``ghost T``
    An object of this type can only be used in propositional functions. It is
    not available at runtime i.e. the compiler erases it at code generation.

    ``T`` conforms to ``ghost T``. Any object of type ``T`` can be passed to a
    function expecting a ``ghost T``.

    ``<ghost> T`` does not conform to ``T``.  Reason: The function might use the
    object to make decisions or construct other runtime objects from it.


``ref T``
    A reference to the type ``T``. A reference cannot live longer than the
    original object.


``&name``
    The name ``name`` must be bound to a resource object. ``name`` is a
    reference to the resource. Its livetime is limited to the livetime of the
    resource.

    We have the typing judgement ``ref &name: ref T`` only
    if ``name: once T`` is valid.



Name attributes:

``once name``
    When a formal argument of a function has the declaration ``(once name:
    T)`` it is guaranteed that the function uses its argument only once. I.e.
    the function can handle objects of type ``T`` and objects of type ``once
    T``.


Being a *once* object is infectuous to the parent objects. A list of linear
objects is a linear object as well. If a name is bound to a linear list, then
the name has to be used in a pattern match. The pattern match reveals the linear
head and tail which have to be consumed as well. A pattern match on the empty
list consumes the empty list and there remain no other linear objects which have
to be consumed.
