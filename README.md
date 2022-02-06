
Pointy Castle
=============

A Dart library for encryption and decryption. In this release, most of the classes are ports of Bouncy Castle from Java to Dart. The porting is almost always
direct except for some classes that had been added to ease the use of low level
data.

To make sure nothing fails, tests and benchmarks for every algorithm are
provided. The expected results are taken from the Bouncy Castle Java version
and also from standards, and matched against the results got from Pointy Castle.

This library was adopted from the original project at https://github.com/PointyCastle/pointycastle at the request of the authors to help support ongoing development.

## Algorithms

In this release, the following algorithms are implemented:

**Block ciphers:**
  * AES

**Asymmetric block ciphers:**
  * RSA

**Asymmetric block cipher encodings:**
  * PKCS1
  * OAEP

**Stream ciphers:**
  * Salsa20

**Block cipher modes of operation:**
  * CBC (Cipher Block Chaining mode)
  * CFB (Cipher Feedback mode)
  * ECB (Electronic Code Book mode)
  * GCTR (GOST 28147 OFB counter mode)
  * OFB (Output FeedBack mode)
  * CTR (Counter mode)
  * SIC

**Paddings:**
  * PKCS7
  * ISO7816-4

**Digests:**
  * Blake2b
  * MD2
  * MD4
  * MD5
  * RIPEMD-128|160|256|320
  * SHA-1
  * SHA-224|256|384|512
  * SHA-512/t (t=8 to 376 and 392 to 504 in multiples of 8)
  * Keccak-224|256|384|512*
  * Tiger
  * Whirlpool

*_Keccak is currently implemented as SHA3Digest._

**MACs:**
  * HMAC
  * CMAC

**Signatures:**
  * (DET-)ECDSA
  * RSA

**Password based key derivators:**
  * PBKDF2
  * scrypt

**HMAC based key derivators:**
  * HKDF

**Asymmetric key generators:**
  * ECDSA
  * RSA

**Secure PRNGs:**
  * Based on block cipher in CTR mode
  * Based on block cipher in CTR mode with auto reseed (for forward security)
  * Based on Fortuna algorithm

### Instantiating implementation objects

There are two ways to instantiate objects that implement the
algorithms:

- using the registry, or
- without the registry.

#### Using the registry

Using the registry, the algorithm name is provided to high-level class
factories.

This is especially convenient when an algorithm involves multiple
algorithm implementation classes to implement. All the necessary
classes can all be instantiated with a single name
(e.g. "HMAC/SHA-256" or "SHA-1/HMAC/PBKDF2"), and they are
automatically combined together with the correct values.

For example,

```dart
final sha256 = Digest("SHA-256");
final sha1 = Digest("SHA-1");
final md5 = Digest("MD5");

final hmacSha256 = Mac("SHA-256/HMAC");
final hmacSha1 = Mac("SHA-1/HMAC");
final hmacMd5 = Mac("MD5/HMAC");

final derivator = KeyDerivator("SHA-1/HMAC/PBKDF2");

final signer = Signer("SHA-256/RSA");
```

#### Without the registry

Without the registry, each implementation class must be instantiated
using its constructor.

If an algorithm involves multiple algorithm implementation classes,
they each have to be individually instantiated and combined together
with the correct values.

For example,

``` dart
final sha256 = SHA256Digest();
final sha1 = SHA1Digest();
final md5 = MD5Digest();

final hmacSha256 = HMac(SHA256Digest(), 64);
final hmacSha512 = HMac(SHA512Digest(), 128);
final hmacMd5 = HMac(MD5Digest(), 64);

final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
```

#### Registry vs without registry

Using the registry means that all algorithms will be imported by
default, which can increase the compiled size of your program.

To avoid this, instantiate all classes directly by using the
constructors. But which classes can be instantiated with its
constructor will depend on which libraries have been imported.

### Importing libraries

A program can take one of these three approaches for importing Point
Castle libraries:

- only import pointycastle.dart;
- only import exports.dart; or
- import api.dart and individual libraries as needed.

#### Only import pointycastle.dart

The "pointycastle.dart" file exports:

- the high-level API; and
- implementations of the interfaces.

But it does not export any of the algorithm implementation classes.

``` dart
import "package:pointycastle/pointycastle.dart";
```

With this import, **none** of the implementation classes can be
instantiated directly.  The program can only use the registry.

For example,

``` dart
final sha256 = Digest("SHA-256");
// final md5 = MD5Digest(); // not available
final p = Padding("PKCS7");
// final s = FortunaRandom(); // not available
```

#### Only import exports.dart

The "export.dart" file exports:

- the high-level API,
- implementations of the interfaces; and
- every algorithm implementation class.

That is, everything!

``` dart
import "package:pointycastle/export.dart";
```

With this import, **all** of the implementation classes can be
instantiated directly.  The program can also use the registry.


For example, this works without any additional imports:

``` dart
final sha256 = Digest("SHA-256");
final md5 = MD5Digest();
final p = Padding("PKCS7");
final s = FortunaRandom();
```

#### Import api.dart and individual libraries

The "api.dart" exports only:

- the high-level API.

It does not include the implementations of the interfaces, nor any
algorithm implementation class.

``` dart
import "package:pointycastle/api.dart";
// additional imports will be needed
```

With this import, only **some** of the implementation classes can be
instantiated directly (i.e. those that are also explicitly imported).
The program can also use the registry.

For example, the following only works because of the additional imports:

``` dart
// In addition to "package:pointycastle/api.dart":
import "package:pointycastle/digests/sha256.dart";
import "package:pointycastle/digests/md5.dart"
import 'package:pointycastle/paddings/pkcs7.dart';

final sha256 = Digest("SHA-256");
final md5 = MD5Digest();
final p = Padding("PKCS7");
// final s = FortunaRandom(); // not available without 'package:pointycastle/random/fortuna_random.dart'
```

## Tutorials

Some articles on how to use some of Pointy Castle's features can be
found under the _tutorials_ directory in the sources.

- [Calculating a digest](https://github.com/PointyCastle/pointycastle/blob/master/tutorials/digest.md) - calculating a hash or digest (e.g. SHA-256, SHA-1, MD5)
- [Calculating a HMAC](https://github.com/PointyCastle/pointycastle/blob/master/tutorials/hmac.md) - calculating a hash-based message authentication code (e.g. HMAC-SHA256, HMAC-SHA1)
- [Using AES-CBC](https://github.com/PointyCastle/pointycastle/blob/master/tutorials/aes-cbc.md) - block encryption and decryption with AES-CBC
- [Using RSA](https://github.com/PointyCastle/pointycastle/blob/master/tutorials/rsa.md) - key generation, signing/verifying, and encryption/decryption
- Some [tips](https://github.com/PointyCastle/pointycastle/blob/master/tutorials/tips.md) on using Pointy Castle

_Note: the above links are to the most recent versions on the master
branch on GitHub. They may be different from the version here._
