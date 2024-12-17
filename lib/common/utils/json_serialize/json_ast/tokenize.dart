import 'package:meta/meta.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/error.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/location.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/tokenize_error_types.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/utils/substring.dart';

enum TokenType {
  leftBrace, // {
  rightBrace, // }
  leftBracket, // [
  rightBracket, // ]
  colon, // :
  comma, // ,
  string, // string
  number, // number
  true_, // true (reserved keyword, renamed to true_)
  false_, // false (reserved keyword, renamed to false_)
  null_ // null (reserved keyword, renamed to null_)
}

final Map<String, TokenType> punctuatorTokensMap = {
  '{': TokenType.leftBrace,
  '}': TokenType.rightBrace,
  '[': TokenType.leftBracket,
  ']': TokenType.rightBracket,
  ':': TokenType.colon,
  ',': TokenType.comma
};

final Map<String, TokenType> keywordTokensMap = {
  'true': TokenType.true_,
  'false': TokenType.false_,
  'null': TokenType.null_
};

enum _StringState { start, startQuoteOrChar, escape }

final Map<String, int> escapes = {
  '"': 0, // Quotation mask
  '\\': 1, // Reverse solidus
  '/': 2, // Solidus
  'b': 3, // Backspace
  'f': 4, // Form feed
  'n': 5, // New line
  'r': 6, // Carriage return
  't': 7, // Horizontal tab
  'u': 8 // 4 hexadecimal digits
};

enum _NumberState {
  start,
  minus,
  zero,
  digit,
  point,
  digitFraction,
  exp,
  expDigitOrSign,
}

bool _compareDynamicList(List? l, List? other) {
  if (l != null && other != null) {
    final len = l.length;
    if (len != other.length) {
      return false;
    }
    for (var i = 0; i < len; i++) {
      final el = l.elementAt(i);
      final otherEl = other.elementAt(i);
      if (el != otherEl) {
        return false;
      }
    }
  } else if (l == null && other != null || l != null && other == null) {
    return false;
  }
  return true;
}

@immutable
class Node {
  final String type;
  final Location? loc;

  Node(this.type, this.loc);

  // Node copyWith({
  //   String? type,
  //   Location? loc,
  // }) {
  //   return Node(
  //     type ?? this.type,
  //     loc ?? this.loc,
  //   );
  // }
}

class ValueNode extends Node {
  final String value;
  final String? raw;

  ValueNode(
    this.value,
    this.raw, {
    String type = 'Identifier',
    Location? loc,
  }) : super(type, loc);

  @override
  bool operator ==(Object other) =>
      other is ValueNode &&
      type == other.type &&
      loc == other.loc &&
      value == other.value &&
      raw == other.raw;

  @override
  int get hashCode =>
      value.hashCode ^ raw.hashCode ^ type.hashCode ^ loc.hashCode;

  ValueNode copyWith({
    String? value,
    String? raw,
    String? type,
    Location? loc,
  }) {
    return ValueNode(
      value ?? this.value,
      raw ?? this.raw,
      type: type ?? this.type,
      loc: loc ?? this.loc,
    );
  }
}

class Token {
  final TokenType? type;
  final int line;
  final int column;
  final int index;
  final String? value;
  Location? loc;
  Token(this.type, this.line, this.column, this.index, this.value);
}

class ObjectNode extends Node {
  final List<PropertyNode> children;

  ObjectNode([super.type = 'Object', super.loc, List<PropertyNode>? children])
      : children = children ?? <PropertyNode>[];

