// See file LICENSE for more information.

library pointycastle.impl.block_chipher.test.src.null_digest;

import "dart:typed_data";

import "package:pointycastle/api.dart";
import "package:pointycastle/src/impl/base_digest.dart";
import "package:pointycastle/src/registry/registry.dart";

/**
 * An implementation of a null [Digest], that is, a digest that returns an empty string. It can be
 * used for testing or benchmarking chaining algorithms.
 */
class NullDigest extends BaseDigest {
  static final FactoryConfig FACTORY_CONFIG =
      new StaticFactoryConfig(Digest, "Null", () => NullDigest());

  final int digestSize;

  NullDigest([this.digestSize = 32]);

  final String algorithmName = "Null";

  void reset() {}

  void updateByte(int inp) {}

  void update(Uint8List inp, int inpOff, int len) {}

  int doFinal(Uint8List out, int outOff) {
    out.fillRange(0, digestSize, 0);
    return digestSize;
  }
}
