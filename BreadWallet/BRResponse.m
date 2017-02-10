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
@synthesize  responseCode;

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
        if(self.responseType == RESPONSE_TYPE_SUCCESS)
        {
            self.responseCode = RESPONSE_CODE_None;
            self.response = [[dictionary objectForKey:@"response"] stringValue];
        }else
        {
            self.responseCode = [[dictionary objectForKey:@"response"] intValue];
            self.response = [BRResponse getResponseErrorMessage:self.responseCode];
        }
    }
}

+ (NSString*) getResponseErrorMessage:(BRResponseCode) resposeCode
{
    switch (resposeCode) {
        case RESPONSE_CODE_Unauthorized:
            return NSLocalizedString(@"RESPONSE_CODE_Unauthorized", nil);
            break;
        case RESPONSE_CODE_Unexpected_Error:
            return NSLocalizedString(@"RESPONSE_CODE_Unexpected_Error", nil);
            break;
        case RESPONSE_CODE_Incorrect_Authen_Key:
            return NSLocalizedString(@"RESPONSE_CODE_Incorrect_Authen_Key", nil);
            break;
        case RESPONSE_CODE_Invalid_Mnemonic_Code:
            return NSLocalizedString(@"RESPONSE_CODE_Invalid_Mnemonic_Code", nil);
            break;
            
        default:
            break;
    }
    return nil;
}
@end
