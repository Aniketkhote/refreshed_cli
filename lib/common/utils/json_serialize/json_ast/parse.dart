import 'dart:math';

import 'package:refreshed_cli/common/utils/json_serialize/json_ast/error.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/location.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/parse_error_types.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/tokenize.dart';
import 'package:refreshed_cli/common/utils/json_serialize/json_ast/utils/substring.dart';

enum _ObjectState {
  start,
  openObject,
  property,
  comma,
}

enum _PropertyState {
  start,
  key,
  colon,
}

enum _ArrayState {
  start,
  openArray,
  value,
  comma,
}

JSONASTException errorEof(
    String input, List<dynamic> tokenList, Settings settings) {
  final loc = (tokenList.isNotEmpty
      ? tokenList[tokenList.length - 1].loc.end as Loc
      : Loc(line: 1, column: 1));

  return JSONASTException(
      unexpectedEnd(), input, settings.source, loc.line, loc.column);
}

/// [hexCode] is the hexCode string without '\u' prefix
String parseHexEscape(String hexCode) {
  var charCode = 0;
  final minLength = min(hexCode.length, 4);
  for (var i = 0; i < minLength; i++) {
    charCode = charCode * 16 + int.tryParse(hexCode[i], radix: 16)!;
  }
  return String.fromCharCode(charCode);
}

final escapes = {
  'b': '\b', // Backspace
  'f': '\f', // Form feed
  'n': '\n', // New line
  'r': '\r', // Carriage return
  't': '\t' // Horizontal tab
};

final passEscapes = ['"', '\\', '/'];

String parseString(String string) {
  final result = StringBuffer();
  for (var i = 0; i < string.length; i++) {
    final char = string[i];
    if (char == '\\') {
      i++;
      final nextChar = string[i];
      if (nextChar == 'u') {
        result.write(parseHexEscape(safeSubstring(string, i + 1, i + 5)));
        i += 4;
      } else if (passEscapes.contains(nextChar)) {
        result.write(nextChar);
      } else if (escapes.containsKey(nextChar)) {
        result.write(escapes[nextChar]);
      } else {
        break;
      }
    } else {
      result.write(char);
    }
  }
  return result.toString();
}

ValueIndex<ObjectNode>? parseObject(
    String input, List<Token> tokenList, int index, Settings settings) {
  // object: leftBrace (property (comma property)*)? rightBrace
  late Token startToken;
  var object = ObjectNode();
  var state = _ObjectState.start;

  while (index < tokenList.length) {
    final token = tokenList[index];

    switch (state) {
      case _ObjectState.start:
        {
          if (token.type == TokenType.leftBrace) {
            startToken = token;
            state = _ObjectState.openObject;
            index++;
          } else {
            return null;
          }
          break;
        }

      case _ObjectState.openObject:
        {
          if (token.type == TokenType.rightBrace) {
            //  if (settings.loc != null) {
            object = object.copyWith(
                loc: Location.create(
                    startToken.loc!.start.line,
                    startToken.loc!.start.column,
                    startToken.loc!.start.offset,
                    token.loc!.end.line,
                    token.loc!.end.column,
                    token.loc!.end.offset,
                    settings.source));
            //  }
            return ValueIndex(object, index + 1);
          } else {
            final property = parseProperty(input, tokenList, index, settings)!;
            object.children.add(property.value);
            state = _ObjectState.property;
            index = property.index;
          }
          break;
        }

      case _ObjectState.property:
        {
          if (token.type == TokenType.rightBrace) {
            if (settings.loc) {
              object = object.copyWith(
                loc: Location.create(
                  startToken.loc!.start.line,
                  startToken.loc!.start.column,
                  startToken.loc!.start.offset,
                  token.loc!.end.line,
                  token.loc!.end.column,
                  token.loc!.end.offset,
                  settings.source,
                ),
              );
            }
            return ValueIndex(object, index + 1);
          } else if (token.type == TokenType.comma) {
            state = _ObjectState.comma;
            index++;
          } else {
            final msg = unexpectedToken(
                substring(
                    input, token.loc!.start.offset!, token.loc!.end.offset),
                settings.source,
                token.loc!.start.line,
                token.loc!.start.column);
            throw JSONASTException(msg, input, settings.source,
                token.loc!.start.line, token.loc!.start.column);
          }
          break;
        }

      case _ObjectState.comma:
        {
          final property = parseProperty(input, tokenList, index, settings);
          if (property != null) {
            index = property.index;
            object.children.add(property.value);
            state = _ObjectState.property;
          } else {
            final msg = unexpectedToken(
                substring(
                    input, token.loc!.start.offset!, token.loc!.end.offset),
                settings.source,
                token.loc!.start.line,
                token.loc!.start.column);
            throw JSONASTException(msg, input, settings.source,
                token.loc!.start.line, token.loc!.start.column);
          }
          break;
        }
    }
  }
  throw errorEof(input, tokenList, settings);
}

