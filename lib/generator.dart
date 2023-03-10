/*
 * @Author: Beoyan
 * @Date: 2023-03-10 09:39:57
 * @LastEditTime: 2023-03-10 09:39:58
 * @LastEditors: Beoyan
 * @Description: 
 */
/*
 * @Author: Beoyan
 * @Date: 2023-03-09 11:08:34
 * @LastEditTime: 2023-03-09 20:06:43
 * @LastEditors: Beoyan
 * @Description: 
 */
import 'dart:convert';

import 'json_generator.dart';
import 'template.dart';

class Generator {
  String jsonString;
  String entityName;
  Version version;

  Generator(this.jsonString,
      [this.entityName = 'Entity', this.version = Version.v0]) {
    jsonString = convertJsonString(jsonString);
  }

  List<DefaultTemplate> templateList = [];

  void refreshAllTemplates() {
    DefaultTemplate template;
    if (version == Version.v1) {
      template = V1Template(srcJson: jsonString, className: entityName);
    } else {
      template = DefaultTemplate(srcJson: jsonString, className: entityName);
    }

    if (!template.isList) {
      templateList.add(template);
      refreshTemplate(template);
      // return resultSb.toString();
    } else {
      var listTemplate = template.getListTemplate();
      templateList.add(listTemplate);

      refreshTemplate(template);
    }
  }

  String makeDartCode() {
    StringBuffer resultSb = StringBuffer();
    handleInputClassName();

    resultSb.writeln(header);
    for (var template in templateList) {
      resultSb.writeln(template.toString());
    }
    return resultSb.toString();
  }

  void handleInputClassName() {
    // final text = eClassName!.value!;
    // final lines = text.split("\n");

    // for (var i = 0; i < templateList.length; i++) {
    //   final template = templateList[i];
    // final line = lines[i].trim();
    // final inputKeyValue = line.split(":");
    // final inputName = entityName.trim();

    // template.className = inputName;
    // }
  }

  void refreshTemplate(DefaultTemplate template) {
    var fieldList = template.fieldList;
    for (var filed in fieldList) {
      if (filed is MapField) {
        DefaultTemplate template = DefaultTemplate(
            srcJson: json.encode(filed.map),
            className:
                isCamelCase ? camelCase(filed.typeString) : filed.typeString);
        if (version == Version.v1) {
          template = V1Template(
              srcJson: json.encode(filed.map),
              className:
                  isCamelCase ? camelCase(filed.typeString) : filed.typeString);
        }
        templateList.add(template);
        refreshTemplate(template);
      } else if (filed is ListField) {
        if (filed.childIsObject) {
          DefaultTemplate template = DefaultTemplate(
              srcJson: json.encode(filed.list[0]),
              className:
                  isCamelCase ? camelCase(filed.typeName) : filed.typeName);
          if (version == Version.v1) {
            template = V1Template(
                srcJson: json.encode(filed.list[0]),
                className:
                    isCamelCase ? camelCase(filed.typeName) : filed.typeName);
          }
          templateList.add(template);
          refreshTemplate(template);
        }
      }
    }
  }

  String camelCase(String name) {
    StringBuffer sb = StringBuffer();
    var list = name.split("_");
    for (int i = 0; i < list.length; i++) {
      var item = list[i];
      String name = "";
      if (i == 0) {
        name = firstLetterUpper(item);
      } else {
        name = firstLetterUpper(item);
      }
      sb.write(name);
    }
    return sb.toString();
  }

  String firstLetterUpper(String value) {
    if (value.isEmpty) {
      return "";
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  String get fileName => camelCase2UnderScoreCase(entityName);

  static const String importString =
      "import 'package:json_annotation/json_annotation.dart';";

  String get header => """$importString 
      
part '$fileName.g.dart';
    
    """;

  String getClassNameText() {
    final sb = StringBuffer();
    for (final template in templateList) {
      String text = "${template.className} : ${template.className}";
      sb.writeln(text);
    }
    return sb.toString();
  }
}

String camelCase2UnderScoreCase(String name) {
  return name[0].toLowerCase() +
      name.substring(1).replaceAllMapped(RegExp("[A-Z]"), (match) {
        var str = match.group(0);
        return "_${str!.toLowerCase()}";
      });
}

/// use the string replace's method the resolve the int and double problem.
String convertJsonString(String jsonString) {
  var numberReg = RegExp(r"[0-9]\.[0-9]+");

  //匹配小数数字正则
  var allMatch = numberReg.allMatches(jsonString).toList();

  for (var i = 0; i < allMatch.length; i++) {
    //是一个小数数字
    var m = allMatch[i];
    var s = m.group(0);

    // 应该是double，但由于js的原因被识别成了整数数，这里对这种数据进行处理，将这里的最后一位从0替换为5，以便于让该被js识别成小数 而非数字
    s = s!.replaceRange(s.length - 1, s.length, "5");
    jsonString = jsonString.replaceRange(m.start, m.end, s);
  }
  return jsonString;
}
