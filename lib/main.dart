import 'package:flutter/material.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('sample app'),
      ),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WebviewScreen(),
                ),
              );
            },
            child: const Text("webview 表示"),
          ),
        ),
      ),
    );
  }
}

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = _createController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('sample app'),
      ),
      body: FutureBuilder(
          future: controller,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return WebViewWidget(
                controller: snapshot.data as WebViewController,
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

Future<WebViewController> _createController() async {
  const demoUrl = 'https://flutter.dev';

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {},
        onPageFinished: (String url) async {
          final cookies = await WebviewCookieManager().getCookies(url);
          print('getCookies: $cookies');
        },
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
      ),
    )
    ..loadRequest(Uri.parse(demoUrl));

  // cookieを設定
  const cookie = WebViewCookie(
    name: 'token',
    value: 'your_access_token',
    domain: demoUrl,
  );
  await WebViewCookieManager().setCookie(cookie);

  // NOTE: 以下はandroidのみ有効。iosだと実行されない。
  controller.runJavaScript("""
  window.localStorage.setItem('access_token', 'your_access_token');
  const token = window.localStorage.getItem('access_token');
  window.confirm('取得したアクセストークン: ' + token);
""");

  return controller;
}
