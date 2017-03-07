//
//  BRLoginViewController.h
//  LoafWallet
//
//  Created by BapVn on 12/22/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROTO @"https"
//#define HOST  @"192.168.0.118:3000/api/v1/user"
#define HOST  @"clover-miner.com/api/v1/user"
#define BASE_URL  PROTO@"://"HOST

#define BAP_API_LOGIN               @"login"
#define BAP_API_SET_MNEMONIC_CODE   @"set_mnemonic_code"
#define BAP_API_RESET_PASS          @"forgot_password"

@class BRForgotPassViewController;

@interface BRLoginViewController : UIViewController<UIAlertViewDelegate,UITextFieldDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    NSMutableData *_responseData;

}
@property (weak, nonatomic) IBOutlet UITextField *textUserName;
@property (weak, nonatomic) IBOutlet UITextField *textPass;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, copy) NSString * _Nullable _userName; // requesting seedPhrase will trigger
@property (nonatomic, copy) NSString * _Nullable _passWord;

@property (nonatomic, strong) IBOutlet BRForgotPassViewController * forgotPassViewController;

- (void) requestLogin:(NSString * _Nonnull)userName withPass:(NSString * _Nonnull)pass;
- (void) requestSaveMnemonicCode;
- (void) requestResetPass:(id)sender;
- (void) finishedLogin;

- (void) handleLoginResponse:(NSDictionary *) response withError:(NSError *) error ;
- (void) handleSaveMemonicCodeResponse:(NSDictionary *) response withError:(NSError *) error ;
- (void) handleResetPassResponse:(NSDictionary *) response withError:(NSError *) error ;

- (void) handleResponse:(NSDictionary *) response withError:(NSError *) error ;

- (void) sendRequest:(NSString *) urlString withParams:(NSMutableDictionary *) distParams;
- (void) showToastMessage:(NSString * _Nonnull) message withDuration:(float) duration;

-(void) showSpinnerLoading;
-(void) hideSpinnerLoading;

-(bool)checkLoginField;
-(bool)checkResetPassField;

typedef enum RequestStateTypes
{
    RT_NONE,
    RT_LOGIN,
    RT_SAVE_MNEMONIC_CODE,
    RT_RESET_PASSWORD
} RequestType;

@end
