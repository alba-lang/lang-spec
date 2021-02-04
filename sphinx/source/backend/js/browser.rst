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
