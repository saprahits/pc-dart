// See file LICENSE for more information.

library pointycastle.benchmark.digests.ripemd128_benchmark;

import "../benchmark/digest_benchmark.dart";

main() {
  new DigestBenchmark("RIPEMD-128").report();
}
