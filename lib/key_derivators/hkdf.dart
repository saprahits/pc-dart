// See file LICENSE for more information.

library pointycastle.impl.key_derivator.hkdf;

import "dart:math";
import "dart:typed_data";

import "package:pointycastle/api.dart";
import 'package:pointycastle/export.dart';
import "package:pointycastle/key_derivators/api.dart";
import "package:pointycastle/src/impl/base_key_derivator.dart";
import "package:pointycastle/src/registry/registry.dart";

/// HMAC-based Extract-and-Expand Key Derivation Function (HKDF) implemented
/// according to IETF RFC 5869.
class HKDFKeyDerivator extends BaseKeyDerivator {
  /// Intended for internal use.
  static final FactoryConfig FACTORY_CONFIG =
      new DynamicFactoryConfig.suffix(KeyDerivator, "/HKDF", (_, Match match) {
    final String digestName = match.group(1);
    final Digest digest = new Digest(digestName);
    return () {
      return new HKDFKeyDerivator(digest);
    };
  });

  static final Map<String, int> _DIGEST_BLOCK_LENGTH = {
    "GOST3411": 32,
    "MD2": 16,
    "MD4": 64,
    "MD5": 64,
    "RIPEMD-128": 64,
    "RIPEMD-160": 64,
    "SHA-1": 64,
    "SHA-224": 64,
    "SHA-256": 64,
    "SHA-384": 128,
    "SHA-512": 128,
    "Tiger": 64,
    "Whirlpool": 64,
  };

  HkdfParameters _params;

  HMac _hMac;
  int _hashLen;

  Uint8List _info;
  Uint8List _currentT;

  int _generatedBytes;

  HKDFKeyDerivator(Digest digest) {
    ArgumentError.checkNotNull(digest);

    _hMac = new HMac(digest, _getBlockLengthFromDigest(digest.algorithmName));
    _hashLen = _hMac.macSize;
  }

  @override
  String get algorithmName => "${_hMac.algorithmName}/HKDF";

  @override
  int get keySize => _params.desiredKeyLength;

  @override
  void init(covariant HkdfParameters params) {
    _params = params;

    if (_params.skipExtract) {
      // use IKM directly as PRK
      _hMac.init(new KeyParameter(_params.ikm));
    } else {
      _hMac.init(extract(_params.salt, _params.ikm));
    }

    _info = _params.info;

    _generatedBytes = 0;
    _currentT = new Uint8List(_hashLen);
  }

  @override
  int deriveKey(Uint8List inp, int inpOff, Uint8List out, int outOff) {
    // append input to the 'info' part for key derivation
    if (inp != null) {
      _info = Uint8List.fromList(_info + inp);
    }

    return _generate(out, outOff, keySize);
  }

  /// Performs the extract part of the key derivation function.
  KeyParameter extract(Uint8List salt, Uint8List ikm) {
    if (salt == null || salt.isEmpty) {
      if (_hashLen != _hMac.macSize) {
        throw new ArgumentError("Hash length doesn't equal MAC size of: ${_hMac.algorithmName}");
      }

      _hMac.init(new KeyParameter(new Uint8List(_hashLen)));
    } else {
      _hMac.init(new KeyParameter(salt));
    }

    _hMac.update(ikm, 0, ikm.length);

    Uint8List prk = new Uint8List(_hashLen);
    _hMac.doFinal(prk, 0);
    return new KeyParameter(prk);
  }

  /// Performs the expand part of the key derivation function, using currentT
  /// as input and output buffer.
  void expandNext() {
    int n = _generatedBytes ~/ _hashLen + 1;
    if (n >= 256) {
      throw new ArgumentError("HKDF cannot generate more than 255 blocks of HashLen size");
    }

    // special case for T(0): T(0) is empty, so no update
    if (_generatedBytes != 0) {
      _hMac.update(_currentT, 0, _hashLen);
    }

    _hMac.update(_info, 0, _info.length);
    _hMac.updateByte(n);
    _hMac.doFinal(_currentT, 0);
  }

  int _generate(Uint8List out, int outOff, int len) {
    if (_generatedBytes + len > 255 * _hashLen) {
      throw new ArgumentError("HKDF may only be used for 255 * HashLen bytes of output");
    }

    if (_generatedBytes % _hashLen == 0) {
      expandNext();
    }

    // copy what is left in the currentT
    int toGenerate = len;
    int posInT = _generatedBytes % _hashLen;
    int leftInT = _hashLen - _generatedBytes % _hashLen;
    int toCopy = min(leftInT, toGenerate);
    out.setRange(outOff, outOff + toCopy, _currentT.sublist(posInT));
    _generatedBytes += toCopy;
    toGenerate -= toCopy;
    outOff += toCopy;

    while (toGenerate > 0) {
      expandNext();
      toCopy = min(_hashLen, toGenerate);
      out.setRange(outOff, outOff + toCopy, _currentT.sublist(0));
      _generatedBytes += toCopy;
      toGenerate -= toCopy;
      outOff += toCopy;
    }

    return len;
  }

  static int _getBlockLengthFromDigest(String digestName) {
    var blockLength = _DIGEST_BLOCK_LENGTH.entries
        .firstWhere((map) => map.key.toLowerCase() == digestName.toLowerCase(), orElse: null)
        .value;
    if (blockLength == null) {
      throw new ArgumentError("Invalid block length for digest: ${digestName}");
    }

    return blockLength;
  }
}
