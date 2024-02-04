import 'package:flutter/material.dart';
import 'package:flutter_dsl/src/obs/obs_Interface.dart';

import '../js/js_page_channel.dart';
import '../obs/observer.dart';

typedef ValueBuilder = Widget Function(BuildContext context, dynamic value);

class Obs extends StatefulWidget {
  final JSPageChannel jsChannel;
  final ValueBuilder builder;
  final String? debugLabel;
  const Obs({
    super.key,
    this.debugLabel,
    required this.jsChannel,
    required this.builder,
  });

  @override
  State<Obs> createState() => _ObsState<Obs>();
}

class _ObsState<T extends Obs> extends State<T> {
  late Observer _observer;

  void _update() {
    if (mounted) {
      setState(() {});
    } else {
      _observer.clear();
    }
  }

  @override
  void initState() {
    _observer = Observer(_update, widget.jsChannel, widget.debugLabel);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ObsInterface.notifyChildren(_observer, () => _buildChild(context));
  }

  Widget _buildChild(BuildContext context) {
    _observer.clear();
    return widget.builder(
      context,
      null,
    );
  }

  @override
  void dispose() {
    _observer.clear();
    super.dispose();
  }
}

class ObsText extends Obs {
  final dynamic item;
  final String content;
  const ObsText({
    super.key,
    required this.content,
    required super.jsChannel,
    required super.builder,
    super.debugLabel,
    this.item,
  });

  @override
  State<ObsText> createState() => _ObsTextState();
}

class _ObsTextState extends _ObsState<ObsText> {
  @override
  Widget _buildChild(BuildContext context) {
    _observer.clear();
    String? v = parserText(widget.content, widget.jsChannel);
    return widget.builder(context, v);
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
            c = (widget.item as Map).objectForKeyPath(matchedText);
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
}

extension MapExtension on Map {
  dynamic objectForKeyPath(String keyPath) {
    if (keyPath.contains('.')) {
      dynamic value = this;
      Iterator<String> keys = keyPath.split('.').iterator;
      while (keys.moveNext()) {
        String key = keys.current;
        value = value[key];
      }
      return value;
    }
    return this[keyPath];
  }
}
