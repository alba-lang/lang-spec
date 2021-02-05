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
