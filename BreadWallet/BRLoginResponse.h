//
//  BRLoginResponse.h
//  LoafWallet
//
//  Created by BapVn on 12/27/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRResponseType.h"

@interface BRLoginResponse : NSObject

@property (nonatomic, assign)  BRResponseType responceType;
@property (nonatomic, copy) NSString * response;
@property (nonatomic, assign) BOOL isFirstLogin;
@property (nonatomic, copy) NSString * authenKey;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary;

@end
