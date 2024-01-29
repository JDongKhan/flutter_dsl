library flutter_dsl;

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_dsl/src/js/unique_key_generator.dart';
import 'package:xml/xpath.dart';

import 'src/builder/builder.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'src/js/js_caller.dart';
import 'package:flutter/services.dart';

part 'src/flutter_dsl_widget.dart';
part 'src/flutter_dsl_parser.dart';

part 'src/builder/flutter_dsl_widget_builder.dart';
part 'src/builder/flutter_dsl_view_builder.dart';
part 'src/builder/flutter_dsl_text_builder.dart';
part 'src/builder/flutter_dsl_column_builder.dart';
part 'src/builder/flutter_dsl_list_view_builder.dart';
part 'src/builder/flutter_dsl_row_builder.dart';
part 'src/builder/flutter_dsl_button_builder.dart';
part 'src/builder/flutter_dsl_image_builder.dart';
