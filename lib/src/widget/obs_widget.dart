import 'package:flutter/material.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';

import '../js/js_page_channel.dart';
import '../obs/observer.dart';

typedef ValueBuilder = Widget Function(dynamic value);

class Obs extends StatefulWidget {
  final JSPageChannel jsChannel;
  final WidgetBuilder builder;
  final String? debugLabel;
  const Obs({
    super.key,
    this.debugLabel,
    required this.jsChannel,
    required this.builder,
  });

  @override
  State<Obs> createState() => _ObsState();
}

class _ObsState extends State<Obs> {
  late Observer _observer;

  void _update() {
    setState(() {});
  }

  @override
  void initState() {
    _observer = Observer(_update, widget.jsChannel, widget.debugLabel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ObsInterface.notifyChildren(_observer, () => _buildChild());
  }

  Widget _buildChild() {
    _observer.clear();
    return widget.builder(context);
  }

  @override
  void dispose() {
    _observer.clear();
    super.dispose();
  }
}

class ObsWidget extends StatefulWidget {
  final JSPageChannel jsChannel;
  final ValueBuilder builder;
  final dynamic item;
  final String content;
  final String? debugLabel;
  const ObsWidget({
    super.key,
    required this.content,
    required this.jsChannel,
    required this.builder,
    this.debugLabel,
    this.item,
  });

  @override
  State<ObsWidget> createState() => _ObsWidgetState();
}

class _ObsWidgetState extends State<ObsWidget> {
  late Observer _observer;

  @override
  void initState() {
    _observer = Observer(_update, widget.jsChannel, widget.debugLabel);
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
    _observer.clear();
    String? v = parserText(widget.content, widget.jsChannel);
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
          dynamic c;
          if (widget.item != null) {
            c = widget.item[matchedText];
          } else {
            c = jsCaller.getField(matchedText);
          }
          content = content.replaceAll('{{$matchedText}}', c.toString());
        }
      }
      return content;
    }
    return v;
  }

  @override
  void dispose() {
    _observer.clear();
    super.dispose();
  }
}

class Obs2 extends StatefulWidget {
  final ValueBuilder builder;
  final JSPageChannel jsChannel;
  final String vIf;
  final String? debugLabel;
  const Obs2({
    super.key,
    required this.jsChannel,
    required this.builder,
    required this.vIf,
    this.debugLabel,
  });

  @override
  State<Obs2> createState() => _Obs2State();
}

class _Obs2State extends State<Obs2> {
  late Observer _observer;

  @override
  void initState() {
    _observer = Observer(_update, widget.jsChannel, widget.debugLabel);
    super.initState();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ObsInterface.notifyChildren(_observer, () => _build());
  }

  Widget _build() {
    bool result = widget.jsChannel.callExpression(widget.vIf);
    return widget.builder(result);
  }

  @override
  void dispose() {
    _observer.clear();
    super.dispose();
  }
}
