.. _Packages:

************************************************************
Packages
************************************************************

A package is a collection of :ref:`modules <Modules>`. Any package is part of a
:ref:`project <Projects>`.

If a package is the only package within a project, it can be located in the same
directory as the project. If the project has more than one package, then each
package must be located in a subdirectory of the project directory.

A package is one of:

- browser application
- console application
- library

A package directory has a configuration file named ``alba-package.yml``. The
configuration file contains at least the following data:

.. code-block:: yaml

    name: <author>.<name>   # package names have two components

    use:                    # the list of the used packages
        - pkg₁
        - pkg₂
        ...

    source: <source directory>  # if absent '.' is assumed


Web Application:
    Additional configuration data for a web application:

    .. code-block:: yaml

        web-application:
            main:   <main module>       # module with the function 'main'


Console Application:
    .. code-block:: yaml

        console-application:
            main:   <main module>       # module with the function 'main'

Library:
    .. code-block:: yaml

        library:
            export:                     # exported modules
                - <module₁>
                - <module₂>
                - ...
