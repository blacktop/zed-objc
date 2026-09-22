# zed-objc
Objective-C support

Run `make test-queries` to compile the queries and check debugger, text-object,
and fold captures. Requires `uv`, Python 3.13, a C compiler, and the
`grammars/objc` checkout downloaded by Zed at the revision in `extension.toml`.
The test target installs the Python Tree-sitter bindings through `uv`.
