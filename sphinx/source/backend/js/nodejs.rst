.. _Nodejs:

************************************************************
Nodejs
************************************************************


Nodejs is the main target to compile console applications.

.. note::

    The following is draft material. It needs more details to be implemented.


Error
============================================================

Nodejs has 4 categories of errors

- Standard javascript errors like ``EvalError``, ``SyntaxError``, etc. These
  errors shall not occur in compiled javascript code.

- System errors triggered by the underlying operating systems like open a file
  that does not exist.

- User specified errors triggered by the application code.

- Assertion errors.

There are 3 mechanism to raise an error:

- Throw an exception. Error handling via ``try {...} catch (err) {...}``.

- Error first in callbacks ``(err, ...) => { if (err) {...} ...}``. A non null
  error object indicates an error.

- Event emitters emit error events ``connection.on('error', (err) => {...})``.

A system error has the following mandatory and optional properties:

- errno: negative numbers according to `libuv <https://docs.libuv.org/en/v1.x/errors.html>`_.

- code: The string error code
  (see `common system errors
  <https://nodejs.org/api/errors.html>`_)

- syscall: The name of the system call which failed e.g. ``open``

- message: A system-provided human-readable description of the error

- (opt) path: The file path when reporting a file system error

- (opt) dest: The file path destination when reporting a file system error

- (opt) (port, address, ...)




Nodejs has an error object with certain fields. The most important ones are
*syscall*, *code* and *message*. It might be best to define a record in alba
which has these three fields ::

    record Error :=
        syscall: String
        code:    String
        message: String




IO Monad
============================================================

Actions are done within some kind of IO monad. There is some builtin type
``IO``::

    IO: Any -> Any

    IO.return {A}: A -> IO A

    IO.(>>=) {A B}: IO A -> (A -> IO B) -> IO B

Many actions have the possibility to fail. To describe failures the builtin
``Result`` type is used. ::

    class Result {E A: Any} :=
        ok:     A -> Result
        error:  E -> Result

    Result.(>>=) {E A}: Result E A -> (A -> Result E B) -> Result E B
    := case
        \ (ok a)    f   :=  f a
        \ (error e) _   :=  error e

    Result.catch {E A}: Result E A -> (E -> Result E A) -> Result E A
    :=
        \ (ok a)    _   :=  ok a
        \ (error e) f   :=  f e


Using ``IO`` and ``Result`` we create the type ``IOE`` which is an io action
which can fail. ::

    record IOE (A: Any) :=
        io: IO (Result Error A)

    IOE.ok {A} (a: A): IOE A :=
        record [ ok a |> return ]

    IOE.error {A} (e: Error): IOE A :=
        record [ error e |> return ]

    IOE.(>>=) {A B} (m: IOE A) (f: A -> IOE B): IOE B :=
        record [
            do
                r := io m
                inspect r case
                    \ (ok a) :=
                        io <| f a
                    \ (error e) :=
                        return <| error e
        ]

    IOE.catch {A} (m: IOE A) (f: Error -> IOE A): IOE A :=
        record [ catch (io m) (f >> io) ]




Buffer
============================================================

Buffers are needed to do input/output. Buffers have a capacity and a size.

::

    Buffer: Any

    allocate:   UInt   -> IOE Buffer        -- no more memory error
    free:       Buffer -> IOE Unit          -- already freed error

    toString:   Buffer -> IOE String        -- already freed error
    fromString: String -> IOE Buffer        -- no more memory error


File System
============================================================



::
    File: Any

    stdin:  File
    stdout: File
    stderr: File

    open: String -> Mode -> IOE File
    close: File -> IOE Unit

    read:  File -> Buffer -> IOE Bool       -- ok or end of file reached
    write: File -> Buffer -> IOE Unit
