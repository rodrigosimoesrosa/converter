import 'dart:convert';

import 'package:converter/api/api.dart';
import 'package:converter/i18n/i18n.dart';
import 'package:converter/lifecycle/lifecycle-event-handler.dart';
import 'package:converter/route/category/item/cartegory-tile.dart';
import 'package:converter/unit/unit.dart';
import 'package:converter/widget/backdrop.dart';
import 'package:converter/widget/unit-converter.dart';
import 'package:flutter/material.dart';

import 'item/category.dart';

class CategoryRoute extends StatefulWidget {
  const CategoryRoute();

  @override
  State<CategoryRoute> createState() => _CategoryRouteState();
}

class _CategoryRouteState extends State<CategoryRoute> {
  Category _defaultCategory;
  Category _currentCategory;

  final _categories = <Category>[];

  static const _colors = <ColorSwatch>[
    ColorSwatch(0xFF6AB7A8,
        {'highlight': Color(0xFF6AB7A8), 'splash': Color(0xFF0ABC9B)}),
    ColorSwatch(0xFFFFD28E, {
      'highlight': Color(0xFFFFD28E),
      'splash': Color(0xFFFFA41C),
    }),
    ColorSwatch(0xFFFFB7DE, {
      'highlight': Color(0xFFFFB7DE),
      'splash': Color(0xFFF94CBF),
    }),
    ColorSwatch(0xFF8899A8, {
      'highlight': Color(0xFF8899A8),
      'splash': Color(0xFFA9CAE8),
    }),
    ColorSwatch(0xFFEAD37E, {
      'highlight': Color(0xFFEAD37E),
      'splash': Color(0xFFFFE070),
    }),
    ColorSwatch(0xFF81A56F, {
      'highlight': Color(0xFF81A56F),
      'splash': Color(0xFF7CC159),
    }),
    ColorSwatch(0xFFD7C0E2, {
      'highlight': Color(0xFFD7C0E2),
      'splash': Color(0xFFCA90E5),
    }),
    ColorSwatch(0xFFCE9A9A, {
      'highlight': Color(0xFFCE9A9A),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFF912D2D),
    }),
  ];

  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digital_storage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(new LifecycleEventHandler(resumeCallBack: _onResume));
  }

  Future<void> _onResume() async {
    await _loadApiCategory();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    if (_categories.isEmpty) {
      await _loadLocalCategories();
    }

    await _loadApiCategory();
  }

  Future<void> _loadApiCategory() async {
    final api = Api();
    final response = await api.getUnits(apiCategory['route']);
    if (response == null) {
      return;
    }

    final units = <Unit>[];
    for (var unit in response) {
      units.add(Unit.fromJson(unit));
    }

    setState(() {
      final name = apiCategory['name'];
      _categories.removeWhere((category) => category.name == name);
      _categories.add(Category(
          name: name,
          units: units,
          color: _colors.last,
          iconLocation: _icons.last));
    });
  }

  Future<void> _loadLocalCategories() async {
    final json =
        DefaultAssetBundle.of(context).loadString('assets/data/units.json');
    final data = JsonDecoder().convert(await json);

    if (data is! Map) {
      throw (I18N.of(context).text('local_data_load_error'));
    }

    var index = 0;
    data.keys.forEach((name) {
      final List<Unit> units =
          data[name].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();

      var category = Category(
        name: name,
        units: units,
        color: _colors[index],
        iconLocation: _icons[index],
      );

      setState(() {
        _categories.add(category);
      });

      index++;
    });

    setState(() {
      _currentCategory = _categories.first;
    });
  }

  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  Widget _buildCategoriesTiles(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return ListView.builder(
          itemBuilder: (BuildContext context, int index) =>
              _buildCategoryTile(_categories[index]),
          itemCount: _categories.length);
    }

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3.0,
      children: _categories.map((Category category) {
        return _buildCategoryTile(category);
      }).toList(),
    );
  }

  Widget _buildCategoryTile(Category category) {
    final action =
        category.name == apiCategory['name'] && category.units.isEmpty
            ? null
            : _onCategoryTap;

    return CategoryTile(category: category, onTap: action);
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Center(
          child: Container(
              width: 36, height: 36, child: CircularProgressIndicator()),
        ),
      );
    }

    assert(debugCheckHasMediaQuery(context));
    final _paddingList = EdgeInsets.only(left: 8.0, right: 8.0, bottom: 48.0);
    final listView = Padding(
      padding: _paddingList,
      child: _buildCategoriesTiles(MediaQuery.of(context).orientation),
    );

    final category =
        _currentCategory == null ? _defaultCategory : _currentCategory;
    return Backdrop(
      currentCategory: category,
      frontPanel: UnitConverter(category: category),
      backPanel: listView,
      frontTitle: Text(I18N.of(context).text('backdrop_front_title')),
      backTitle: Text(I18N.of(context).text('backdrop_back_title')),
    );
  }
}
