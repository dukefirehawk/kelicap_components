import 'dart:io';
import 'dart:convert';

import 'package:grinder/grinder.dart';

import 'package:path/path.dart' as p;

void main(List<String> args) => grind(args);

@DefaultTask()
Future<void> analyze() async {
  log('Counting number of Dart files...');
  var count = 0;
  await Directory('lib').list(recursive: true).forEach((element) {
    if (element is File && p.extension(element.path) == '.dart') {
      count++;
    }
  });

  log('Analyzing...');

  final analyze = await Process.start('dart', ['analyze', '--format=machine']);

  var needMigrate = <String>{};

  await analyze.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .forEach((element) {
        final output = element.split('|');

        if (output[2].contains('DEPRECATED')) {
          needMigrate.add(output[3]);
        }
      });

  log('${((1 - needMigrate.length / count) * 100).round()}% Done!');
  log(
    '${needMigrate.length} out of $count files are still using deprecated API!\n',
  );

  for (var element in needMigrate) {
    print('- [ ] ${p.relative(element, from: 'lib')}');
  }
}
