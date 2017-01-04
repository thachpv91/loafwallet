//
//  BRLoginViewController.h
//  LoafWallet
//
//  Created by BapVn on 12/22/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROTO @"http"
#define HOST  @"192.168.0.99/api/v1/user"
//#define HOST  @"45.32.102.232/api/v1/user"
#define BASE_URL  PROTO@"://"HOST

#define BAP_API_LOGIN               @"login"
#define BAP_API_SET_MNEMONIC_CODE   @"set_mnemonic_code"

@interface BRLoginViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableData *_responseData;

}
@property (weak, nonatomic) IBOutlet UITextField *textUserName;
@property (weak, nonatomic) IBOutlet UITextField *textPass;

@property (nonatomic, copy) NSString * _Nullable _userName; // requesting seedPhrase will trigger
@property (nonatomic, copy) NSString * _Nullable _passWord;

- (void) requestLogin:(NSString * _Nonnull)userName withPass:(NSString * _Nonnull)pass;
- (void) requestSaveMnemonicCode;
- (void) requestGetMnemonicCode;

- (void) handleLoginResponse:(NSDictionary *) response withError:(NSError *) error ;
- (void) handleSaveMemonicCodeResponse:(NSDictionary *) Response withError:(NSError *) error ;
- (void) handleGetMemonicCodeResponse:(NSDictionary *) Response withError:(NSError *) error ;

- (void) handleResponse:(NSDictionary *) response withError:(NSError *) error ;

- (void) sendRequest:(NSString *) urlString withParams:(NSMutableDictionary *) distParams;
- (void) showToastMessage:(NSString * _Nonnull) message withDuration:(float) duration;

typedef enum RequestStateTypes
{
    RT_NONE,
    RT_LOGIN,
    RT_SAVE_MNEMONIC_CODE,
    RT_GET_MNEMONIC_CODE
} RequestType;

@end
