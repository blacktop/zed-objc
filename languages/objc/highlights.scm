; C (mirrors Zed's built-in C highlights; the ObjC grammar extends tree-sitter-c)

[
  "const"
  "enum"
  "extern"
  "inline"
  "sizeof"
  "static"
  "struct"
  "typedef"
  "union"
  "volatile"
] @keyword

[
  "break"
  "case"
  "continue"
  "default"
  "do"
  "else"
  "for"
  "goto"
  "if"
  "return"
  "switch"
  "while"
] @keyword.control

[
  "#define"
  "#elif"
  "#else"
  "#endif"
  "#if"
  "#ifdef"
  "#ifndef"
  "#include"
  "#import"
  (preproc_directive)
] @keyword.preproc @preproc

[
  "="
  "+="
  "-="
  "*="
  "/="
  "%="
  "&="
  "|="
  "^="
  "<<="
  ">>="
  "++"
  "--"
  "+"
  "-"
  "*"
  "/"
  "%"
  "~"
  "&"
  "|"
  "^"
  "<<"
  ">>"
  "!"
  "&&"
  "||"
  "=="
  "!="
  "<"
  ">"
  "<="
  ">="
  "->"
  "?"
  ":"
] @operator

[
  "."
  ";"
  ","
] @punctuation.delimiter

[
  "{"
  "}"
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

[
  (string_literal)
  (system_lib_string)
  (char_literal)
] @string

(escape_sequence) @string.escape

(comment) @comment

(number_literal) @number

[
  (true)
  (false)
] @boolean

(null) @constant.builtin

(identifier) @variable

((identifier) @constant
  (#match? @constant "^_*[A-Z][A-Z\\d_]*$"))

(call_expression
  function: (identifier) @function)

(call_expression
  function: (field_expression
    field: (field_identifier) @function))

(function_declarator
  declarator: (identifier) @function)

(preproc_function_def
  name: (identifier) @function.special)

(field_identifier) @property

(statement_identifier) @label

[
  (type_identifier)
  (primitive_type)
  (sized_type_specifier)
] @type

(attribute_specifier) @attribute

; Objective-C

[
  "@interface"
  "@implementation"
  "@protocol"
  "@end"
  "@property"
  "@synthesize"
  "@dynamic"
  "@selector"
  "@compatibility_alias"
  "@defs"
  "@optional"
  "@required"
  "@autoreleasepool"
  "@synchronized"
  "@import"
  "__covariant"
  "__contravariant"
  "oneway"
  "in"
  "typeof"
  "__typeof"
  "__typeof__"
  (visibility_specification)
  (protocol_qualifier)
] @keyword

(class_declaration
  "@" @keyword
  "class" @keyword)

[
  "@try"
  "@catch"
  "@finally"
  "@throw"
  "__try"
  "__catch"
  "__finally"
] @keyword.control

(method_definition
  ["+" "-"] @keyword)

(method_declaration
  ["+" "-"] @keyword)

(type_qualifier
  [
    "_Nonnull"
    "_Nullable"
    "_Nullable_result"
    "_Null_unspecified"
    "__autoreleasing"
    "__block"
    "__bridge"
    "__bridge_retained"
    "__bridge_transfer"
    "__kindof"
    "__nonnull"
    "__nullable"
    "__strong"
    "__unsafe_unretained"
    "__unused"
    "__weak"
  ]) @keyword

; Types

[
  "BOOL"
  "IMP"
  "SEL"
  "Class"
  "id"
] @type

(class_interface
  (identifier) @type)

(class_implementation
  (identifier) @type)

(class_declaration
  (identifier) @type)

(protocol_declaration
  (identifier) @type)

(protocol_forward_declaration
  (identifier) @type)

(protocol_reference_list
  (identifier) @type)

((message_expression
  receiver: (identifier) @type)
  (#match? @type "^[A-Z]"))

(module_import
  path: (identifier) @type)

; Methods and messages

(method_definition
  (identifier) @function)

(method_declaration
  (identifier) @function)

(message_expression
  method: (identifier) @function)

(selector_expression
  (identifier) @function)

(selector_expression
  (method_identifier
    (identifier) @function))

((message_expression
  method: (identifier) @constructor)
  (#match? @constructor "^(init|new|alloc)"))

; Parameters

(method_parameter
  (identifier) @variable.parameter)

(method_parameter
  declarator: (identifier) @variable.parameter)

(parameter_declaration
  declarator: (identifier) @variable.parameter)

(parameter_declaration
  declarator: (pointer_declarator
    declarator: (identifier) @variable.parameter))

; Properties and instance variables

(property_attribute
  (identifier) @attribute)

(struct_declarator
  (identifier) @property)

(struct_declarator
  (pointer_declarator
    declarator: (identifier) @property))

(property_implementation
  (identifier) @property)

; Builtins

((identifier) @variable.special
  (#any-of? @variable.special "self" "super" "_cmd"))

((identifier) @constant.builtin
  (#any-of? @constant.builtin "nil" "Nil" "NULL"))

((identifier) @boolean
  (#any-of? @boolean "YES" "NO"))

[
  "@available"
  "__builtin_available"
] @function.special

(availability_attribute_specifier) @attribute

(platform) @string.special

(version_number) @number

"@" @punctuation.special

(string_literal
  "@" @string)
