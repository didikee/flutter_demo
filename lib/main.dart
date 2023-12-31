import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

// inappwebview
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'myweb.dart';

void main() {
  // it should be the first line in main method
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hot News',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    print("on button clicked.");
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFabClicked() {
    print("on fab clicked.");
    // fetchNews();
    fetchV2ex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hot News'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          Text('Hello'),
          NewsTabPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _onFabClicked,
      ),
    );
  }
}

class NewsTabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewsTabState();
  }
}

class _NewsTabState extends State<NewsTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> myTabs = [
    Tab(text: 'Baidu'),
    Tab(text: 'V2ex'),
    Tab(text: 'Github'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          tabs: myTabs,
          controller: _tabController,
        ),
        toolbarHeight: 0,
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          // Replace these containers with your actual tab content
          if (tab.text == 'Baidu') {
            return ListPages();
          } else if (tab.text == 'V2ex') {
            return V2exPages();
          } else {
            return ListView.builder(
                itemCount: 10, // Replace with the number of items in each list
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Item $index in ${tab.text}'),
                    subtitle: Text('Subtitle for Item $index'),
                  );
                });
          }
        }).toList(),
      ),
    );
  }
}

class ListPages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListPagesState();
  }
}

class _ListPagesState extends State<ListPages>
    with AutomaticKeepAliveClientMixin {
  List<News> _newsList = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView.builder(
        itemCount: _newsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(_newsList[index].image),
            title: Text(_newsList[index].title.trim(),
                maxLines: 1,
                style: TextStyle(fontSize: 16, color: "#232323".getHexColor())),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                _newsList[index].desc.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: "#545454".getHexColor()),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(_newsList[index].title.trim()),
                  ),
                  body: WebPage(_newsList[index].url),
                  // body: WebViewWidget(
                  //   controller:
                  //       createCrossWebView(context, _newsList[index].url),
                  // ),
                );
              }));
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchNews().then((value) {
      setState(() {
        _newsList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class V2exPages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2exPagesState();
  }
}

class _V2exPagesState extends State<V2exPages>
    with AutomaticKeepAliveClientMixin {
  List<V2ex> _v2exList = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView.builder(
        itemCount: _v2exList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(_v2exList[index].icon),
            title: Text(_v2exList[index].title.trim(),
                maxLines: 1,
                style: TextStyle(fontSize: 16, color: "#232323".getHexColor())),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Text(
                _v2exList[index].time.trim(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: "#545454".getHexColor()),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(_v2exList[index].title.trim()),
                  ),
                  body: WebViewWidget(
                    controller:
                        createCrossWebView(context, fixV2exClickUrl(_v2exList[index].url)),
                  ),
                );
              }));
            },
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchV2ex().then((value) {
      setState(() {
        _v2exList = value;
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
}

WebViewController createCrossWebView(BuildContext context, String url) {
// #docregion platform_features
  late final PlatformWebViewControllerCreationParams params;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
      allowsInlineMediaPlayback: true,
      mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
  } else {
    params = const PlatformWebViewControllerCreationParams();
  }

  final WebViewController controller =
      WebViewController.fromPlatformCreationParams(params);
  // #enddocregion platform_features

  controller
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          debugPrint('WebView is loading (progress : $progress%)');
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
        },
        onNavigationRequest: (NavigationRequest request) {
          // if (request.url.startsWith('https://www.youtube.com/')) {
          //   debugPrint('blocking navigation to ${request.url}');
          //   return NavigationDecision.prevent;
          // }
          // debugPrint('allowing navigation to ${request.url}');
          // return NavigationDecision.navigate;
          return NavigationDecision.prevent;
        },
        onUrlChange: (UrlChange change) {
          debugPrint('url change to ${change.url}');
        },
      ),
    )
    ..addJavaScriptChannel(
      'Toaster',
      onMessageReceived: (JavaScriptMessage message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.message)),
        );
      },
    )
    ..loadRequest(Uri.parse(url));

  // #docregion platform_features
  if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController)
        .setMediaPlaybackRequiresUserGesture(false);
  }
  // #enddocregion platform_features

  return controller;
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomListItem(
              icon: Icons.share, title: "Share with friends", onPressed: () {}),
          CustomListItem(
              icon: Icons.star_rate, title: "Rate us", onPressed: () {}),
          CustomListItem(
              icon: Icons.info_outline, title: "About", onPressed: () {}),
        ],
      ),
    );
  }
}

class CustomListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  CustomListItem({
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon),
                SizedBox(width: 16.0),
                Text(title, style: TextStyle(fontSize: 16.0)),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<News>> fetchNews() async {
  print("start fetchNews -->");
  final response =
      await http.get(Uri.parse('https://top.baidu.com/board?tab=realtime'));
  print("response.statusCode = " + response.statusCode.toString());
  List<News> news = [];
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var document = parse(response.body);

    var hotListElements =
        document.getElementsByClassName("category-wrap_iQLoo horizontal_1eKyQ");
    if (hotListElements.isNotEmpty) {
      print("html is not empty");
      for (int i = 0; i < hotListElements.length; i++) {
        var element = hotListElements[i];
        var title =
            element.getElementsByClassName("c-single-text-ellipsis")[0].text;
        var desc = element
            .getElementsByClassName("hot-desc_1m_jR small_Uvkd3")[0]
            .text;
        var imageElement =
            element.getElementsByClassName("img-wrapper_29V76")[0];
        var url = "";
        imageElement.attributes.forEach((key, value) {
          if ("href" == key) {
            url = value;
          }
        });
        var imageUrl = "";
        imageElement.children.forEach((element) {
          if ("img" == element.localName) {
            element.attributes.forEach((key, value) {
              if ("src" == key) {
                imageUrl = value;
              }
            });
          }
        });
        // element.getElementsByClassName("HotItem-img")[0].
        print("title: " + title);
        print("desc: " + desc);
        print("imageUrl: " + imageUrl);
        news.add(News(title, desc, imageUrl, url));
      }
    } else {
      print("html is empty");
    }
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    debugPrint("Failed to load news");
  }
  return news;
}

class News {
  String title = "";
  String desc = "";
  String image = "";
  String url = "";

  News(this.title, this.desc, this.image, this.url);
}

Future<List<V2ex>> fetchV2ex() async {
  print("start fetchV2ex -->");
  final response = await http.get(Uri.parse('https://www.v2ex.com/?tab=hot'));
  print("response.statusCode = " + response.statusCode.toString());
  List<V2ex> v2exList = [];
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var document = parse(response.body);
    var itemElement = document.getElementsByClassName("cell item");
    if (itemElement.isNotEmpty) {
      for (int i = 0; i < itemElement.length; i++) {
        var v2ex = V2ex();
        var element = itemElement[i];
        print("item: " + element.outerHtml);
        // icon
        element
            .getElementsByClassName("avatar")[0]
            .attributes
            .forEach((key, value) {
          if ("src" == key) {
            v2ex.icon = value;
          }
        });
        // title
        v2ex.title = element.getElementsByClassName("item_title")[0].text;

        // author
        // element.getElementsByClassName("small fade")[0].children.forEach((e1) {
        //   if ("strong" == e1.localName) {
        //     v2ex.author = e1.text;
        //   }
        // });
        element.getElementsByTagName("span").forEach((e1) {
          var text = e1.text;
          if (e1.text.isNotEmpty && text.contains("前")) {
            v2ex.time = text;
          }
        });
        // time
        // v2ex.time = element.getElementsByClassName("small fade")[1].text;
        // url
        element
            .getElementsByClassName("item_title")[0]
            .getElementsByClassName("topic-link")[0]
            .attributes
            .forEach((key, value) {
          if ("href" == key) {
            v2ex.url = value;
            print("v2ex link: " + value);
          }
        });
        v2exList.add(v2ex);
      }
    }
  }
  return v2exList;
}

class V2ex {
  String title = "";
  String icon = "";
  String author = "";
  String time = "";
  String url = "";
}

String fixV2exClickUrl(String url) {
  if (url.startsWith("https://www.v2ex.com")) {
    return url;
  }
  return "https://www.v2ex.com" + url;
}

extension HexString on String {
  int getHexValue() {
    return int.parse(replaceAll('#', '0xff'));
  }

  Color getHexColor() {
    return Color(int.parse(replaceAll('#', '0xff')));
  }
}
