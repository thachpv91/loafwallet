//
//  BRLoginResponse.h
//  LoafWallet
//
//  Created by BapVn on 12/27/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRResponse.h"
//@class BRResponse;

@interface BRLoginResponse : BRResponse

@property (nonatomic) BOOL isFirstLogin;
@property (nonatomic, copy) NSString * authenKey;

- (void) initAttributeWithDictionaty:(NSDictionary *) dictionary;

@end
