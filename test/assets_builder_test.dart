import 'dart:io' as io;

import 'package:assets_scanner/assets_scanner_builder.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _pkgName = 'pkg';

const _assets = {
  '$_pkgName|assets/alarm_white.png': '123',
  '$_pkgName|assets/arrows.png': '456',
  '$_pkgName|lib/main.dart': '',
};

const _pubspecFile = {
  '$_pkgName|pubspec.yaml': '''
  flutter:
    assets:
      - assets/
  ''',
};

void main() {
  Builder builder;
  setUp(() {
    builder = assetScannerBuilder(BuilderOptions.empty);
  });

  group("AssetsBuilder default", () {
    test("generate nothing if no assets values in pubspec.yaml", () async {
      await testBuilder(builder, {
        '$_pkgName|pubspec.yaml': '',
        ..._assets,
      }, outputs: {});
    });

    test("generate r.dart", () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: {
        '$_pkgName|lib/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'),
      });
    });

    test("generate r.dart with duplicate assets value", () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        '$_pkgName|pubspec.yaml': '''
        flutter:
          assets:
            - assets/
            - assets/
            - assets/alarm_white.png
            - assets/alarm_white.png
            - assets/alarm_white.png
            - assets/alarm_white.png
        ''',
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: {
        '$_pkgName|lib/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'),
      });
    });

    test("generate r.dart with invalid assets", () async {
      final dir = io.Directory.current.path;
      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        '$_pkgName|assets/.DS_Store': '456',
        ..._pubspecFile
      }, generateFor: {
        '$_pkgName|lib/\$lib\$',
      }, outputs: {
        '$_pkgName|lib/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'),
      });
    });
  });

  group("generate with assets_scanner_options.yaml", () {
    test("generate nothing path not sub-path of lib/", () async {
      final optionsFile = io.File("assets_scanner_options.yaml");
      optionsFile.createSync();
      optionsFile.writeAsStringSync('path: src/lib');

      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, onLog: (l) {
        expect(l.message,
            "The custom path in assets_scanner_options.yaml should be sub-path of lib/.");
      });

      optionsFile.deleteSync();
    });

    test("generate with path: \"lib/src\"", () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File("assets_scanner_options.yaml");
      optionsFile.createSync();
      optionsFile.writeAsStringSync('path: lib/src');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: {
        '$_pkgName|lib/src/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test("generate with path: \"lib/src/sub\"", () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File("assets_scanner_options.yaml");
      optionsFile.createSync();
      optionsFile.writeAsStringSync('path: lib/src/sub');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: {
        '$_pkgName|lib/src/sub/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test("generate with className: \"CustomR\"", () async {
      final dir = io.Directory.current.path;
      final optionsFile = io.File("assets_scanner_options.yaml");
      optionsFile.createSync();
      optionsFile.writeAsStringSync('className: "CustomR"');

      final pathAlarm = p.join(dir, 'assets/alarm_white.png');
      final pathArrows = p.join(dir, 'assets/arrows.png');
      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: {
        '$_pkgName|lib/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class CustomR {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  /// ![]($pathAlarm)\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  /// ![]($pathArrows)\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });

    test("generate with ignoreComment: true", () async {
      final optionsFile = io.File("assets_scanner_options.yaml");
      optionsFile.createSync();
      optionsFile.writeAsStringSync('ignoreComment: true');

      await testBuilder(builder, {
        ..._assets,
        ..._pubspecFile,
      }, generateFor: {
        '$_pkgName|lib/\$lib\$'
      }, outputs: {
        '$_pkgName|lib/r.dart': decodedMatches(
            '/// GENERATED BY assets_scanner. DO NOT MODIFY.\n'
            '/// See more detail on https://github.com/littleGnAl/assets-scanner.\n'
            'class R {\n'
            '  static const package = "pkg";\n'
            '\n'
            '  static const alarm_white = "assets/alarm_white.png";\n'
            '\n'
            '  static const arrows = "assets/arrows.png";\n'
            '\n'
            '// ignore_for_file:lines_longer_than_80_chars,constant_identifier_names\n'
            '}\n'
            ''),
      });

      optionsFile.deleteSync();
    });
  });
}
