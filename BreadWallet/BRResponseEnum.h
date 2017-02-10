//
//  BRResponseType.h
//  LoafWallet
//
//  Created by BapVn on 12/29/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

typedef enum BRResponseTypes
{
    RESPONSE_TYPE_ERROR = 0,
    RESPONSE_TYPE_SUCCESS
} BRResponseType;

typedef enum BRResponseCodes
{
    RESPONSE_CODE_None = 0,
    RESPONSE_CODE_Unauthorized = 1,
    RESPONSE_CODE_Incorrect_Authen_Key = 2,
    RESPONSE_CODE_Invalid_Mnemonic_Code = 3,
    RESPONSE_CODE_Unexpected_Error = 4
}BRResponseCode;
