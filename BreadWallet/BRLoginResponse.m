//
//  BRLoginResponse.m
//  LoafWallet
//
//  Created by BapVn on 12/27/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import "BRLoginResponse.h"

@implementation BRLoginResponse

@synthesize responceType;
@synthesize  response;
@synthesize  isFirstLogin;
@synthesize  authenKey;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if(!dictionary) return self;
    if ([dictionary objectForKey:@"response_type"])
    {
        
        NSString * responseTypeStr = [[dictionary objectForKey:@"response_type"] lowercaseString];
        
        if([responseTypeStr isEqualToString:@"success"])
        {
            self.responceType = RESPONSE_TYPE_SUCCESS;
        }
        else
        {
            self.responceType = RESPONSE_TYPE_ERROR;
        }
    }
    
    if ([dictionary objectForKey:@"response"])
    {
        self.response = [dictionary objectForKey:@"response"];
    }
    
    if ([dictionary objectForKey:@"is_first_login"])
    {
        self.isFirstLogin = [[dictionary objectForKey:@"is_first_login"] boolValue];
    }
    
    if ([dictionary objectForKey:@"authen_key"])
    {
        self.authenKey = [dictionary objectForKey:@"authen_key"];
        
    }
    
    return self;
}

@end
