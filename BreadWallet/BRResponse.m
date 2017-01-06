//
//  BRResponse.m
//  LoafWallet
//
//  Created by BapVn on 1/6/17.
//  Copyright © 2017 Aaron Voisine. All rights reserved.
//

#import "BRResponse.h"

@implementation BRResponse

@synthesize responseType;
@synthesize  response;

- (instancetype)initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    if(!dictionary) return self;
    [self initAttributeWithDictionaty:dictionary];
    return self;
}
- (void) initAttributeWithDictionaty:(NSDictionary *) dictionary
{
    if ([dictionary objectForKey:@"response_type"])
    {
        
        NSString * responseTypeStr = [dictionary objectForKey:@"response_type"];
        if([responseTypeStr isEqualToString:@"success"])
        {
            self.responseType = RESPONSE_TYPE_SUCCESS;
        }
        else
        {
            self.responseType = RESPONSE_TYPE_ERROR;
        }
    }
    
    if ([dictionary objectForKey:@"response"])
    {
        self.response = [dictionary objectForKey:@"response"];
    }
}
@end
