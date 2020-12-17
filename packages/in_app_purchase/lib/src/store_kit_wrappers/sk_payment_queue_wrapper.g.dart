// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sk_payment_queue_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SKError _$SKErrorFromJson(Map json) {
  return SKError(
    code: json['code'] as int,
    domain: json['domain'] as String,
    userInfo: (json['userInfo'] as Map)?.map(
      (k, e) => MapEntry(k as String, e),
    ),
  );
}

Map<String, dynamic> _$SKErrorToJson(SKError instance) => <String, dynamic>{
      'code': instance.code,
      'domain': instance.domain,
      'userInfo': instance.userInfo,
    };

SKPaymentDiscountWrapper _$SKPaymentDiscountWrapperFromJson(Map json) {
  return SKPaymentDiscountWrapper(
    identifier: json['identifier'] as String,
    keyIdentifier: json['keyIdentifier'] as String,
    nonce: json['nonce'] as String,
    signature: json['signature'] as String,
    timestamp: json['timestamp'] as int,
  );
}

Map<String, dynamic> _$SKPaymentDiscountWrapperToJson(
        SKPaymentDiscountWrapper instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'keyIdentifier': instance.keyIdentifier,
      'nonce': instance.nonce,
      'signature': instance.signature,
      'timestamp': instance.timestamp,
    };

SKPaymentWrapper _$SKPaymentWrapperFromJson(Map json) {
  return SKPaymentWrapper(
    productIdentifier: json['productIdentifier'] as String,
    applicationUsername: json['applicationUsername'] as String,
    requestData: json['requestData'] as String,
    quantity: json['quantity'] as int,
    paymentDiscount: json['paymentDiscount'] == null
        ? null
        : SKPaymentDiscountWrapper.fromJson(json['paymentDiscount'] as Map),
    simulatesAskToBuyInSandbox: json['simulatesAskToBuyInSandbox'] as bool,
  );
}

Map<String, dynamic> _$SKPaymentWrapperToJson(SKPaymentWrapper instance) =>
    <String, dynamic>{
      'paymentDiscount': instance.paymentDiscount,
      'productIdentifier': instance.productIdentifier,
      'applicationUsername': instance.applicationUsername,
      'requestData': instance.requestData,
      'quantity': instance.quantity,
      'simulatesAskToBuyInSandbox': instance.simulatesAskToBuyInSandbox,
    };
