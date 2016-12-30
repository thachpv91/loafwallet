//
//  BRSaveMnemonicCodeResponse.m
//  LoafWallet
//
//  Created by BapVn on 12/29/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import "BRSaveMnemonicCodeResponse.h"

@implementation BRSaveMnemonicCodeResponse

@synthesize responceType;
@synthesize response;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if(!dictionary) return self;
    if ([dictionary objectForKey:@"response_type"])
    {
        
        NSString * responseTypeStr = [dictionary objectForKey:@"response_type"];
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
    return self;
}

@end
