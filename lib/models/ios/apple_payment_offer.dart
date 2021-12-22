class ApplePaymentOffer {
  const ApplePaymentOffer({
    required this.uuid,
    required this.timeStamp,
    required this.signature,
    required this.identifier,
    required this.keyIdentifier,
  });

  final String uuid;
  final String signature;
  final String identifier;
  final DateTime timeStamp;
  final String keyIdentifier;

  Map<String, dynamic> toJSON() => {
        'nonce': uuid,
        'timestamp': timeStamp,
        'signature': signature,
        'identifier': identifier,
        'key_identifier': keyIdentifier,
      };
}
