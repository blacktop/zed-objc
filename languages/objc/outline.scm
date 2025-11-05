; Class interfaces - capture first identifier as name
(class_interface
  (identifier) @name) @item

; Class implementations - capture first identifier as name
(class_implementation
  (identifier) @name) @item

; Protocol declarations - capture first identifier as name
(protocol_declaration
  (identifier) @name) @item

; Method definitions - capture identifier as name
(method_definition
  (identifier) @name) @item

; Method declarations - capture identifier as name
(method_declaration
  (identifier) @name) @item

; Functions - use declarator field
(function_definition
  declarator: (function_declarator
    declarator: (identifier) @name)) @item

; Structs - use name field (type_identifier)
(struct_specifier
  name: (type_identifier) @name) @item

; Enums - use name field (type_identifier)
(enum_specifier
  name: (type_identifier) @name) @item
