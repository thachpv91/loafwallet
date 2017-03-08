//
//  BRLoginViewController.m
//  LoafWallet
//
//  Created by BapVn on 12/22/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
// https://cacoo.com/diagrams/90FHjt0JlSdhQg4L-A1FBF.png

#import "BRLoginViewController.h"
#import "BRWalletManager.h"
#import "BRLoginResponse.h"
#import "BRSaveMnemonicCodeResponse.h"
#import "BRSettingsViewController.h"
#import "BRPeerManager.h"

#import "Reachability.h"
#import "NSString+EmailValidation.h"
#define MIN_PASS_LENGTH 4
#define MIN_USER_NAME_LENGTH 4

@interface BRLoginViewController ()

@property (nonatomic) RequestType currentRequestType;

@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, strong) id reachabilityObserver;

@property (nonatomic, strong) id protectedObserver;

@property (nonatomic, weak) IBOutlet UIButton *resetPassButton;
@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinnerForgotPass;

@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textPass.delegate = self;
    self.textUserName.delegate = self;
    
    
    self.forgotPassViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgotPassViewController"];
    UIViewController *c = (UIViewController *)self.forgotPassViewController;
    
    self.emailTextField  = (id)[c.view viewWithTag:1];
    self.emailTextField.delegate = self;
    
    self.resetPassButton = (id)[c.view viewWithTag:2];
    [self.resetPassButton addTarget:self action:@selector(requestResetPass:) forControlEvents:UIControlEventTouchUpInside];
    self.resetPassButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.spinnerForgotPass =  (id)[c.view viewWithTag:3];
    
    
    _currentRequestType = RT_NONE;
    
    self.reachabilityObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil
            usingBlock:^(NSNotification *note) {
                if (self.reachability.currentReachabilityStatus == NotReachable)
                {
                  //  [self showToastMessage:@"No connection" withDuration:1.0f];
                }
                else if ( [UIApplication sharedApplication].applicationState != UIApplicationStateBackground)
                {
                   // [self showToastMessage:@"Connected" withDuration:1.0f];
                }
            }];
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];

}
- (void)viewDidAppear:(BOOL)animated
{
    if (! self.protectedObserver) {
        self.protectedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationProtectedDataDidBecomeAvailable object:nil queue:nil usingBlock:^(NSNotification *note) {
            [self performSelector:@selector(protectedViewDidAppear) withObject:nil afterDelay:0.0];
        }];
    }
    
    if ([UIApplication sharedApplication].protectedDataAvailable) {
        [self performSelector:@selector(protectedViewDidAppear) withObject:nil afterDelay:0.0];
    }
    
    self.resetPassButton.enabled = YES;
    self.resetPassButton.alpha = 1.0f;
    [super viewDidAppear:animated];
}
- (void)protectedViewDidAppear
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    if (self.protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.protectedObserver];
    self.protectedObserver = nil;
    
    if ([defs integerForKey:SETTINGS_MAX_DIGITS_KEY] == 5) {
        manager.format.currencySymbol = @"m" BTC NARROW_NBSP;
        manager.format.maximumFractionDigits = 5;
        manager.format.maximum = @((MAX_MONEY/SATOSHIS)*1000);
    }
    else if ([defs integerForKey:SETTINGS_MAX_DIGITS_KEY] == 8) {
        manager.format.currencySymbol = BTC NARROW_NBSP;
        manager.format.maximumFractionDigits = 8;
        manager.format.maximum = @(MAX_MONEY/SATOSHIS);
    }
    
    if (manager.noWallet) {
        if (! manager.passcodeEnabled) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"turn device passcode on", nil)
                                        message:NSLocalizedString(@"\nA device passcode is needed to safeguard your wallet. Go to settings and "
                                                                  "turn passcode on to continue.", nil)
                                       delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"close app", nil), nil] show];
        }
        manager.isFirtLauch = YES;
        manager.didAuthenticate = YES;
    }else
    {
        manager.isFirtLauch = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginClick:(id)sender {
    
    
    NSLog(@"loginClick self.reachability.currentReachabilityStatus = %ld", (long)self.reachability.currentReachabilityStatus);
    self.loginButton.enabled = NO;
    self.loginButton.alpha = 0.5f;
    
//    if(self.reachability.currentReachabilityStatus == NotReachable)
//    {
//        [self showToastMessage:@"No connection" withDuration:0.5f];
//        return;
//    }
    // check login here
    self._userName = self.textUserName.text;
    self._passWord = self.textPass.text;
    
    if( [self checkLoginField])
        [self requestLogin: self._userName withPass:self._passWord];
    
    
    // NSUInteger fieldHash = [self.textPass.text hash];
    //self._passWord = [NSString stringWithFormat:(@"%lu"), (unsigned long)fieldHash];

    
}
- (IBAction)forgotPasswordClick:(id)sender {
    

    if(self.textUserName.text.length > 0) self.emailTextField.text = self.textUserName.text;
    [self.emailTextField becomeFirstResponder];
    
    [self.navigationController pushViewController:self.forgotPassViewController animated:YES];
 
}
- (void) finishedLogin
{
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_IS_LOGGED];
    [[NSUserDefaults standardUserDefaults] setObject:self._userName forKey:USER_DEFAULTS_USENAME];
    [[NSUserDefaults standardUserDefaults] setObject:self._passWord forKey:USER_DEFAULTS_PASSWORD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self.navigationController.presentingViewController
         dismissViewControllerAnimated:NO completion:nil];
    });
}
- (void) requestLogin:(NSString *)userName withPass:(NSString *)pass
{
    _currentRequestType = RT_LOGIN;

    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    postDict[@"email"] = userName;
    postDict[@"password"] = pass;

    NSString *urlString =  [NSString stringWithFormat:BASE_URL@"/%@", BAP_API_LOGIN];//

    [self sendRequest:urlString withParams:postDict];
    
}
- (void) requestSaveMnemonicCode:(NSString *) mnemonicCode
{
    _currentRequestType = RT_SAVE_MNEMONIC_CODE;
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    postDict[@"email"] = self._userName;
    postDict[@"password"] = self._passWord;
    postDict[@"payment_address"] = manager.wallet.receiveAddress;
    postDict[@"mnemonic_code"] = mnemonicCode;
    postDict[@"authen_key"] = manager.authenKey;

    NSString *urlString =  [NSString stringWithFormat:BASE_URL@"/%@", BAP_API_SET_MNEMONIC_CODE];//
    
    [self sendRequest:urlString withParams:postDict];
    
}
- (void) requestResetPass:(id)sender
{
    [self.emailTextField resignFirstResponder];
    NSString * email = self.emailTextField.text;
    
    if(![self checkResetPassField]) return;
    
    _currentRequestType = RT_RESET_PASSWORD;
    
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    postDict[@"email"] = email;
    
    NSString *urlString =  [NSString stringWithFormat:BASE_URL@"/%@", BAP_API_RESET_PASS];//
    
    [self sendRequest:urlString withParams:postDict];
    
    self.resetPassButton.enabled = NO;
    self.resetPassButton.alpha = 0.5f;

}
- (void) handleResponse:(NSDictionary *) response withError:(NSError *) error
{
    switch (_currentRequestType) {
        case RT_LOGIN:
             [self handleLoginResponse:response withError:error];
            break;
        case RT_SAVE_MNEMONIC_CODE:
            [self handleSaveMemonicCodeResponse:response withError:error];
            break;
        case RT_RESET_PASSWORD:
             [self handleResetPassResponse:response withError:error];
             break;
        default:
            break;
    }
}
- (void) sendRequest:(NSString *) urlString withParams:(NSMutableDictionary *) distParams
{
    [self showSpinnerLoading];
    
    NSError *error;
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:distParams options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:requestBodyData];
    request.timeoutInterval = 10.0;
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
    
}
- (void) handleLoginResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\n Login: handleLoginResponse %@ %@", response, error);

    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRLoginResponse * loginResponse = [[BRLoginResponse alloc] initWithDictionary:response];
    
    if(error || loginResponse.responseType == RESPONSE_TYPE_ERROR)
    {
        
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Login failed!", nil)
          message:error?error.userInfo[@"NSDebugDescription"]:
          loginResponse.response
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"ok", nil)
          otherButtonTitles:Nil, nil]
         show];
        self.textPass.text = @"";
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0f;
        return;
    }
    
