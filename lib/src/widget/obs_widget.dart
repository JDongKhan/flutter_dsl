import 'package:flutter/material.dart';

import '../js/js_caller.dart';

typedef ValueBuilder = Widget Function(dynamic value);

class Obs extends StatefulWidget {
  final JSCaller jsCaller;
  final ValueBuilder builder;
  final String field;
  const Obs({super.key, required this.field, required this.jsCaller, required this.builder});

  @override
  State<Obs> createState() => _ObsState();
}

class _ObsState extends State<Obs> with ObserverMixin<Obs> {
  List<String> fields = [];

  @override
  Widget build(BuildContext context) {
    for (var element in fields) {
      widget.jsCaller.removeObs(element, this);
    }
    fields = [];
    String? v = parserText(widget.field, widget.jsCaller);
    return widget.builder(v);
  }

  String? parserText(String v, JSCaller jsCaller) {
    if (v.contains('{{') && v.contains('}}')) {
      String content = v;
      RegExp regex = RegExp(r'{{(.*?)}}');
      Iterable<Match> matches = regex.allMatches(v);
      for (Match match in matches) {
        String? matchedText = match.group(1);
        if (matchedText != null) {
          fields.add(matchedText);
          dynamic c = jsCaller.getObsField(matchedText, this);
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
      widget.jsCaller.removeObs(element, this);
    }
    super.dispose();
  }
}
