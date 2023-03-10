/*
 * @Author: Beoyan
 * @Date: 2023-03-09 10:59:12
 * @LastEditTime: 2023-03-09 19:23:28
 * @LastEditors: Beoyan
 * @Description: 
 */
import 'dart:convert';
import "package:universal_html/html.dart";
import 'generator.dart';

String entityName = 'Entity';

bool useJsonKey = true;

bool isCamelCase = true;
bool isStaticMethod = true;

var dartFileName = '';

// const defaultValue = """{
//   "body": "",
//   "data": [1],
//   "input_content":["1"],
//   "list1":[{"name":"hello"}],
//   "number": [1.02],
//   "user":{"name":"abc"}
// }""";
const defaultValue = "";

enum Version { v0, v1 }

Version v = Version.v1;

TextAreaElement? eResult;
TextAreaElement? eClassName;
Element? editButton;

download(String result) {
  Blob blob = Blob([result]);
  // FileSystem _filesystem =
  //     await window.requestFileSystem(1024 * 1024, persistent: false);
  // FileEntry fileEntry = await _filesystem.root.createFile('dart_test.csv');
  // FileWriter fw = await fileEntry.createWriter();
  // fw.write(blob);
  // File file = await fileEntry.file();
  AnchorElement saveLink = document.createElementNS(
      "http://www.w3.org/1999/xhtml", "a") as AnchorElement;
  saveLink.href = Url.createObjectUrlFromBlob(blob);
  // saveLink.type = "download";
  saveLink.download = dartFileName;
  saveLink.click();
}



late Generator generator;

String getData(String json) {
  try {
    formatJson(json);
  } on Exception {
    return "不是一个正确的json";
  }
  String entityClassName;
  if (entityName == "" || entityName.trim() == "") {
    entityClassName = "Entity";
  } else {
    entityClassName = entityName;
  }

  generator = Generator(json, entityClassName, v);
  generator.refreshAllTemplates();
  return makeCode(generator);
}

String makeCode(Generator generator) {
  var dartCode = generator.makeDartCode();
  dartFileName = ("${generator.fileName}.dart");
  return dartCode;
}

String formatJson(String jsonString) {
  var map = json.decode(jsonString);
  if (map is! Map && map is! List) {
    throw (Exception('json格式错误'));
  }
  var prettyString = const JsonEncoder.withIndent("  ").convert(map);
  return prettyString;
}
