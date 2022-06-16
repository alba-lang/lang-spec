.. _Projects:

************************************************************
Projects
************************************************************


A project is a collection of :ref:`packages <Packages>`. A project is located in
a directory with the following structure::

    alba-project.yml                -- configuration file
    alba-build/                     -- build directory

In many cases a project contains only one package. Only complex projects contain
more than one package.

The command ::

    alba compile

issued anywhere within a project compiles all packages which need
(re-)compilation.


An alba project cannot be part of another alba project. It is initialized with
the command ::

    alba init project

If the current directory is not yet an alba project, does not contain an alba
project and is not part of an alba project, then the compiler creates the file
``alba-project.yml`` and the directory ``alba-build``.If the current directory is already an alba project, then the build directory is
set to an initial state.


The file ``alba-project.yml`` is an empty file just marking the top directory of
the project. In later versions the file might contain configuration data of the
project.
