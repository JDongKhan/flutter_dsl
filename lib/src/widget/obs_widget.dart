import 'package:flutter/material.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';

import '../js/js_page_channel.dart';
import '../obs/observer.dart';

typedef ValueBuilder = Widget Function(dynamic value);

class Obs extends StatefulWidget {
  final JSPageChannel jsCaller;
  final ValueBuilder builder;
  final String field;
  const Obs({super.key, required this.field, required this.jsCaller, required this.builder});

  @override
  State<Obs> createState() => _ObsState();
}

class _ObsState extends State<Obs> {
  List<String> fields = [];
  late Observer _observer;

  @override
  void initState() {
    _observer = Observer(_update);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ObsInterface.notifyChildren(_observer, () => _buildChild());
  }

  Widget _buildChild() {
    for (var element in fields) {
      widget.jsCaller.removeObs(element, _observer);
    }
    fields = [];
    String? v = parserText(widget.field, widget.jsCaller);
    return widget.builder(v);
  }

  String? parserText(String v, JSPageChannel jsCaller) {
    if (v.contains('{{') && v.contains('}}')) {
      String content = v;
      RegExp regex = RegExp(r'{{(.*?)}}');
      Iterable<Match> matches = regex.allMatches(v);
      for (Match match in matches) {
        String? matchedText = match.group(1);
        if (matchedText != null) {
          fields.add(matchedText);
          dynamic c = jsCaller.getField(matchedText);
          content = content.replaceAll('{{$matchedText}}', c.toString());
        }
      }
      return content;
    }
    return v;
  }

  @override
  void dispose() {
    for (var element in fields) {
      widget.jsCaller.removeObs(element, _observer);
    }
    super.dispose();
  }
}
