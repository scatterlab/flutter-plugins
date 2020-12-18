// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FIAObjectTranslator.h"

#pragma mark - SKProduct Coders

@implementation FIAObjectTranslator

+ (NSDictionary *)getMapFromSKProduct:(SKProduct *)product {
  if (!product) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"localizedDescription" : product.localizedDescription ?: [NSNull null],
    @"localizedTitle" : product.localizedTitle ?: [NSNull null],
    @"productIdentifier" : product.productIdentifier ?: [NSNull null],
    @"price" : product.price.description ?: [NSNull null]

  }];
  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:product.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  if (@available(iOS 11.2, *)) {
    [map setObject:[FIAObjectTranslator
                       getMapFromSKProductSubscriptionPeriod:product.subscriptionPeriod]
                       ?: [NSNull null]
            forKey:@"subscriptionPeriod"];
  }
  if (@available(iOS 11.2, *)) {
    [map setObject:[FIAObjectTranslator getMapFromSKProductDiscount:product.introductoryPrice]
                       ?: [NSNull null]
            forKey:@"introductoryPrice"];
  }
  if (@available(iOS 12.0, *)) {
    [map setObject:product.subscriptionGroupIdentifier ?: [NSNull null]
            forKey:@"subscriptionGroupIdentifier"];
  }
  return map;
}

+ (NSDictionary *)getMapFromSKProductSubscriptionPeriod:(SKProductSubscriptionPeriod *)period {
  if (!period) {
    return nil;
  }
  return @{@"numberOfUnits" : @(period.numberOfUnits), @"unit" : @(period.unit)};
}

+ (NSDictionary *)getMapFromSKProductDiscount:(SKProductDiscount *)discount {
  if (!discount) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"price" : discount.price.description ?: [NSNull null],
    @"numberOfPeriods" : @(discount.numberOfPeriods),
    @"subscriptionPeriod" :
            [FIAObjectTranslator getMapFromSKProductSubscriptionPeriod:discount.subscriptionPeriod]
        ?: [NSNull null],
    @"paymentMode" : @(discount.paymentMode)
  }];

  // TODO(cyanglaz): NSLocale is a complex object, want to see the actual need of getting this
  // expanded to a map. Matching android to only get the currencySymbol for now.
  // https://github.com/flutter/flutter/issues/26610
  [map setObject:[FIAObjectTranslator getMapFromNSLocale:discount.priceLocale] ?: [NSNull null]
          forKey:@"priceLocale"];
  return map;
}

+ (NSDictionary *)getMapFromSKProductsResponse:(SKProductsResponse *)productResponse {
  if (!productResponse) {
    return nil;
  }
  NSMutableArray *productsMapArray = [NSMutableArray new];
  for (SKProduct *product in productResponse.products) {
    [productsMapArray addObject:[FIAObjectTranslator getMapFromSKProduct:product]];
  }
  return @{
    @"products" : productsMapArray,
    @"invalidProductIdentifiers" : productResponse.invalidProductIdentifiers ?: @[]
  };
}

+ (NSDictionary *)getMapFromSKPayment:(SKPayment *)payment {
  if (!payment) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"productIdentifier" : payment.productIdentifier ?: [NSNull null],
    @"requestData" : payment.requestData ? [[NSString alloc] initWithData:payment.requestData
                                                                 encoding:NSUTF8StringEncoding]
                                         : [NSNull null],
    @"quantity" : @(payment.quantity),
    @"applicationUsername" : payment.applicationUsername ?: [NSNull null]
  }];
  if (@available(iOS 8.3, *)) {
    [map setObject:@(payment.simulatesAskToBuyInSandbox) forKey:@"simulatesAskToBuyInSandbox"];
  }
  return map;
}

+ (NSDictionary *)getMapFromNSLocale:(NSLocale *)locale {
  if (!locale) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] init];
  [map setObject:[locale objectForKey:NSLocaleCurrencySymbol] ?: [NSNull null]
          forKey:@"currencySymbol"];
  [map setObject:[locale objectForKey:NSLocaleCurrencyCode] ?: [NSNull null]
          forKey:@"currencyCode"];
  return map;
}

