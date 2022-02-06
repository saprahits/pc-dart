// See file LICENSE for more information.

library pointycastle.api.key_generators;

import "package:pointycastle/api.dart";
import "package:pointycastle/ecc/api.dart";

/// Abstract [CipherParameters] to init an ECC key generator.
class ECKeyGeneratorParameters extends KeyGeneratorParameters {
  ECDomainParameters _domainParameters;

  ECKeyGeneratorParameters(ECDomainParameters domainParameters)
      : super(domainParameters.n.bitLength) {
    _domainParameters = domainParameters;
  }

  ECDomainParameters get domainParameters => _domainParameters;
}

/// Abstract [CipherParameters] to init an RSA key generator.
class RSAKeyGeneratorParameters extends KeyGeneratorParameters {
  final BigInt publicExponent;
  final int certainty;

  RSAKeyGeneratorParameters(
      this.publicExponent, int bitStrength, this.certainty)
      : super(bitStrength);
}