ValueIndex<PropertyNode>? parseProperty(
    String input, List<Token> tokenList, int index, Settings settings) {
  // property: string colon value
  late Token startToken;
  var property = PropertyNode();
  var state = _PropertyState.start;

  while (index < tokenList.length) {
    final token = tokenList[index];

    switch (state) {
      case _PropertyState.start:
        {
          if (token.type == TokenType.string) {
            final value = parseString(safeSubstring(input,
                token.loc!.start.offset! + 1, token.loc!.end.offset! - 1));
            var key = ValueNode(value, token.value);
            if (settings.loc) {
              key = key.copyWith(loc: token.loc);
            }
            startToken = token;
            property = property.copyWith(key: key);
            state = _PropertyState.key;
            index++;
          } else {
            return null;
          }
          break;
        }

      case _PropertyState.key:
        {
          if (token.type == TokenType.colon) {
            state = _PropertyState.colon;
            index++;
          } else {
            final msg = unexpectedToken(
                substring(
                    input, token.loc!.start.offset!, token.loc!.end.offset),
                settings.source,
                token.loc!.start.line,
                token.loc!.start.column);
            throw JSONASTException(msg, input, settings.source,
                token.loc!.start.line, token.loc!.start.column);
          }
          break;
        }

      case _PropertyState.colon:
        {
          final value = _parseValue<Node?>(input, tokenList, index, settings);
          property = property.copyWith(value: value.value);
          if (settings.loc) {
            property = property.copyWith(
                loc: Location.create(
                    startToken.loc?.start.line,
                    startToken.loc?.start.column,
                    startToken.loc?.start.offset,
                    value.value?.loc?.end.line,
                    value.value?.loc?.end.column,
                    value.value?.loc?.end.offset,
                    settings.source));
          }
          return ValueIndex(property, value.index);
        }
    }
  }
  return null;
}

ValueIndex<ArrayNode>? parseArray(
    String input, List<Token> tokenList, int index, Settings settings) {
  // array: leftBracket (value (comma value)*)? rightBracket
  late Token startToken;
  var array = ArrayNode();
  var state = _ArrayState.start;
  Token token;
  while (index < tokenList.length) {
    token = tokenList[index];
    switch (state) {
      case _ArrayState.start:
        {
          if (token.type == TokenType.leftBracket) {
            startToken = token;
            state = _ArrayState.openArray;
            index++;
          } else {
            return null;
          }
          break;
        }

      case _ArrayState.openArray:
        {
          if (token.type == TokenType.rightBracket) {
            if (settings.loc) {
              array = array.copyWith(
                  loc: Location.create(
                      startToken.loc!.start.line,
                      startToken.loc!.start.column,
                      startToken.loc!.start.offset,
                      token.loc!.end.line,
                      token.loc!.end.column,
                      token.loc!.end.offset,
                      settings.source));
            }
            return ValueIndex(array, index + 1);
          } else {
            final value = _parseValue<Node>(input, tokenList, index, settings);
            index = value.index;
            array.children.add(value.value);
            state = _ArrayState.value;
          }
          break;
        }

      case _ArrayState.value:
        {
          if (token.type == TokenType.rightBracket) {
            if (settings.loc) {
              array = array.copyWith(
                  loc: Location.create(
                      startToken.loc!.start.line,
                      startToken.loc!.start.column,
                      startToken.loc!.start.offset,
                      token.loc!.end.line,
                      token.loc!.end.column,
                      token.loc!.end.offset,
                      settings.source));
            }
            return ValueIndex(array, index + 1);
          } else if (token.type == TokenType.comma) {
            state = _ArrayState.comma;
            index++;
          } else {
            final msg = unexpectedToken(
                substring(
                    input, token.loc!.start.offset!, token.loc!.end.offset),
                settings.source,
                token.loc!.start.line,
                token.loc!.start.column);
            throw JSONASTException(msg, input, settings.source,
                token.loc!.start.line, token.loc!.start.column);
          }
          break;
        }

      case _ArrayState.comma:
        {
          final value = _parseValue<Node>(input, tokenList, index, settings);
          index = value.index;
          array.children.add(value.value);
          state = _ArrayState.value;
          break;
        }
    }
  }
  throw errorEof(input, tokenList, settings);
}

