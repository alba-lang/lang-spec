********************************************************************************
Platforms
********************************************************************************

In order to compile applications to some executable format we need a platform.
Three platforms make sense

- Unix: This is for console applications

- Browser: Elm like browser applications

- Server: Web serverse with ``libuv`` like functions





Unix Console Applications
================================================================================

We need unix like functions to access the filesystem:

- open, create, close, fsnyc

- read, write

- seek, truncate

- stat

- readdir

- env

- alloc, free (buffers)

.. code-block::

    -- unix like erno
    type IO_Error: Any := [ebadf, einval, eisdir, enoent, enomem, eperm, epipe, ... ]

    -- type of an io action
    IO (E A: Any): Any


    -- monadic operations
    return {E A: Any}: A -> IO E A
    (>>=) {E A B: Any}: IO E A -> (A -> IO E B) -> IO E B

    -- types
    File: Any   -- file descriptor
    Buffer: Any -- buffer descriptor

    Handler (E: Any): IO_Error -> E



    -- primitives for file system access
    open {E: Any}: String -> Mode -> Handler E -> IO E File
    alloc {E: Any}: Nat -> (IOError -> E) -> IO E Buffer
    read {E: Any}:  File -> Buffer -> Handler E -> IO E Nat
                            -- number of bytes read
    write {E: Any}: Buffer -> File -> Handler E -> IO E Nat
                            -- number of bytes written




Browser Applications
================================================================================


Server Applications
================================================================================
