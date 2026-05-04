import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/downloader_provider.dart';
import '../widgets/quality_selection_sheet.dart';
import '../../core/link_parser.dart';
import '../../../../di.dart';

class VideoBrowserScreen extends ConsumerStatefulWidget {
  const VideoBrowserScreen({super.key});

  @override
  ConsumerState<VideoBrowserScreen> createState() => _VideoBrowserScreenState();
}

class _VideoBrowserScreenState extends ConsumerState<VideoBrowserScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  final TextEditingController _urlController = TextEditingController();

  final String desktopUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

  String url = "https://www.google.com/";
  List<String> detectedVideoUrls = [];
  bool isMagicExtractable = false;
  bool isSniffedDetected = false;
  bool isExtracting = false;

  late InAppWebViewSettings settings;

  @override
  void initState() {
    super.initState();
    _urlController.text = url;
    
    settings = InAppWebViewSettings(
      useShouldInterceptRequest: true,
      useOnLoadResource: true,
      userAgent: desktopUserAgent,
      javaScriptEnabled: true,
      mediaPlaybackRequiresUserGesture: false,
      transparentBackground: true,
      allowsInlineMediaPlayback: true,
    );
  }

  void _onUrlSubmit(String searchUrl) {
    var validUrl = searchUrl;
    if (!validUrl.contains('.') && !validUrl.startsWith('http')) {
      validUrl = "https://www.google.com/search?q=$searchUrl";
    } else if (!validUrl.startsWith("http://") && !validUrl.startsWith("https://")) {
      validUrl = "https://$validUrl";
    }
    webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(validUrl)));
  }

  void _checkAndAddVideoUrl(String? resourceUrl, String? mimeType) {
    if (resourceUrl == null) return;
    
    final lowerUrl = resourceUrl.toLowerCase();
    bool isVideo = false;
    
    if (lowerUrl.contains('.mp4') || 
        lowerUrl.contains('.m3u8') || 
        lowerUrl.contains('.webm')) {
      isVideo = true;
    } 
    else if (mimeType != null && mimeType.toLowerCase().contains('video/')) {
      isVideo = true;
    }

    if (isVideo && !detectedVideoUrls.contains(resourceUrl)) {
      if (!mounted) return;
      setState(() {
        detectedVideoUrls.add(resourceUrl);
        isSniffedDetected = true;
      });
    }
  }

  Future<void> _onDownloadPressed() async {
    if (isMagicExtractable) {
      _startMagicExtraction();
    } else {
      _showSniffedBottomSheet();
    }
  }

  Future<void> _startMagicExtraction() async {
    setState(() => isExtracting = true);
    try {
      final currentUrl = _urlController.text;
      
      // We manually trigger the extraction flow
      final result = await ref.read(extractMetadataUseCaseProvider).call(currentUrl);
      
      if (!mounted) return;
      setState(() => isExtracting = false);

      result.fold(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Extraction failed: ${failure.message}')),
        ),
        (extractionResult) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => QualitySelectionSheet(result: extractionResult),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => isExtracting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSniffedBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Sniffed Video Resources',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            if (detectedVideoUrls.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40.0),
                child: Text('No direct video links found.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: detectedVideoUrls.length,
                  itemBuilder: (context, index) {
                    final detectedUrl = detectedVideoUrls[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(detectedUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: const Text('Direct Media Link'),
                      trailing: IconButton.filledTonal(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          final fileName = "sniffed_${DateTime.now().millisecondsSinceEpoch}.mp4";
                          ref.read(downloaderProvider.notifier).startDownload(
                                url: detectedUrl,
                                fileName: fileName,
                              );
                          Navigator.pop(context);
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
  }

  @override
  Widget build(BuildContext context) {
    final showFab = isMagicExtractable || isSniffedDetected;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              hintText: 'Search or enter URL',
              prefixIcon: Icon(Icons.search, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 14),
            keyboardType: TextInputType.url,
            onSubmitted: _onUrlSubmit,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(url)),
            initialSettings: settings,
            onWebViewCreated: (controller) => webViewController = controller,
            onLoadStart: (controller, url) {
              if (url != null) {
                setState(() {
                  this.url = url.toString();
                  _urlController.text = this.url;
                  // Clear sniffed URLs on new page load
                  detectedVideoUrls.clear();
                  isSniffedDetected = false;
                  // Check for magic extraction
                  isMagicExtractable = LinkParser.isVideoUrl(this.url);
                });
              }
            },
            onLoadResource: (controller, resource) {
              _checkAndAddVideoUrl(resource.url?.toString(), null);
            },
            shouldInterceptRequest: (controller, request) async {
              _checkAndAddVideoUrl(request.url.toString(), null);
              return null;
            },
          ),
          if (isExtracting)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: showFab ? Offset.zero : const Offset(0, 2),
        child: FloatingActionButton.extended(
          onPressed: isExtracting ? null : _onDownloadPressed,
          icon: isMagicExtractable 
              ? const Icon(Icons.auto_awesome) 
              : const Icon(Icons.download),
          label: Text(isMagicExtractable 
              ? 'Magic Download' 
              : '${detectedVideoUrls.length} sniffed'),
          backgroundColor: isMagicExtractable 
              ? Colors.redAccent 
              : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
