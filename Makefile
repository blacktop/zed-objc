.PHONY: clean test-queries

clean:
	rm -rf grammars \
           target \
           extension.wasm

test-queries:
	uv run --python 3.13 --with tree-sitter==0.25.2 --with ./grammars/objc python tests/test_queries.py
