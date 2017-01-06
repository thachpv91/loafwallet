//
//  BRResponse.h
//  LoafWallet
//
//  Created by BapVn on 1/6/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRResponseType.h"

@interface BRResponse : NSObject

@property (nonatomic)  BRResponseType responseType;
@property (nonatomic, copy) NSString * response;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary;
- (void) initAttributeWithDictionaty:(NSDictionary *) dictionary;
@end
