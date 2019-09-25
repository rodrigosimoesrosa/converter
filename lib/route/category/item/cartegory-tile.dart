import 'package:flutter/material.dart';
import 'package:converter/i18n/i18n.dart';
import 'package:converter/route/category/item/category.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final ValueChanged<Category> onTap;

  const CategoryTile({Key key, @required this.category, this.onTap})
      : assert(category != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    const _rowHeight = 100.0;
    final _borderRadius = BorderRadius.circular(_rowHeight / 2);
    final _paddingInkWell = EdgeInsets.all(8.0);
    final _paddingRow = EdgeInsets.all(16.0);

    final title = I18N.of(context).text(category.name);
    return Material(
      color: onTap == null ? Color.fromRGBO(50, 50, 50, 0.2) : Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: _borderRadius,
          highlightColor: category.color['highlight'],
          splashColor: category.color['splash'],
          onTap: onTap == null ? null : () { onTap(category); },
          child: Padding(
            padding: _paddingInkWell,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: _paddingRow,
                  child: Image.asset(category.iconLocation)
                ),
                Center(
                  child: Text(
                    title == null ? category.name : title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.title,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