+ (SKMutablePayment *)getSKMutablePaymentFromMap:(NSDictionary *)map {
  if (!map) {
    return nil;
  }
  SKMutablePayment *payment = [[SKMutablePayment alloc] init];
  payment.productIdentifier = map[@"productIdentifier"];
  NSString *utf8String = map[@"requestData"];
  payment.requestData = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
  payment.quantity = [map[@"quantity"] integerValue];
  payment.applicationUsername = map[@"applicationUsername"];
  if (@available(iOS 8.3, *)) {
    payment.simulatesAskToBuyInSandbox = [map[@"simulatesAskToBuyInSandbox"] boolValue];
  }

  if (@available(iOS 12.2, *)) {
    payment.paymentDiscount = [FIAObjectTranslator getSKPaymentDiscountFromMap:map[@"paymentDiscount"]];
  }
  return payment;
}

+ (SKPaymentDiscount *) getSKPaymentDiscountFromMap:(NSDictionary *)map  API_AVAILABLE(ios(12.2)){
    if(!map) {
        return nil;
    }
    
    
    SKPaymentDiscount *paymentDiscount = [
                                          [SKPaymentDiscount alloc]
                                          initWithIdentifier:map[@"identifier"]
                                          keyIdentifier:map[@"keyIdentifier"]
                                          nonce:[[NSUUID alloc] initWithUUIDString:map[@"nonce"]]
                                          signature:map[@"signature"]
                                          timestamp:@([map[@"timestamp"] integerValue])
                                          ];

    return paymentDiscount;
}

+ (NSDictionary *)getMapFromSKPaymentTransaction:(SKPaymentTransaction *)transaction {
  if (!transaction) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"error" : [FIAObjectTranslator getMapFromNSError:transaction.error] ?: [NSNull null],
    @"payment" : transaction.payment ? [FIAObjectTranslator getMapFromSKPayment:transaction.payment]
                                     : [NSNull null],
    @"originalTransaction" : transaction.originalTransaction
        ? [FIAObjectTranslator getMapFromSKPaymentTransaction:transaction.originalTransaction]
        : [NSNull null],
    @"transactionTimeStamp" : transaction.transactionDate
        ? @(transaction.transactionDate.timeIntervalSince1970)
        : [NSNull null],
    @"transactionIdentifier" : transaction.transactionIdentifier ?: [NSNull null],
    @"transactionState" : @(transaction.transactionState)
  }];

  return map;
}

+ (NSDictionary *)getMapFromSKPaymentDiscount:(SKPaymentDiscount *)paymentDiscount  API_AVAILABLE(ios(12.2)){
  if (!paymentDiscount) {
    return nil;
  }
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithDictionary:@{
    @"identifier" : paymentDiscount.identifier,
    @"keyIdentifier" : paymentDiscount.keyIdentifier,
    @"nonce" : paymentDiscount.nonce.UUIDString,
    @"signature" : paymentDiscount.signature,
    @"timestamp" : paymentDiscount.timestamp,
  }];
  return map;
}

+ (NSDictionary *)getMapFromNSError:(NSError *)error {
  if (!error) {
    return nil;
  }
  NSMutableDictionary *userInfo = [NSMutableDictionary new];
  for (NSErrorUserInfoKey key in error.userInfo) {
    id value = error.userInfo[key];
    if ([value isKindOfClass:[NSError class]]) {
      userInfo[key] = [FIAObjectTranslator getMapFromNSError:value];
    } else if ([value isKindOfClass:[NSURL class]]) {
      userInfo[key] = [value absoluteString];
    } else {
      userInfo[key] = value;
    }
  }
  return @{@"code" : @(error.code), @"domain" : error.domain ?: @"", @"userInfo" : userInfo};
}

@end
