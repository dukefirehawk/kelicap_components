import 'package:analyzer/dart/element/element.dart';

void main() {
  LibraryElement? lib;
  var x = lib?.exportNamespace.get2('foo');
  print(x?.library);
}
