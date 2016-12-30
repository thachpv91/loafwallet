//
//  BRSaveMnemonicCodeResponse.h
//  LoafWallet
//
//  Created by BapVn on 12/29/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRResponseType.h"

@interface BRSaveMnemonicCodeResponse : NSObject

@property (nonatomic)  BRResponseType responceType;
@property (nonatomic, copy) NSString * response;


- (instancetype)initWithDictionary:(NSDictionary *) dictionary;

@end
