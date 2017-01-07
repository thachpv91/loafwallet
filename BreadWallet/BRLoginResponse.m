//
//  BRLoginResponse.m
//  LoafWallet
//
//  Created by BapVn on 12/27/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import "BRLoginResponse.h"

@implementation BRLoginResponse

@synthesize responseType;
@synthesize  response;
@synthesize  isFirstLogin;
@synthesize  authenKey;

- (void) initAttributeWithDictionaty:(NSDictionary *) dictionary
{
    [super initAttributeWithDictionaty:dictionary];
    
    if ([dictionary objectForKey:@"is_first_login"])
    {
        self.isFirstLogin = [[dictionary objectForKey:@"is_first_login"] boolValue];
    }
    
    if ([dictionary objectForKey:@"authen_key"])
    {
        self.authenKey = [dictionary objectForKey:@"authen_key"];
    }
}
@end