  ObjectNode copyWith({
    String? type,
    Location? loc,
    List<PropertyNode>? children,
  }) {
    return ObjectNode(
      type ?? this.type,
      loc ?? this.loc,
      children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ObjectNode &&
      type == other.type &&
      loc == other.loc &&
      _compareDynamicList(children, other.children);
}

class ArrayNode extends Node {
  final List<Node> children;

  ArrayNode([super.type = 'Array', super.loc, List<Node>? children])
      : children = children ?? <Node>[];

  ArrayNode copyWith({
    String? type,
    Location? loc,
    List<Node>? children,
  }) {
    return ArrayNode(
      type ?? this.type,
      loc ?? this.loc,
      children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ArrayNode &&
      type == other.type &&
      loc == other.loc &&
      _compareDynamicList(children, other.children);
}

class PropertyNode extends Node {
  final List<Node> children;
  final int? index;
  final ValueNode? key;
  final Node? value;

  PropertyNode({
    String type = 'Property',
    Location? loc,
    List<Node>? children,
    this.index,
    this.key,
    this.value,
  })  : children = children ?? <Node>[],
        super(type, loc);

  @override
  bool operator ==(Object other) =>
      other is PropertyNode &&
      type == other.type &&
      index == other.index &&
      loc == other.loc &&
      key == other.key &&
      value == other.value &&
      _compareDynamicList(children, other.children);

  PropertyNode copyWith({
    List<Node>? children,
    int? index,
    ValueNode? key,
    Node? value,
    String? type,
    Location? loc,
  }) {
    return PropertyNode(
      children: children ?? this.children,
      index: index ?? this.index,
      key: key ?? this.key,
      value: value ?? this.value,
      type: type ?? this.type,
      loc: loc ?? this.loc,
    );
  }
}

class LiteralNode extends Node {
  final dynamic value;
  final String? raw;

  LiteralNode(
    this.value,
    this.raw, {
    String type = 'Literal',
    Location? loc,
  }) : super(type, loc);

  @override
  bool operator ==(Object other) =>
      other is LiteralNode &&
      type == other.type &&
      loc == other.loc &&
      value == other.value &&
      raw == other.raw;

  LiteralNode copyWith({
    dynamic value,
    String? raw,
    String? type,
    Location? loc,
  }) {
    return LiteralNode(
      value ?? this.value,
      raw ?? this.raw,
      type: type ?? this.type,
      loc: loc ?? this.loc,
    );
  }
}

@immutable
class ValueIndex<T> {
  final T value;
  final int index;

  ValueIndex(this.value, this.index);

  @override
  bool operator ==(Object other) =>
      other is ValueIndex<T> && value == other.value && index == other.index;
}

// HELPERS

bool isDigit1to9(String char) {
  final charCode = char.codeUnitAt(0);
  return charCode >= '1'.codeUnitAt(0) && charCode <= '9'.codeUnitAt(0);
}

bool isDigit(String char) {
  final charCode = char.codeUnitAt(0);
  return charCode >= '0'.codeUnitAt(0) && charCode <= '9'.codeUnitAt(0);
}

bool isHex(String char) {
  final charCode = char.codeUnitAt(0);
  return (isDigit(char) ||
      (charCode >= 'a'.codeUnitAt(0) && charCode <= 'f'.codeUnitAt(0)) ||
      (charCode >= 'A'.codeUnitAt(0) && charCode <= 'F'.codeUnitAt(0)));
}

bool isExp(String char) {
  return char == 'e' || char == 'E';
}

class Position {
  final int index;
  final int line;
  final int column;

  Position(this.index, this.line, this.column);
}

// PARSERS

Position? parseWhitespace(String input, int index, int line, int column) {
  final char = input[index];

  if (char == '\r') {
    // CR (Unix)
    index++;
    line++;
    column = 1;
    if (input[index] == '\n') {
      // CRLF (Windows)
      index++;
    }
  } else if (char == '\n') {
    // LF (MacOS)
    index++;
    line++;
    column = 1;
  } else if (char == '\t' || char == ' ') {
    index++;
    column++;
  } else {
    return null;
  }

  return Position(index, line, column);
}

Token? parseChar(String input, int index, int line, int column) {
  final char = input[index];
  if (punctuatorTokensMap.containsKey(char)) {
    final tokenType = punctuatorTokensMap[char];
    return Token(tokenType, line, column + 1, index + 1, null);
  }

  return null;
}

Token? parseKeyword(String input, int index, int line, int column) {
  final entries = keywordTokensMap.entries;
  for (var i = 0; i < entries.length; i++) {
    final entry = entries.elementAt(i);
    final keyLen = entry.key.length;
    final nextLen = index + keyLen;
    final lastIndex = nextLen > input.length ? input.length : nextLen;
    if (safeSubstring(input, index, lastIndex) == entry.key) {
      return Token(entry.value, line, column + keyLen, lastIndex, entry.key);
    }
  }

  return null;
}

Token? parseString(String input, int index, int line, int column) {
  final startIndex = index;
  // final buffer = StringBuffer();
  var state = _StringState.start;

  while (index < input.length) {
    final char = input[index];

    switch (state) {
      case _StringState.start:
        {
          if (char == '"') {
            index++;
            state = _StringState.startQuoteOrChar;
          } else {
            return null;
          }
          break;
        }

      case _StringState.startQuoteOrChar:
        {
          if (char == '\\') {
            // buffer.write(char);
            index++;
            state = _StringState.escape;
          } else if (char == '"') {
            index++;
            return Token(TokenType.string, line, column + index - startIndex,
                index, safeSubstring(input, startIndex, index));
          } else {
            // buffer.write(char);
            index++;
          }
          break;
        }

      case _StringState.escape:
        {
          if (escapes.containsKey(char)) {
            // buffer.write(char);
            index++;
            if (char == 'u') {
              for (var i = 0; i < 4; i++) {
                final curChar = input[index];
                if (curChar != '' && isHex(curChar)) {
                  // buffer.write(char);
                  index++;
                } else {
                  return null;
                }
              }
            }
            state = _StringState.startQuoteOrChar;
          } else {
            return null;
          }
          break;
        }
    }
  }
  return null;
}

Token? parseNumber(String input, int index, int line, int column) {
  final startIndex = index;
  var passedValueIndex = index;
  var state = _NumberState.start;

  iterator:
  while (index < input.length) {
    final char = input[index];

    switch (state) {
      case _NumberState.start:
        {
          if (char == '-') {
            state = _NumberState.minus;
          } else if (char == '0') {
            passedValueIndex = index + 1;
            state = _NumberState.zero;
          } else if (isDigit1to9(char)) {
            passedValueIndex = index + 1;
            state = _NumberState.digit;
          } else {
            return null;
          }
          break;
        }

      case _NumberState.minus:
        {
          if (char == '0') {
            passedValueIndex = index + 1;
            state = _NumberState.zero;
          } else if (isDigit1to9(char)) {
            passedValueIndex = index + 1;
            state = _NumberState.digit;
          } else {
            return null;
          }
          break;
        }

      case _NumberState.zero:
        {
          if (char == '.') {
            state = _NumberState.point;
          } else if (isExp(char)) {
            state = _NumberState.exp;
          } else {
            break iterator;
          }
          break;
        }

      case _NumberState.digit:
        {
          if (isDigit(char)) {
            passedValueIndex = index + 1;
          } else if (char == '.') {
            state = _NumberState.point;
          } else if (isExp(char)) {
            state = _NumberState.exp;
          } else {
            break iterator;
          }
          break;
        }

      case _NumberState.point:
        {
          if (isDigit(char)) {
            passedValueIndex = index + 1;
            state = _NumberState.digitFraction;
          } else {
            break iterator;
          }
          break;
        }

      case _NumberState.digitFraction:
        {
          if (isDigit(char)) {
            passedValueIndex = index + 1;
          } else if (isExp(char)) {
            state = _NumberState.exp;
          } else {
            break iterator;
          }
          break;
        }

      case _NumberState.exp:
        {
          if (char == '+' || char == '-') {
            state = _NumberState.expDigitOrSign;
          } else if (isDigit(char)) {
            passedValueIndex = index + 1;
            state = _NumberState.expDigitOrSign;
          } else {
            break iterator;
          }
          break;
        }

      case _NumberState.expDigitOrSign:
        {
          if (isDigit(char)) {
            passedValueIndex = index + 1;
          } else {
            break iterator;
          }
          break;
        }
    }

    index++;
  }

  if (passedValueIndex > 0) {
    return Token(TokenType.number, line, column + passedValueIndex - startIndex,
        passedValueIndex, safeSubstring(input, startIndex, passedValueIndex));
  }

  return null;
}

List<Token? Function(String, int, int, int)> _parsers = [
  parseChar,
  parseKeyword,
  parseString,
  parseNumber
];

Token? _parseToken(String input, int index, int line, int column) {
  for (var i = 0; i < _parsers.length; i++) {
    final token = _parsers[i](input, index, line, column);
    if (token != null) {
      return token;
    }
  }
  return null;
}

List<Token> tokenize(String input, Settings settings) {
  var line = 1;
  var column = 1;
  var index = 0;
  var tokens = <Token>[];

  while (index < input.length) {
    final whitespace = parseWhitespace(input, index, line, column);
    if (whitespace != null) {
      index = whitespace.index;
      line = whitespace.line;
      column = whitespace.column;
      continue;
    }

    final token = _parseToken(input, index, line, column);

    if (token != null) {
      token.loc = Location.create(line, column, index, token.line, token.column,
          token.index, settings.source);
      tokens.add(token);
      index = token.index;
      line = token.line;
      column = token.column;
    } else {
      final msg = unexpectedSymbol(
          substring(input, index, index + 1), settings.source, line, column);
      throw JSONASTException(msg, input, settings.source, line, column);
    }
  }
  return tokens;
}
