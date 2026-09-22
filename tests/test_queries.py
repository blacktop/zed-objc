"""Run with `make test-queries` after Zed downloads the pinned grammar."""

from pathlib import Path
import subprocess
import tomllib
import unittest

from tree_sitter import Language, Parser, Query, QueryCursor
import tree_sitter_objc


ROOT = Path(__file__).resolve().parents[1]


class QueryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        manifest = tomllib.loads((ROOT / "extension.toml").read_text())
        revision = subprocess.check_output(
            ["git", "-C", str(ROOT / "grammars/objc"), "rev-parse", "HEAD"],
            text=True,
            timeout=10,
        ).strip()
        if revision != manifest["grammars"]["objc"]["commit"]:
            raise RuntimeError("grammars/objc must match extension.toml")
        cls.language = Language(tree_sitter_objc.language())
        cls.parser = Parser(cls.language)

    def matches(self, query_name, source):
        tree = self.parser.parse(source.encode())
        self.assertFalse(tree.root_node.has_error, str(tree.root_node))
        query = Query(
            self.language,
            (ROOT / "languages/objc" / f"{query_name}.scm").read_text(),
        )
        return QueryCursor(query).matches(tree.root_node)

    def test_all_queries_compile(self):
        for path in sorted((ROOT / "languages/objc").glob("*.scm")):
            with self.subTest(query=path.name):
                Query(self.language, path.read_text())

    def test_property_outline(self):
        for declaration, name in [
            ("@property int count;", "count"),
            ("@property (copy) NSString *title;", "title"),
            ("@property (copy) void (^completion)(id);", "completion"),
            ("@property (copy) void (^ _Nullable completion)(id value);", "completion"),
            ("@property (copy) NSString *(^nameProvider)(void);", "nameProvider"),
        ]:
            with self.subTest(declaration=declaration):
                source = f"@interface Foo\n{declaration}\n@end"
                matches = self.matches("outline", source)
                properties = [
                    match for _, match in matches
                    if any(node.type == "property_declaration" for node in match.get("item", []))
                ]
                self.assertEqual(len(properties), 1)
                self.assertEqual([node.text.decode() for node in properties[0]["name"]], [name])
                self.assertEqual([node.text.decode() for node in properties[0]["context"]], ["@property"])
                self.assertEqual(properties[0]["item"][0].text.decode(), declaration)

    def test_local_declaration_variables(self):
        for declaration, expected in [
            ("int count;", ["count"]),
            ("int *pointer;", ["pointer"]),
            ("int count, *pointer;", ["count", "pointer"]),
            ("int *pointer = 0;", ["pointer"]),
            ("int count, initialized = 0;", ["count", "initialized"]),
            ("int helper(void);", []),
        ]:
            with self.subTest(declaration=declaration):
                matches = self.matches("debugger", f"void run() {{ {declaration} }}")
                captures = [
                    node.text.decode()
                    for _, match in matches
                    for node in match.get("debug-variable", [])
                ]
                self.assertEqual(sorted(captures), sorted(expected))

    def test_message_variables(self):
        for expression, expected in [
            ("[obj doThing]", ["obj"]),
            ("[obj setValue:value forKey:key]", ["obj", "value", "key"]),
            ("[obj setValue:VALUE forKey:key]", ["obj", "key"]),
            ("[NSString stringWithFormat:format, value, other]", ["format", "value", "other"]),
            ("[obj setValue:[other value] forKey:key]", ["obj", "other", "key"]),
            ("[obj setValue:42 forKey:key]", ["obj", "key"]),
            ("[obj setValue:Value forKey:_key]", ["obj", "Value", "_key"]),
            ("[NSString string]", []),
            ("[MY_CLASS new]", []),
            ("[_CLASS new]", []),
            ("[_obj doThing]", ["_obj"]),
            ("[self doThing]", ["self"]),
            ("[[obj child] doThing]", ["obj"]),
        ]:
            with self.subTest(expression=expression):
                matches = self.matches("debugger", f"void run() {{ {expression}; }}")
                captures = [
                    node.text.decode()
                    for _, match in matches
                    for node in match.get("debug-variable", [])
                ]
                self.assertEqual(sorted(captures), sorted(expected))

    def test_class_members(self):
        for header, body in [
            ("@interface Foo : NSObject", "@property int count;\n- (void)run;"),
            ("@interface Foo : NSObject <Bar>", "{ int _count; }\n@property int count;\n- (void)run;"),
            ("@interface Foo (Extras)", "- (void)extra;\n- (void)other;"),
            ("@implementation Foo", "{ int _count; }"),
            ("@implementation Foo", "{ int _count; }\n- (void)run {}"),
            ("@implementation Foo", "- (void)run {}\n- (void)other {}"),
            ("@protocol Foo <NSObject>", "@property int count;\n- (void)run;"),
            ("@protocol Foo", "- (void)run;\n@optional\n- (void)extra;\n@required\n- (void)other;"),
        ]:
            with self.subTest(header=header, body=body):
                source = f"{header}\n{body}\n@end"
                matches = self.matches("textobjects", source)
                groups = [match for _, match in matches if "class.around" in match]
                self.assertEqual(len(groups), 1)
                inside = groups[0]["class.inside"]
                start = min(node.start_byte for node in inside)
                end = max(node.end_byte for node in inside)
                self.assertEqual(source.encode()[start:end].decode(), body)
                self.assertEqual(groups[0]["class.around"][0].text.decode(), source)

    def test_empty_class_has_no_inside_capture(self):
        for header in ["@interface Foo : NSObject", "@implementation Foo", "@protocol Foo <NSObject>"]:
            with self.subTest(header=header):
                matches = self.matches("textobjects", f"{header}\n@end")
                self.assertTrue(any("class.around" in match for _, match in matches))
                self.assertFalse(any(match.get("class.inside") for _, match in matches))

    def test_class_body_comments(self):
        for header, member in [
            ("@interface Foo : NSObject", "- (void)run;"),
            ("@implementation Foo", "- (void)run {}"),
            ("@protocol Foo <NSObject>", "- (void)run;"),
        ]:
            for body in [
                "// Documentation only",
                "/* Documentation only */",
                f"// Leading documentation\n{member}\n// Trailing documentation",
                f"/* Leading documentation */\n{member}\n/* Trailing documentation */",
            ]:
                with self.subTest(header=header, body=body):
                    source = f"{header}\n{body}\n@end"
                    matches = self.matches("textobjects", source)
                    groups = [match for _, match in matches if "class.around" in match]
                    self.assertEqual(len(groups), 1)
                    inside = groups[0].get("class.inside", [])
                    self.assertTrue(inside)
                    start = min(node.start_byte for node in inside)
                    end = max(node.end_byte for node in inside)
                    self.assertEqual(source.encode()[start:end].decode(), body)

    def test_c_folds(self):
        source = '''
#include "first.h"
#include "second.h"
#define INCREMENT(value) ((value) + 1)
#if FIRST
int first;
#elif SECOND
int second;
#else
int third;
#endif
#ifdef ENABLED
int enabled;
#endif
/* A multiline
   comment. */
struct Point {
    int x;
    int y;
};
enum Mode {
    Off,
    On
};
int helper(int n) {
    int values[] = {
        1,
        2
    };
    for (int i = 0; i < n; ++i) {
        if (i) {
            while (n > 0) {
                --n;
            }
        }
    }
    do {
        ++n;
    } while (n < 1);
    switch (n) {
        case 1:
            break;
        default:
            n = 0;
    }
    asm("nop");
    return n;
}
'''
        matches = self.matches("folds", source)
        folded = {node.type for _, match in matches for node in match.get("fold", [])}
        self.assertEqual(folded, {
            "for_statement", "if_statement", "while_statement", "do_statement",
            "switch_statement", "case_statement", "function_definition",
            "struct_specifier", "enum_specifier", "comment", "preproc_if",
            "preproc_elif", "preproc_else", "preproc_ifdef", "preproc_function_def",
            "initializer_list", "gnu_asm_expression", "preproc_include",
            "compound_statement",
        })
        includes = [
            nodes for _, match in matches
            if (nodes := match.get("fold")) and nodes[0].type == "preproc_include"
        ]
        self.assertEqual([len(nodes) for nodes in includes], [2])

    def test_objc_folds(self):
        source = """
@class Foo;
@interface Foo : NSObject
@property int count;
- (void)run;
@end
@protocol Bar
- (void)run;
@end
@implementation Foo
- (void)run {
    struct Point { int x; int y; } point;
    id items = @[@1, @2];
    id map = @{@"key": @1};
    void (^block)(void) = ^{ [self run]; };
    @try { @throw items; }
    @catch (id error) { [error description]; }
    @finally { [self run]; }
    __asm { nop }
}
@end
"""
        matches = self.matches("folds", source)
        folded = {node.type for _, match in matches for node in match.get("fold", [])}
        self.assertEqual(folded, {
            "class_declaration", "class_interface", "class_implementation",
            "protocol_declaration", "property_declaration", "method_declaration",
            "struct_declaration", "struct_declarator", "try_statement",
            "catch_clause", "finally_clause", "throw_statement", "block_literal",
            "ms_asm_block", "dictionary_literal", "array_literal",
            "struct_specifier", "compound_statement",
        })


if __name__ == "__main__":
    unittest.main()
