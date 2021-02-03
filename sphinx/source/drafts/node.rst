************************************************************
Node
************************************************************


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


::

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
