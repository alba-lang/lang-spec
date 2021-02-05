************************************************************
Browser
************************************************************


Window
============================================================

A browser window is represented by a window object. The window object is an
event target which receives events like ``load``, ``resize``, ``popstate``.

The methods ``setTimeout`` and ``setInterval`` are window methods.

The most important properties are ``document``, ``history`` and ``location``.


Many objects in the browser inherit from ``EventTarget``. An event target has
the methods ``addEventListener``, ``removeEventListener`` and ``dispatchEvent``.



Document
============================================================

A document represents the web page loaded into the browser. A documents consists
of elements, text nodes and nodes.

.. code-block:: none

    Hierarchy:

        Document                        Text node

        Element                         Character data

                        Node

                        Event Target


A document is the root node of the document tree. Each document has a ``body``
property. The body is the body node, a frameset or null.

A document has methods to create text nodes and elements.

.. code-block:: javascript

    document.createTextNode('Hello, World!')
    document.createElement('div')



Nodes have methods to manipulate the document tree.

.. code-block:: javascript

    node.insertBefore(new_child, child)
    node.appendChild(child)     /* if 'child' is a document fragment, all
                                   children of the fragment are moved into
                                   'node' */
    node.removeChild(child)     // exception, if 'child' is not a child.
    node.replaceChild(new_child, child)
    node.firstChild()           // 'null' if there are no children
    node.parentNode()           // 'null' if there is no parent node

    // ATTENTION: documents and document fragments can never have parents.
    // Question: What happens if I insert the document into a node?


Elements of the document can have attributes. An attribute has a name and a
value. Both are strings.

.. code-block:: javascript

        element.setAttribute(name, value)
        element.getAttribute(name)          // null or "" if not present

Like all objects in javascript, elements can have arbitrary properties. A
``setAttribute`` sets the property of the same name. Updating a property does
**not** update the attribute.



Location
============================================================

General form of a uri:

.. code-block:: none

    uri:        scheme:[//authority]path[?query][#fragment]

    authority:  [userinfo@]host[:port]

    query:      key1=value1&key2=value2&...

    Example:

        http://www.example.com:8080/bla/blue?name=bla&color=blue#chapter1


The location object has properties and methods.

.. code-block:: javascript

    location.href
    location.hostname
    location.port
    location.pathname
    location.protocol
    location.assign(url)    // loads new web page




History
============================================================

.. code-block:: javascript

    history.back()
    history.forward()
    history.go(n)

    history.pushState(state, title, url)        // no page load
    history.replaceState(state, title, url)     // no page load




Alba Browser Application
============================================================

A compiled alba browser application is a javascript module with two exported
functions:

- init

    - element: The element below which the view shall be displayed
    - data: javascript object which the application can decode to get its init
      data
    - callback: To receive messages from the application
    - history access flag: Application is allowed to access the history and
      subscribe to popstate

- postMessage: A method to send messages to the application

The init method can throw an exception

- No element given or the element does not belong to the document.

- The application type is *document* or *application* and the element is not
  body. Reason: Only *sandbox*  and *element* can work below the body.
  *document* and *application* must takeover the body, i.e. must have exclusive
  rights on the page.

On success the init method does the following steps:

- Calls the internal init function with the data object to get the initial state
  and the initial commands.

  If the application type is *application* then call the internal init function
  with the url and an opaque navigation key. This is the method to allow the
  application to use navigation functions.

- Registers a requestAnimationFrame to display views of the state. The state
  object has a *modified* flag which is initially *true* and set to true on each
  update. The animation callback resets the *modified* flag after displaying the
  state.

The generated javascript module looks like

.. code-block:: javascript

    const application = {
        type: 'application'
        , init: function (data, key, url) { ... }
        , view: function (model) { ... }
        , update: function (msg, model) { ... }
        , onUrlRequest: function (urlreq) { ... }
    }

    var state                   // initialized by 'init'

    var element

    var callback = null         // initialized by 'init' or null

    function decode_message (m) { ... }

    function find_element (e) { ... }

    function do_command (cmd) { ... }

    export function init (conf) { ... }

    export function postMessage (m) {
        var m = decode_message(m)
        if (m === undefined) {
            return false
        } else {
            var res = application.update(m, state)
            state = res[0]
            cmd = res[1]
            do_command (cmd)
        }
    }
