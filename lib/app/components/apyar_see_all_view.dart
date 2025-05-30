import 'package:apyar/app/components/apyar_grid_item.dart';
import 'package:apyar/app/models/index.dart';
import 'package:flutter/material.dart';

class ApyarSeeAllView extends StatelessWidget {
  List<ApyarModel> list;
  String title;
  int showCount;
  int? showLines;
  double fontSize;
  void Function(String title, List<ApyarModel> list) onSeeAllClicked;
  void Function(ApyarModel novel) onClicked;
  EdgeInsetsGeometry? margin;
  double padding;

  ApyarSeeAllView({
    super.key,
    required this.title,
    required this.list,
    required this.onSeeAllClicked,
    required this.onClicked,
    this.showCount = 8,
    this.margin,
    this.showLines,
    this.fontSize = 11,
    this.padding = 6,
  });

  @override
  Widget build(BuildContext context) {
    final showList = list.take(showCount).toList();
    if (showList.isEmpty) return const SizedBox.shrink();
    int _showLines = 1;
    if (showLines == null && showList.length > 1) {
      _showLines = 2;
    } else {
      _showLines = showLines ?? 1;
    }
    return Container(
      padding: EdgeInsets.all(padding),
      margin: margin,
      child: SizedBox(
        height: _showLines * 160,
        child: Column(
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title),
                GestureDetector(
                  onTap: () => onSeeAllClicked(title, list),
                  child: const MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      'See All',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: showList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 150,
                  mainAxisExtent: 130,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) => ApyarGridItem(
                  // fontSize: fontSize,
                  apyar: showList[index],
                  onClicked: onClicked,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
