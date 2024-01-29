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
  String field = '';

  @override
  Widget build(BuildContext context) {
    String v = widget.field.replaceAll('{{', '');
    v = v.replaceAll('}}', '');
    field = v;
    v = widget.jsCaller.getObsField(v, this);
    return widget.builder(v);
  }

  @override
  void dispose() {
    widget.jsCaller.removeObs(field, this);
    super.dispose();
  }
}
