; Objective-C

(method_declaration) @function.around

(method_definition
  (compound_statement
    "{"
    (_)* @function.inside
    "}")) @function.around

(block_literal
  (compound_statement
    "{"
    (_)* @function.inside
    "}")) @function.around

(class_interface
  (_)* @class.inside) @class.around

(class_implementation
  (implementation_definition)* @class.inside) @class.around

(protocol_declaration
  (_)* @class.inside) @class.around

; C (mirrors Zed's built-in C text objects)

(declaration
  declarator: (function_declarator)) @function.around

(function_definition
  body: (_
    "{"
    (_)* @function.inside
    "}")) @function.around

(preproc_function_def
  value: (_) @function.inside) @function.around

(comment) @comment.around

(struct_specifier
  body: (_
    "{"
    (_)* @class.inside
    "}")) @class.around

(enum_specifier
  body: (_
    "{"
    [
      (_)
      ","?
    ]* @class.inside
    "}")) @class.around

(union_specifier
  body: (_
    "{"
    (_)* @class.inside
    "}")) @class.around