ValueIndex<LiteralNode>? parseLiteral(
    String input, List<Token> tokenList, int index, Settings settings) {
  // literal: string | number | true_ | false_ | null_
  final token = tokenList[index];
  dynamic value;

  switch (token.type) {
    case TokenType.string:
      {
        value = parseString(safeSubstring(
            input, token.loc!.start.offset! + 1, token.loc!.end.offset! - 1));
        break;
      }
    case TokenType.number:
      {
        value = int.tryParse(token.value!);
        value ??= double.tryParse(token.value!);
        break;
      }
    case TokenType.true_:
      {
        value = true;
        break;
      }
    case TokenType.false_:
      {
        value = false;
        break;
      }
    case TokenType.null_:
      {
        value = null;
        break;
      }
    default:
      {
        return null;
      }
  }

  var literal = LiteralNode(value, token.value);
  if (settings.loc) {
    literal = literal.copyWith(loc: token.loc);
  }
  return ValueIndex(literal, index + 1);
}

typedef ParserFun<T> = ValueIndex<T>? Function(
    String input, List<Token> tokenList, int index, Settings settings);

List<ParserFun> _parsersList = [parseLiteral, parseObject, parseArray];

ValueIndex<T>? _findValueIndex<T>(
    String input, List<Token> tokenList, int index, Settings settings) {
  for (var i = 0; i < _parsersList.length; i++) {
    final parser = _parsersList.elementAt(i) as ValueIndex<T>? Function(
        String, List<Token>, int, Settings);
    final valueIndex = parser(input, tokenList, index, settings);
    if (valueIndex != null) {
      return valueIndex;
    }
  }
  return null;
}

ValueIndex<T> _parseValue<T>(
    String input, List<Token> tokenList, int index, Settings settings) {
  // value: literal | object | array
  final token = tokenList[index];

  final value = _findValueIndex<T>(input, tokenList, index, settings);

  if (value != null) {
    return value;
  } else {
    final msg = unexpectedToken(
        substring(input, token.loc!.start.offset!, token.loc!.end.offset),
        settings.source,
        token.loc!.start.line,
        token.loc!.start.column);
    throw JSONASTException(msg, input, settings.source, token.loc!.start.line,
        token.loc!.start.column);
  }
}

Node parse(String input, Settings settings) {
  final tokenList = tokenize(input, settings);

  if (tokenList.isEmpty) {
    throw errorEof(input, tokenList, settings);
  }

  final value = _parseValue<Node>(input, tokenList, 0, settings);

  if (value.index == tokenList.length) {
    return value.value;
  }

  final token = tokenList[value.index];

  final msg = unexpectedToken(
      substring(input, token.loc!.start.offset!, token.loc!.end.offset),
      settings.source,
      token.loc!.start.line,
      token.loc!.start.column);
  throw JSONASTException(msg, input, settings.source, token.loc!.start.line,
      token.loc!.start.column);
}
