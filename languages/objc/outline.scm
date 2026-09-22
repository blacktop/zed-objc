; Objective-C

(class_interface
  "@interface" @context
  .
  (identifier) @name
  category: (identifier)? @context) @item

(class_implementation
  "@implementation" @context
  .
  (identifier) @name
  category: (identifier)? @context) @item

(protocol_declaration
  "@protocol" @context
  .
  (identifier) @name) @item

(method_declaration
  ["+" "-"] @context
  (method_type)? @context
  [
    (identifier) @name
    (method_parameter ":" @name)
  ]+) @item

(method_definition
  ["+" "-"] @context
  (method_type)? @context
  [
    (identifier) @name
    (method_parameter ":" @name)
  ]+) @item

(property_declaration
  "@property" @context
  (struct_declaration
    (struct_declarator
      [
        (identifier) @name
        (function_declarator
          declarator: (parenthesized_declarator
            (block_pointer_declarator
              declarator: (identifier) @name)))
        (pointer_declarator
          declarator: [
            (identifier) @name
            (function_declarator
              declarator: (parenthesized_declarator
                (block_pointer_declarator
                  declarator: (identifier) @name)))
          ])
      ]))) @item

; C (mirrors Zed's built-in C outline)

(preproc_def
  "#define" @context
  name: (_) @name) @item

(preproc_function_def
  "#define" @context
  name: (_) @name
  parameters: (preproc_params
    "(" @context
    ")" @context)) @item

(struct_specifier
  "struct" @context
  name: (_) @name) @item

(union_specifier
  "union" @context
  name: (_) @name) @item

(enum_specifier
  "enum" @context
  name: (_) @name) @item

(enumerator
  name: (_) @name) @item

(field_declaration
  type: (_) @context
  declarator: (field_identifier) @name) @item

(type_definition
  "typedef" @context
  declarator: (_) @name) @item

(declaration
  (type_qualifier)? @context
  type: (_)? @context
  declarator: [
    (function_declarator
      declarator: (_) @name
      parameters: (parameter_list
        "(" @context
        ")" @context))
    (pointer_declarator
      "*" @context
      declarator: (function_declarator
        declarator: (_) @name
        parameters: (parameter_list
          "(" @context
          ")" @context)))
    (pointer_declarator
      "*" @context
      declarator: (pointer_declarator
        "*" @context
        declarator: (function_declarator
          declarator: (_) @name
          parameters: (parameter_list
            "(" @context
            ")" @context))))
  ]) @item

(function_definition
  (type_qualifier)? @context
  type: (_)? @context
  declarator: [
    (function_declarator
      declarator: (_) @name
      parameters: (parameter_list
        "(" @context
        ")" @context))
    (pointer_declarator
      "*" @context
      declarator: (function_declarator
        declarator: (_) @name
        parameters: (parameter_list
          "(" @context
          ")" @context)))
    (pointer_declarator
      "*" @context
      declarator: (pointer_declarator
        "*" @context
        declarator: (function_declarator
          declarator: (_) @name
          parameters: (parameter_list
            "(" @context
            ")" @context))))
  ]) @item

(comment) @annotation
