

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class CustomWebView extends StatefulWidget {
  final String url;
  final Function(String successUrl) onTopUpSuccess;
  final Function onTopUpFailure;

  const CustomWebView({
    super.key,
    required this.url,
    required this.onTopUpSuccess,
    required this.onTopUpFailure,
  });

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    // TODO: implement initState
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {
            debugPrint('!!!! Page started loading: $url');
          },
          onPageFinished: (String url) {
            // _webViewController
            //     .runJavaScript("document.querySelector('input').focus();");
            _webViewController.clearCache();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            final String uriString = request.url;
            debugPrint('!!!! Redirected to: $uriString');
            if (uriString.contains('success')) {
              http.get(Uri.parse(request.url));
              widget.onTopUpSuccess(uriString);
              Navigator.pop(context);
              return NavigationDecision.prevent;
            } else if (uriString.contains('failure')) {
              Navigator.pop(context);
              widget.onTopUpFailure();

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final String url = widget.url;
    return WebViewWidget(
      controller: _webViewController,
    );
  }
}