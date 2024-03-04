// Inside epub_view.dart or in a separate Dart file

import 'dart:typed_data';

import 'package:epub_view/src/ui/epub_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContentMeasurer extends StatefulWidget {
  final String htmlContent;
  final void Function(Size size) onMeasured;
  final EpubViewBuilders builders;
  final EpubBook document;

  const HtmlContentMeasurer({
    Key? key,
    required this.htmlContent,
    required this.onMeasured,
    required this.builders,
    required this.document,
  }) : super(key: key);

  @override
  _HtmlContentMeasurerState createState() => _HtmlContentMeasurerState();
}

class _HtmlContentMeasurerState extends State<HtmlContentMeasurer> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => measureContent());
  }

  void measureContent() {
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;
    final size = renderBox.size;
    widget.onMeasured(size);
  }

  @override
  Widget build(BuildContext context) {
    final defaultBuilder = widget.builders as EpubViewBuilders<DefaultBuilderOptions>;
    final options = defaultBuilder.options;
    return Offstage(
      offstage: true,
      child: Container(
        key: _key,
        child: Html(
          data: widget.htmlContent,
          style: {
            'html': Style(
              padding: HtmlPaddings.only(
                top: (options.paragraphPadding as EdgeInsets?)?.top,
                right: (options.paragraphPadding as EdgeInsets?)?.right,
                bottom: (options.paragraphPadding as EdgeInsets?)?.bottom,
                left: (options.paragraphPadding as EdgeInsets?)?.left,
              ),
            ).merge(Style.fromTextStyle(options.textStyle)),
          },
          extensions: [
            TagExtension(
              tagsToExtend: {"img"},
              builder: (imageContext) {
                final url = imageContext.attributes['src']!.replaceAll('../', '');
                final content = Uint8List.fromList(widget.document.Content!.Images![url]!.Content!);
                return Image(
                  image: MemoryImage(content),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
