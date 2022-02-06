// See file LICENSE for more information.

library pointycastle.test.key_derivators.pbkdf2_test;

import 'package:pointycastle/pointycastle.dart';

import '../test/key_derivators_tests.dart';
import '../test/src/helpers.dart';

void main() {
  var salt = createUint8ListFromString("salt");
  var pkcs = new KeyDerivator("SHA-1/HMAC/PBKDF2");
  var params = new Pbkdf2Parameters(salt, 100, 16);

  runKeyDerivatorTests(pkcs, [
    params,
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
    "12aaf52b2fc239db41778c59d0e3c927",
    params,
    "En un lugar de La Mancha, de cuyo nombre no quiero acordarme...",
    "5b78b99ac2cc6b6626558f53c7490f4a",
  ]);
}