//    [self showToastMessage:@"Login successful" withDuration:0.5f];
    
    manager.authenKey = loginResponse.authenKey;
    if(loginResponse.isFirstLogin)
    {
            NSLog(@" Login: handleLoginResponse: Login isFirstLogin = TRUE --> Create Wallet ");
             // create wallet
            NSString * seedPhrase = [manager generateRandomSeed];
        
            [[BRPeerManager sharedInstance] connect];
            
            // save MnemonicCode to server
            NSLog(@" Login: handleLoginResponse: Request to save Mnemonic Code");
             [self requestSaveMnemonicCode:seedPhrase];
        
    }else
    {
//        if(manager.isFirtLauch)
//        {
                [manager setServerSaveMnemonic:YES];
                NSLog(@"Login: handleLoginResponse: Restore from Server`s MnenicCode ");
                // Resore wallet
                @autoreleasepool {  // @autoreleasepool ensures sensitive data will be deallocated immediately
                    NSString * mnemonicCode = loginResponse.response;
                    
                    NSString * phrase = [manager.mnemonic cleanupPhrase:mnemonicCode];
                    phrase = [manager.mnemonic normalizePhrase:phrase];
                    
                    manager.seedPhrase = phrase;
                    
                    [[BRPeerManager sharedInstance] connect];

                }
           
//        }else
//        {
//                 NSLog(@" Login: handleLoginResponse: Login ok, show Wallet");
//
//        }

        [self finishedLogin];
        
     
    }
}
- (void) handleSaveMemonicCodeResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\n Login: handleSaveMemonicCodeResponse %@ %@", response, error);
    
     BRSaveMnemonicCodeResponse * saveMCResponse = [[BRSaveMnemonicCodeResponse alloc] initWithDictionary:response];
    
    if(error || saveMCResponse.responseType == RESPONSE_TYPE_ERROR)
    {
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Syncing account failed!", nil)
          message:error?error.userInfo[@"NSDebugDescription"]:saveMCResponse.response
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"ok", nil)
          otherButtonTitles:Nil, nil]
         show];
    }else
    {
         BRWalletManager *manager = [BRWalletManager sharedInstance];
        [manager setServerSaveMnemonic:YES];
        
        
        [self finishedLogin];
    }

}
- (void) handleResetPassResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\n Login: handleResetPassResponse %@ %@", response, error);
    
    BRResponse * resetPassResponse = [[BRResponse alloc] initWithDictionary:response];
    
    if(error || resetPassResponse.responseType == RESPONSE_TYPE_ERROR)
    {
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"Failed!", nil)
          message:error?error.userInfo[@"NSDebugDescription"]:resetPassResponse.response
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"try again", nil)
          otherButtonTitles:Nil, nil]
         show];
        
        [self.emailTextField becomeFirstResponder];
        self.resetPassButton.enabled = YES;
        self.resetPassButton.alpha = 1.0f;
        
        
        return;
    }

    //  [self showToastMessage:resetPassResponse.response withDuration:0.5f];
            
    [[[UIAlertView alloc]
              initWithTitle:NSLocalizedString(@"Successful!", nil)
              message:resetPassResponse.response
              delegate:self
              cancelButtonTitle:NSLocalizedString(@"ok", nil)
              otherButtonTitles:Nil, nil]
             show];
    
    [self.textPass becomeFirstResponder];
    self.textPass.text = @"";
    self.loginButton.enabled = YES;
    self.loginButton.alpha = 1.0f;
    
    // [self.navigationController popViewControllerAnimated:NO];

}
/*
#pragma mark - Navigation
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@" Login: didFailWithError %@", error);
    [self showSpinnerLoading];
    if(error.code == NSURLErrorTimedOut)
    {
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"WARNING", nil)
          message:NSLocalizedString(@"Connect timeout!", nil)
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"try again", nil)
          otherButtonTitles:NSLocalizedString(@"close app", nil), nil]
          show];
        return;
    }
    
    if(_currentRequestType == RT_LOGIN || _currentRequestType == RT_RESET_PASSWORD)
    {
        [self hideSpinnerLoading];
        [self showToastMessage: error.userInfo[@"NSLocalizedDescription"]
                  withDuration: 1.5f];
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0f;
        
        self.resetPassButton.enabled = YES;
        self.resetPassButton.alpha = 1.0f;
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSError *error;
    NSDictionary *receivedDictionary = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingAllowFragments error:&error];
    if ([receivedDictionary isKindOfClass:[NSString class]]) {
        NSString * receivedString = [NSString stringWithFormat:@"%@", receivedDictionary];
        NSData *jsonData = [receivedString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        receivedDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    }
    NSLog(@"Login: %@",receivedDictionary);
    
    [self handleResponse:receivedDictionary withError:error];
    
    connection = nil;
    _responseData = nil;
    [self hideSpinnerLoading];
}
- (void)dealloc
{
    [self.reachability stopNotifier];
    
    if (self.protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.protectedObserver];
    if (self.reachabilityObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.reachabilityObserver];

}
// MARK: - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"ok", nil)])
    {
        self.loginButton.enabled = YES;
        self.loginButton.alpha = 1.0f;
        if(_currentRequestType == RT_LOGIN || _currentRequestType == RT_SAVE_MNEMONIC_CODE)
        {
            [self.textUserName becomeFirstResponder];
        }
        else if (_currentRequestType == RT_RESET_PASSWORD )
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return;
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"try again", nil)])
    {
        [self hideSpinnerLoading];
        self.loginButton.alpha = 1.0f;
        self.loginButton.enabled = true;
        if(_currentRequestType == RT_SAVE_MNEMONIC_CODE)
        {
            // Try request to save mnemonic Code
            NSString * mnemonicCode = manager.seedPhrase;
            [self requestSaveMnemonicCode:mnemonicCode];
        }
        else if (_currentRequestType == RT_RESET_PASSWORD)
        {
            self.resetPassButton.enabled = YES;
            self.resetPassButton.alpha = 1.0f;
        }
        return;
    }
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"close app", nil)])
    {
        [manager deleteWallet];
        exit(0);
    }



}
- (void) showToastMessage:(NSString *) message withDuration:(float) duration
{
    UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    [toast show];
    
    int64_t time = duration * NSEC_PER_SEC;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, time), dispatch_get_main_queue(), ^{
        [toast dismissWithClickedButtonIndex:0 animated:YES];
    });
}

-(void) showSpinnerLoading
{
    if(self.currentRequestType == RT_RESET_PASSWORD)
    {
        [self.spinnerForgotPass startAnimating];
    }else
    {
        [self.spinner startAnimating];
    }
}
-(void) hideSpinnerLoading
{
    if(self.currentRequestType == RT_RESET_PASSWORD)
    {
        [self.spinnerForgotPass stopAnimating];
    }else
    {
        [self.spinner stopAnimating];
    }
}
-(bool)checkLoginField
{
    bool result = true;
    NSString * message;
    if(self._userName.length <=0)
    {
        result = false;
        message = NSLocalizedString(@"user name is empty!", nil);
    }else if(![self._userName isValidEmail])
        {
            result = false;
            message = NSLocalizedString(@"This email address is invalid!", nil);
        }else if(self._passWord.length <= 0)
    {
        result = false;
        message = NSLocalizedString(@"password is empty", nil);
    }else if(self._passWord.length <= MIN_PASS_LENGTH)
    {
        result = false;
        message = NSLocalizedString(@"This password is too short", nil);
    }
    if(!result)
    {
        [[[UIAlertView alloc]
                initWithTitle:NSLocalizedString(@"WARNING", nil)
                      message:message
                     delegate:self
            cancelButtonTitle:NSLocalizedString(@"ok", nil)
            otherButtonTitles:Nil, nil]
            show];
    }
    
    return result;
}
-(bool)checkResetPassField
{
    bool result = true;
    NSString * email = self.emailTextField.text;
    NSString * message;
    if(email.length <=0)
    {
        result = false;
        message = NSLocalizedString(@"email address is empty!", nil);
    }
    if(![email isValidEmail])
    {
        result = false;
        message = NSLocalizedString(@"This email address is invalid!", nil);
    }
    
    if(!result)
    {
        [[[UIAlertView alloc]
          initWithTitle:NSLocalizedString(@"WARNING", nil)
          message:message
          delegate:self
          cancelButtonTitle:NSLocalizedString(@"ok", nil)
          otherButtonTitles:Nil, nil]
         show];
    
    }
    
    return result;
}
@end

//if (self.navigationController.presentingViewController) {
//    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//}
//else [self.navigationController popViewControllerAnimated:NO];
