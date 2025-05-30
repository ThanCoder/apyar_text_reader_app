import 'package:apyar/app/components/index.dart';
import 'package:apyar/app/scraper/scraper_bookmark_services.dart';
import 'package:apyar/app/scraper/screens/scraper_content_bookmark_screen.dart';
import 'package:apyar/app/utils/path_util.dart';
import 'package:apyar/app/widgets/index.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<String> list = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = await ScraperBookmarkServices.getTitleList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text('Library'),
      ),
      body: isLoading
          ? TLoader()
          : CustomScrollView(
              slivers: [
                SliverGrid.builder(
                  itemCount: list.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisExtent: 180,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final data = list[index];
                    return GestureDetector(
                      onTap: () async {
                        final dataList =
                            await ScraperBookmarkServices.getDataList(
                                title: data);
                        if (!mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScraperContentBookmarkScreen(
                                title: data, list: dataList),
                          ),
                        );
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                    child: MyImageFile(
                                        path:
                                            '${PathUtil.getCachePath()}/$data')),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(174, 37, 37, 37),
                                ),
                                child: Text(
                                  data,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
