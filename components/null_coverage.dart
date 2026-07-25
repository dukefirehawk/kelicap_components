import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('Counting number of Dart files...');
  } else {
    print(
      'Generated through `null_coverage.dart` everytime the `dev` branch is updated.\n',
    );
  }
  var count = 0;
  await Directory('lib').list(recursive: true).forEach((element) {
    if (element is File && p.extension(element.path) == '.dart') {
      count++;
    }
  });

  if (args.isEmpty) {
    print('Analyzing...');
  }

  final analyze = await Process.start('dart', ['analyze', '--format=machine']);

  var needMigrate = <String>{};

  await analyze.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((element) {
        final output = element.split('|');

        if (output[0] == 'ERROR') {
          needMigrate.add(output[3]);
        }
      });

  print('${((1 - needMigrate.length / count) * 100).round()}% Done!');
  if (args.isNotEmpty) {
    print('');
  }
  print('${needMigrate.length} out of $count files still need to be migrated!');
  if (args.isNotEmpty) {
    print('');
  }

  for (var element in needMigrate) {
    print('- [ ] ${p.relative(element, from: 'lib')}');
  }
}
