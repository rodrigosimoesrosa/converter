import 'package:flutter/material.dart';
import 'package:converter/api/api.dart';
import 'package:converter/i18n/i18n.dart';
import 'package:converter/route/category/item/category.dart';
import 'package:converter/unit/unit.dart';

class UnitConverter extends StatefulWidget {
  final Category category;
  const UnitConverter({@required this.category}) : assert(category != null);

  @override
  State<StatefulWidget> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  Unit _fromUnit;
  Unit _toUnit;
  double _inputValue;
  String _converted;
  List<DropdownMenuItem> _menuItems;

  final _inputKey = GlobalKey(debugLabel: 'inputText');

  bool _showValidationError = false;
  bool _showErrorUI = false;
  bool _showLoadingUI = false;

  final _padding = EdgeInsets.all(16.0);
  final _precision = 7;

  @override
  void initState() {
    super.initState();
    new Future.delayed(Duration.zero, () {
      _createDropdownMenuItems();
    });
    _setDefaults();
  }

  @override
  void didUpdateWidget(UnitConverter old) {
    super.didUpdateWidget(old);
    if (old.category == widget.category) {
      return;
    }

    _createDropdownMenuItems();
    _setDefaults();
  }

  void _revertValues() {
    setState(() {
      _setDefaults(lastFromUnit: _fromUnit, lastToUnit: _toUnit, inputValue: _inputValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.units == null ||
        (widget.category.name == apiCategory['name'] && _showErrorUI)) {

      return SingleChildScrollView(
        child: Container(
          margin: _padding,
          padding: _padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: widget.category.color['error'],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 180.0,
                color: Colors.white,
              ),
              Text(
                I18N.of(context).text('currency_converter_api_error'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final input = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: _inputKey,
            style: Theme.of(context).textTheme.display1,
            decoration: InputDecoration(
              labelStyle: Theme.of(context).textTheme.display1,
              errorText: _showValidationError ? I18N.of(context).text('input_invalid') : null,
              labelText: I18N.of(context).text('input'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: _updateInputValue,
          ),
          _createDropdown(_fromUnit.name, _updateFromConversion),
        ],
      ),
    );

    final arrows = RotatedBox(
      quarterTurns: 1,
      child: GestureDetector(
        onTap: _revertValues,
        child: Icon(
          Icons.compare_arrows,
          size: 40.0,
        ),
      ),

    );

    final output = Padding(
      padding: _padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputDecorator(
            child: Text(
              _converted,
              style: Theme.of(context).textTheme.display1,
            ),
            decoration: InputDecoration(
              labelText: I18N.of(context).text('output'),
              labelStyle: Theme.of(context).textTheme.display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdown(_toUnit.name, _updateToConversion),
        ],
      ),
    );

    final loading = Container(
      child: Center(
        child: Container(
            width: 36, height: 36, child: CircularProgressIndicator(valueColor:
            new AlwaysStoppedAnimation<Color>(widget.category.color['highlight']))),
      ),
    );

    final converter = ListView(
      children: _showLoadingUI ? [
        loading,
        input,
        arrows,
        output,
      ] : [
        input,
        arrows,
        output,
      ]
    );

    return Padding(
      padding: _padding,
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          if (orientation == Orientation.portrait) {
            return converter;
          } else {
            return Center(
              child: Container(
                width: 450.0,
                child: converter,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: Colors.grey[400], width: 1.0)),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.grey[50]),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              items: _menuItems,
              value: currentValue,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
      ),
    );
  }

  void _updateInputValue(String value) {
    setState(() {
      if (value == null || value.isEmpty) {
        _converted = '';
        return;
      }

      try {
        final doubleValue = double.parse(value);
        _showValidationError = false;
        _inputValue = doubleValue;
        _updateConversion();
      } on Exception {
        _showValidationError = true;
      }
    });
  }

  void _updateToConversion(value) {
    setState(() {
      _toUnit = _getUnit(value);
    });

    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateFromConversion(dynamic value) {
    setState(() {
      _fromUnit = _getUnit(value);
    });

    if (_inputValue != null) {
      _updateConversion();
    }
  }

  Unit _getUnit(name) {
    return widget.category.units.firstWhere((Unit unit) {
      return unit.name == name;
    }, orElse: null);
  }

  Future<void> _updateConversion() async {
    if (widget.category.name == apiCategory['name']) {

      setState(() {
        _showLoadingUI = true;
      });

      final api = Api();
      final conversion = await api.convert(apiCategory['route'],
          _inputValue.toString(), _fromUnit.name, _toUnit.name);

      if (conversion == null) {
        setState(() {
          _showLoadingUI = false;
          _showErrorUI = true;
        });

        return;
      }

      setState(() {
        _showLoadingUI = false;
        _showErrorUI = false;
        _converted = _getConvertedAndFormatted(conversion);
      });

      return;
    }

    setState(() {
      _converted = _getConvertedAndFormatted(
          _inputValue * (_toUnit.conversion / _fromUnit.conversion));
    });
  }

  String _getConvertedAndFormatted(double converted) {
    var value = converted.toStringAsPrecision(_precision);
    if (value.contains('.') && value.endsWith('0')) {
      var last = value.length - 1;
      while (value[last] == '0') {
        last -= 1;
      }
      value = value.substring(0, last + 1);
    }

    if (value.endsWith('.')) {
      return value.substring(0, value.length - 1);
    }

    return value;
  }

  void _createDropdownMenuItems() {
    var items = <DropdownMenuItem>[];
    for (var i = 0; i < widget.category.units.length; i++) {
      final unit = widget.category.units[i];
      final name = I18N.of(context).text(unit.name);
      final value = name == null ? unit.name : name;
      items.add(DropdownMenuItem(
          value: unit.name,
          child: Container(
              child: Text(value, softWrap: true)
          )
      ));
    }

    setState(() {
      _menuItems = items;
    });
  }

  void _setDefaults({Unit lastFromUnit, Unit lastToUnit, double inputValue = 0.0}) {
    setState(() {
      _converted = '';
      _showValidationError = false;
      _inputValue = inputValue;

      if (lastFromUnit != null && lastToUnit != null) {
        _fromUnit = lastToUnit;
        _toUnit = lastFromUnit;
        return;
      }

      _fromUnit = widget.category.units[0];
      _toUnit = widget.category.units[1];
    });

    if (_inputValue == null) {
      return;
    }

    _updateConversion();
  }
}
