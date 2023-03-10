import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'json_generator.dart';
import 'storage.dart';
// import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1280, 720),
        builder: (context, child) => MaterialApp(
              title: 'Flutter JSON TO Dart',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: const MyHomePage(title: 'Flutter JSON TO Dart'),
            ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController resultController = TextEditingController();

  final TextEditingController inputController = TextEditingController();

  final TextEditingController classNameController = TextEditingController();

  bool anotation = true;

  bool camelCase = true;

  bool realJson = false;

  ValueChanged<bool?>? camelCaseChange = (value) {};
  var dataHelper = CookieHelper();
  formateInputToResult() {
    String formateResult = '不是1个正确的json';
    try {
      formateResult = formatJson(inputController.text);
    } catch (e) {
      resultController.text = '不是1个正确的json';
      setState(() {
        realJson = false;
      });
      return;
    }
    setState(() {
      realJson = true;
    });

    dataHelper.saveJsonString(formateResult);
    resultController.text = getData(formateResult);
  }

  formateInput() {
    String formateResult = '不是1个正确的json';
    try {
      formateResult = formatJson(inputController.text);
    } catch (e) {
      return;
    }
    inputController.text = formateResult;
  }

  @override
  void initState() {
    super.initState();
    inputController.text = dataHelper.loadJsonString() ?? '';
    entityName = dataHelper.loadEntityName() ?? 'Entity';
    if (inputController.text.isNotEmpty) {
      formateInputToResult();
    }
    inputController.addListener(() {
      formateInputToResult();
    });

    classNameController.addListener(() {
      setState(() {
        if (classNameController.text.isNotEmpty) {
          dataHelper.saveEntityName(classNameController.text);
        }
        entityName = classNameController.text.isNotEmpty
            ? classNameController.text
            : entityName;

        formateInputToResult();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned(
              right: 0,
              child: InkWell(
                  onTap: () async {
                    Uri url =
                        Uri.parse('https://github.com/Beoyan-1/json_to_dart');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  child: Image.network(
                    "https://beoyan-1.github.io/jsonToDart/github_logo.jpg",
                    width: 70.w,
                    height: 70.w,
                    fit: BoxFit.fitWidth,
                    color: Colors.transparent,
                  ))),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('类名称'),
                    SizedBox(width: 10.w),
                    Container(
                      height: 23.h,
                      width: 150.w,
                      padding: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4)),
                      child: Center(
                        child: TextField(
                            controller: classNameController,
                            style: const TextStyle(fontSize: 20),
                            maxLines: 1,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, color: Colors.transparent)),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, color: Colors.transparent)),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 0, color: Colors.transparent)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintMaxLines: 1,
                            )),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    InkWell(
                      onTap: () {
                        setState(() {
                          useJsonKey = !useJsonKey;

                          if (!useJsonKey) {
                            camelCaseChange = null;
                            isCamelCase = false;
                          } else {
                            camelCaseChange = ((value) {});
                          }
                          formateInputToResult();
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                              child: Checkbox(
                                  value: useJsonKey, onChanged: (value) {})),
                          const Text('使用 JsonKey 注解')
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: useJsonKey
                          ? () {
                              setState(() {
                                isCamelCase = !isCamelCase;
                                formateInputToResult();
                              });
                            }
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                              child: Checkbox(
                                  value: isCamelCase,
                                  onChanged: camelCaseChange)),
                          const Text('使用驼峰命名')
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isStaticMethod = !isStaticMethod;
                          formateInputToResult();
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                              child: Checkbox(
                                  value: isStaticMethod,
                                  onChanged: (value) {})),
                          const Text('使用静态方法')
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 520.h,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('将json粘贴至左边'),
                            Container(
                                width: 500.w,
                                height: 500.h,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(4)),
                                child: TextField(
                                  expands: true,
                                  maxLines: null,
                                  controller: inputController,
                                )),
                          ]),
                    ),
                    SizedBox(width: 20.w),
                    Column(
                      children: [
                        TextButton(
                            onPressed: formateInput, child: const Text('格式化')),
                        SizedBox(height: 10.h),
                        TextButton(
                            onPressed: () {
                              if (realJson) {
                                Clipboard.setData(
                                    ClipboardData(text: resultController.text));
                              }
                            },
                            child: const Text('复制')),
                        SizedBox(height: 10.h),
                        TextButton(
                            onPressed: () {
                              if (realJson) {
                                download(resultController.text);
                              }
                            },
                            child: const Text('下载')),
                      ],
                    ),
                    SizedBox(width: 20.w),
                    SizedBox(
                      height: 530.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                              visible: realJson,
                              child: Row(
                                children: [
                                  SelectableText(
                                    '应该使用的文件名为 : $dartFileName',
                                    maxLines: 1,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  InkWell(
                                    child: Icon(
                                      Icons.copy,
                                      size: 20.h,
                                      color: Colors.red,
                                    ),
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: dartFileName));
                                    },
                                  )
                                ],
                              )),
                          Container(
                              width: 500.w,
                              height: 500.h,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(4)),
                              child: TextField(
                                maxLines: null,
                                controller: resultController,
                                expands: true,
                              )),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
