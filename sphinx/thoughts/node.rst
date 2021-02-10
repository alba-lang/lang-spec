************************************************************
Node
************************************************************

Modules
============================================================

The *node* way of handling modules:

.. code-block:: javascript

    /* module file 'm.js' */

    function f (x,y) {return x + y}

    exports.add = f

    // using 'm.js'
    const m = require('./m')

    const sum = m.add(3,4)


However *nodejs*  supports ecma script modules as well.



Streams
============================================================


.. code-block:: none

    Readable Streams                    Writable Streams
    Events:                             Events:
        - data                              - drain
        - end                               - finish
        - error                             - error
        - close                             - close
        - readable                          - pipe/unpipe

    Functions:                          Functions:
        - pipe/unpipe                       - write
        - read/unshift/resume               - end
        - pause/isPaused                    - cork/uncork
        - setEncoding                       - setDefaultEncoding


``write`` writes the data to the underlying resource of buffers them. It returns
false, if it wishes that the write would pause writing until the *drain* event
is emmitted. If the writer ignores the return value, the streams continues
buffering. If the underlying resource is slower than the writer, then large
amounts of data might be buffered.

The writable stream signals with the *drain* event, that more data can be
written to it.

The write function accepts a callback which is called when all data have been
processed by the underlying resource.







Alba Stream API
============================================================

Writable stream:

::

    record IOR (A: Any) := io: IO (Result Error A)

    write: Buffer -> Writable -> IOR Bool
        -- Write a buffer to the writable stream. Get an error or a bool
        -- indicating, if more writes are possible or better wait for drain.

    writeEnd: Buffer -> (Unit -> IOR A) -> Writeable -> IOR A
        -- Write a buffer as the last input to the stream. Wait for the finish
        -- event, then call the action.

    drain {A}: (Unit -> IOR A) -> Writable -> IOR A
        -- Wait for the drain event. Then execute the action.


Readable stream:

::

    read: Readable -> IOR (Maybe Buffer)
        -- Try to read bytes into a buffer and return the buffer.
        -- Return 'nothing' if the readable stream has ended.
        -- Closing a resource (file descriptor, connection) before ending the
        -- stream is considered as a error.



Result within the io monad
============================================================

The result monad::

    class Result (E A: Any) :=
        ok:    A -> Result
        error: E -> Result

    Result.return {E A}: A -> Result E A
        := ok

    Result.(>>=) {E A}: Result E A -> (f: A -> Result E B) -> Result E B
    := case
        \ (ok a)    f   :=  f a
        \ (error e) _   :=  error e

::

    record IOR (A: Any) :=          -- zero cost abstraction
        io: IO (Result Error A)     -- record with one field

    IOR.return {A} (a: A): IOR A :=
        record [ IO.return <| ok a ]

    IOR.error {A} (e: Error): IOR A :=
        record [ IO.return <| error e ]

    IOR.(>>=) {A B} (m: IOR A) (f: A -> IOR B): IOR B :=
        record [
            do
                r := io m
                inspect r case
                    \ (ok a) :=
                        io <| f a
                    \ (error e) :=
                        return <| error e
        ]

    IOR.catch {A} (m: IOR A) (f: Error -> IOR A): IOR A :=
        record [ catch (io m) (io << f) ]





Simple Http Server
============================================================

.. code-block:: javascript

    const http = require('http');

    function requestListener (req, res) {
      res.writeHead(200);
      res.end('Hello, World!\n');
    }

    const server = http.createServer(requestListener);


    server.listen(8080);

    function end_listen (msg) {
        console.log(msg);
        server.unref()
    }

    setTimeout (end_listen, 5000, "end listen");


.. code-block:: alba

    use
        alba-lang.standard.http

    main: IO Unit :=
        do
            server := createServer
                (\ req res := do
                    writeHead 200 res
                    writeEnd "Hello, World!\n")
            listen 8080 "localhost" server
            setTimeout
                5000
                (\ _ := stopListen server)
