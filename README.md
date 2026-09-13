# odin-pocketpy

Odin bindings to [pocketpy](https://github.com/pocketpy/pocketpy), a minimalist python interpreter designed to be embedded in a larger application.

See main.odin for a brief overview of features.

The API is mostly the same as in C, with the exception of the C preprocessor macros which were used in the original, the most important of which I have ported to Odin in macros.odin.

Additionally, for extremely simple structs (all numeric types, standard layout), there is a simple `bindstruct` procedure which can write `__new__`, `__init__`, `__repr__`, and all getters and setters automagically.
To see how this works, see reflect.odin. I intend to make it work with more types and more complex layouts in the future.

PRs welcome, especially for testing on Mac & Linux.
