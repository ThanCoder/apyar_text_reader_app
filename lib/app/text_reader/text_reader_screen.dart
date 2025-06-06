import 'dart:io';

import 'package:apyar/app/action_button/content_action_button.dart';
import 'package:apyar/app/models/apyar_model.dart';
import 'package:apyar/app/providers/apyar_provider.dart';
import 'package:apyar/app/text_reader/text_reader_setting_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';

import '../components/index.dart';
import '../widgets/core/index.dart';
import 'text_reader_config_model.dart';

class TextReaderScreen extends StatefulWidget {
  ApyarModel data;
  TextReaderConfigModel config;
  bool? bookmarkValue;
  void Function(bool bookmarkValue)? onBookmarkChanged;
  void Function(TextReaderConfigModel config)? onConfigChanged;
  TextReaderScreen({
    super.key,
    required this.data,
    required this.config,
    this.bookmarkValue,
    this.onBookmarkChanged,
    this.onConfigChanged,
  });

  @override
  State<TextReaderScreen> createState() => _TextReaderScreenState();
}

class _TextReaderScreenState extends State<TextReaderScreen> {
  final ScrollController _controller = ScrollController();

  List<ApyarModel> list = [];
  bool isDataLoading = false;
  late TextReaderConfigModel config;
  late ApyarModel currentData;
  bool isGetTopData = false;
  bool? bookmarkValue;
  bool isFullScreen = false;

  @override
  void initState() {
    _controller.addListener(_onScroll);
    config = widget.config;
    currentData = widget.data;
    bookmarkValue = widget.bookmarkValue;
    super.initState();
    init();
  }

  void init() async {
    list.add(widget.data);
    setState(() {});
    initConfig();
  }

  void initConfig() {
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: config.isKeepScreen);
    }
  }

  double maxScroll = 0;

  void _onScroll() {
    final max = _controller.position.maxScrollExtent;
    final pos = _controller.position.pixels;

    if (isGetTopData && pos == 0) {
      if (!isDataLoading) {
        _loadTopItem();
      }
    }
    if (maxScroll != max && pos == max) {
      maxScroll = max;
      if (!isDataLoading) {
        _loadDownItem();
      }
    }
  }

  void _loadTopItem() {
    isDataLoading = true;
    if (currentData.isExistsPrev()) {
      currentData = currentData.getPrev();
      list.insert(0, currentData);
    } else {
      showMessage(context, '`${currentData.number + 1}` Chapter မရှိပါ ');
    }
    isDataLoading = false;
    setState(() {});
  }

  void _loadDownItem() {
    if (currentData.isExistNext()) {
      isDataLoading = true;
      currentData = currentData.getNext();
      list.add(currentData);
      isDataLoading = false;
      setState(() {});
    } else {
      // showMessage(context, '`${currentData.number + 1}` Chapter မရှိပါ ');
    }
  }

  void _toggleBookMark() {
    bookmarkValue = !bookmarkValue!;
    if (widget.onBookmarkChanged != null) {
      widget.onBookmarkChanged!(bookmarkValue!);
    }
    setState(() {});
  }

  void _showSetting() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TextReaderSettingDialog(
        config: config,
        onApply: (changedConfig) {
          config = changedConfig;
          if (widget.onConfigChanged != null) {
            widget.onConfigChanged!(changedConfig);
          }
          setState(() {});
          initConfig();
        },
      ),
    );
  }

  void _toggleFullScreen() {
    isFullScreen = !isFullScreen;
    ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apyar = context.watch<ApyarProvider>().getCurrent!;
    return MyScaffold(
      contentPadding: 0,
      body: GestureDetector(
        onLongPress: _showSetting,
        onSecondaryTap: _showSetting,
        onDoubleTap: _toggleFullScreen,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverAppBar(
              title: Text(apyar.title),
              snap: true,
              floating: true,
              actions: [
                bookmarkValue == null
                    ? SizedBox.shrink()
                    : IconButton(
                        color: bookmarkValue! ? Colors.red : Colors.teal,
                        onPressed: _toggleBookMark,
                        icon: Icon(bookmarkValue!
                            ? Icons.bookmark_remove_rounded
                            : Icons.bookmark_add_rounded),
                      ),
                ContentActionButton(
                  onBackpress: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            // list
            SliverList.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final ch = list[index];
                return Padding(
                  padding: EdgeInsets.all(config.padding),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      const Divider(),
                      Column(
                        children: [
                          Text('Chapter: ${ch.number}'),
                        ],
                      ),
                      const Divider(),
                      Text(
                        ch.getContent(),
                        style: TextStyle(
                          fontSize: config.fontSize,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
