import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/downloader_provider.dart';

/// A Universal Video Downloader Screen that uses a hybrid network-sniffing approach.
/// It loads web pages and intercepts network requests to find media files.
class VideoBrowserScreen extends ConsumerStatefulWidget {
  const VideoBrowserScreen({super.key});

  @override
  ConsumerState<VideoBrowserScreen> createState() => _VideoBrowserScreenState();
}

class _VideoBrowserScreenState extends ConsumerState<VideoBrowserScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  final TextEditingController _urlController = TextEditingController();

  // Desktop Chrome User-Agent spoofing
  // Spoofing the User-Agent as a desktop browser forces websites to serve 
  // high-quality videos (often MP4) instead of mobile-optimized streaming formats.
  final String desktopUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

  String url = "https://www.google.com/";
  List<String> detectedVideoUrls = [];
  bool isVideoDetected = false;

  late InAppWebViewSettings settings;

  @override
  void initState() {
    super.initState();
    _urlController.text = url;
    
    // Configure WebView settings for network sniffing and desktop spoofing
    settings = InAppWebViewSettings(
      useShouldInterceptRequest: true, // Crucial for sniffing network requests
      useOnLoadResource: true,         // Crucial for sniffing loaded resources
      userAgent: desktopUserAgent,     // Apply Desktop Spoofing
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      transparentBackground: true,
    );
  }

  /// Handles user URL submission from the AppBar
  void _onUrlSubmit(String searchUrl) {
    var validUrl = searchUrl;
    if (!validUrl.startsWith("http://") && !validUrl.startsWith("https://")) {
      validUrl = "https://$validUrl";
    }
    webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(validUrl)));
  }

  /// The Core Sniffing Logic: Checks if a resource URL points to a video.
  void _checkAndAddVideoUrl(String? resourceUrl, String? mimeType) {
    if (resourceUrl == null) return;
    
    final lowerUrl = resourceUrl.toLowerCase();
    bool isVideo = false;
    
    // Filtering logic to detect videos
    // 1. Direct files (.mp4, .webm)
    // 2. HLS Playlists (.m3u8)
    if (lowerUrl.contains('.mp4') || 
        lowerUrl.contains('.m3u8') || 
        lowerUrl.contains('.webm')) {
      isVideo = true;
    } 
    // 3. MIME type checking (video/mp4, video/webm, etc.)
    else if (mimeType != null && mimeType.toLowerCase().contains('video/')) {
      isVideo = true;
    }

    // Add unique videos and update the UI
    if (isVideo && !detectedVideoUrls.contains(resourceUrl)) {
      if (!mounted) return;
      setState(() {
        detectedVideoUrls.add(resourceUrl);
        isVideoDetected = true;
      });
    }
  }

  /// Displays a BottomSheet with all detected video links
  void _showDownloadBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Detected Videos',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.outlineVariant),
                if (detectedVideoUrls.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No videos detected yet.',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: detectedVideoUrls.length,
                      itemBuilder: (context, index) {
                        final detectedUrl = detectedVideoUrls[index];
                        return ListTile(
                          leading: Icon(
                            Icons.video_file, 
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            detectedUrl,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          trailing: ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            onPressed: () {
                              // Extract a simple filename or use a timestamp
                              final fileName = "video_${DateTime.now().millisecondsSinceEpoch}.mp4";
                              
                              // Trigger the Riverpod provider's download method
                              ref.read(downloaderProvider.notifier).startDownload(
                                    url: detectedUrl,
                                    fileName: fileName,
                                  );
                              
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Download started!')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'Enter URL or Search',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
            ),
          ),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          keyboardType: TextInputType.url,
          onSubmitted: _onUrlSubmit,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: settings,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              if (!mounted) return;
              setState(() {
                if (url != null) {
                  this.url = url.toString();
                  _urlController.text = this.url;
                }
              });
            },
            // Sniffing Method 1: onLoadResource (Triggers when resources are loaded by the DOM)
            onLoadResource: (controller, resource) {
              _checkAndAddVideoUrl(resource.url?.toString(), null);
            },
            // Sniffing Method 2: shouldInterceptRequest (Triggers for every network request the WebView makes)
            shouldInterceptRequest: (controller, request) async {
              _checkAndAddVideoUrl(request.url.toString(), null);
              return null; // Return null to let the WebView proceed with the request normally
            },
          ),
        ],
      ),
      // Smoothly animate the FAB when a video is detected
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: isVideoDetected ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isVideoDetected ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: _showDownloadBottomSheet,
            icon: const Icon(Icons.download),
            label: Text('${detectedVideoUrls.length} Videos'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
