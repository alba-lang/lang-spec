********************************************************************************
IO
********************************************************************************


Console Programs
================================================================================

Two types of console applications:

Script:
    Just read and write files, directories, make http requests etc. I.e. a
    like a compiler. No communication.

Actor:
    Program which can communicate i.e. send and receive messages, serve http
    requests, reacts to timer interrupts etc.



IO Interface
================================================================================


Progress:

.. code::

    type Progress := [yes, no]

    (or): Progress -> Progress -> Progress := case
        \ yes _ := yes
        \ no  b := b

    (and): Progress -> Progress -> Progress := case
        \ yes b := b
        \ no  _ := no

File descriptor:

.. code::

    type Mode     := [read, write]

    type FD: Mode -> List Mode -> Any :=
        start {m} {ms}: FD m (m :: ms)
        next {m0} {m1} {ms}: FD m0 ms -> FD m0 (m1 :: ms)


IO Monad:

.. code::

    IO: Any -> List Mode -> List Mode -> Progress -> Any
    IOError: Any

    section {A B: Any} {i j: Progress} {l0 l1 l2: List Mode}
    :=
        return: A -> IO A l l no
        (>>=): IO A l0 l1 i -> (A -> IO B l1 l2 j) -> IO B l2 (i or j)
        catch: IO A l0 l1 i -> (IOError -> IO A l0 l1 j) -> IO A l0 l1 (i and j)
            -- usually 'l0 = l1' in catch!


    section {A B: Any} {i j: Progress} {m: Mode} {ms: List Mode}
    :=
        open (_: String) (m: Mode): IO (FD m (m :: ms)) ms (m :: ms) no
        close: FD m ms -> IO Unit ms (ms - m) no
        getc: FD read  ms -> IO Char ms ms yes
        putc: FD write ms -> IO Unit ms ms on
        eof: A -> IO A ms ms i -> IO A ms ms no
        stdin:  IO (FD read  ms) ms ms no
        stdout: IO (FD write ms) ms ms no
        stderr: IO (FD write ms) ms ms no


Example: File copy

.. code::

    copy {l} (ic: FD read l) (oc: FD write l): IO Unit l l no :=
        do
            c := getc ic
            _ := putc c oc
        :=
            copy
        |> eof ()


Sinks
================================================================================


.. code::

    abstract type Sink (A S: Any) :=
        Needs_more: S -> Prop
        needs_more: Decider Needs_more
        put s: Needs_more s -> A -> S
        put_end: S -> S

    readToSink (fd: FD read l) {_: Sink Char S}: S -> IO S l l


An IO sink of buffers:

.. code::

    abstract type IOSink (S: Any) :=
        Needs_more: S -> Prop
        needs_more: Decider Needs_more
        put s: Needs_more s -> IOBuffer -> IO S l l
        put_end: S -> IO S l l

    readToIOSink (fd: FD read l) {_: IOSink S}: S -> IO S l l

Buffers
================================================================================

Buffers are suited for low leve io operations.

Buffers are arrays of bytes. Read operations can read buffers i.e. allocate a
buffer and read into it. Write operations can write bufferes to files.

.. code::

    Buffer: Any

Within the language we need operations to read the contents of a buffer and to
fill a buffer.

A reader of a buffer is practically a parser which consumes the bytes in the
buffer.

.. code::

    Reader: Any -> Progress -> Any


    section {A B: Any} {i j: Progress}
        -- Builtin functions
    :=
        return: A -> Reader A no

        (>>=) (m: Reader A i) (f: A -> Reader B j): Reader B (i or j)

        getc: Reader Byte yes

        (</>) (p: Reader A i) (q: Reader A j): Reader A (i and j)

        nbytes: Reader Nat no

        nlines: Reader Nat no

        scan: Reader A i -> Buffer -> Maybe A



Appendix
================================================================================



Length Indexed Buffers
-------------------------

.. code::

    type Fin: Natural -> Any :=
        start {n}: Fin (succ n)
        next  {n}:  Fin n -> Fin (succ n)

    finToNat {n}: Fin n -> Natural := case
        \ start    := zero
        \ (next f) := succ (finToNat f)

    weaken {n}: Fin n -> Fin (succ n) := case
        \ start    := start
        \ (next f) := weaken f


    strengthen {n}: all (i: Fin n): Fin (succ (finToNat i)) := case
        \ start     := start
        \ next j    := next (strengthen j)



The objects of type ``Fin n`` can be internally represented by natural numbers
strictly below ``n``. In that case ``finToNat``, ``weaken`` and ``strengthen``
are the identitiy function. I.e. these functions are available at compile time
with the inductive type. During runtime these functions do nothing.
