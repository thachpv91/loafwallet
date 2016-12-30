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

@interface BRLoginViewController ()

@property (nonatomic, assign) RequestType currentRequestType;

@property (nonatomic, strong) id protectedObserver;
@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textPass.delegate = self;
    self.textUserName.delegate = self;

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
    
    // check login here
    self._userName = self.textUserName.text;
    self._passWord = self.textPass.text;

    [self requestLogin: self._userName withPass:self._passWord];
    
}
- (void) requestLogin:(NSString *)userName withPass:(NSString *)pass
{
    _currentRequestType = REQUEST_LOGIN;

    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    postDict[@"email"] = userName;
    postDict[@"password"] = pass;

    NSString *urlString =  [NSString stringWithFormat:BASE_URL@"/%@", BAP_API_LOGIN];//

    [self sendRequest:urlString withParams:postDict];
    
}
- (void) requestSaveMnemonicCode:(NSString *) mnemonicCode
{
    _currentRequestType = REQUEST_SAVE_MEMONIC_CODE;
    
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
- (void) requestGetMemonicCode
{
   _currentRequestType = REQUEST_GET_MEMONIC_CODE;
}
- (void) handleResponse:(NSDictionary *) response withError:(NSError *) error
{
    switch (_currentRequestType) {
        case REQUEST_LOGIN:
             [self handleLoginResponse:response withError:error];
            break;
        case REQUEST_GET_MEMONIC_CODE:
            [self handleGetMemonicCodeResponse:response withError:error];
            break;
        case REQUEST_SAVE_MEMONIC_CODE:
            [self handleSaveMemonicCodeResponse:response withError:error];
            break;
        default:
            break;
    }
}
- (void) sendRequest:(NSString *) urlString withParams:(NSMutableDictionary *) distParams
{
    NSError *error;
    
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:distParams options:NSJSONWritingPrettyPrinted error:&error];
    
    NSLog(@"sendRequest: error = %@", error);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:requestBodyData];
    //request.timeoutInterval = 10.0;
    
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection start];
    
}
- (void) handleLoginResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\nhandleLoginResponse %@ %@", response, error);

    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRLoginResponse * loginResponse = [[BRLoginResponse alloc] initWithDictionary:response];
    
    NSLog(@"handleLoginResponse: Login isSuccess = %d", (int)loginResponse.responceType);
    if(loginResponse.responceType == RESPONSE_TYPE_SUCCESS)
    {
        manager.authenKey = loginResponse.authenKey;
        if(loginResponse.isFirstLogin)
        {
            NSLog(@"handleLoginResponse: Login isFirstLogin = TRUE --> Create Wallet ");
             // create wallet
            NSString * seedPhrase = [manager generateRandomSeed];
            
            
            NSLog(@"BRSeedViewController customInit .. [BRPeerManager sharedInstance] connect");
            [[BRPeerManager sharedInstance] connect];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:WALLET_NEEDS_BACKUP_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // save MnemonicCode to server
            NSLog(@"handleLoginResponse: Request to save Mnemonic Code");
            [self requestSaveMnemonicCode:seedPhrase];
            
            // Todo: While response here
            // Todo: Show loading animation
        }else
        {
            if(manager.isFirtLauch)
            {
                NSLog(@"handleLoginResponse: Restore from Server`s MnenicCode ");
                // Resore wallet
                @autoreleasepool {  // @autoreleasepool ensures sensitive data will be deallocated immediately
                    NSString * mnemonicCode = loginResponse.response;
                    
                    NSString * phrase = [manager.mnemonic cleanupPhrase:mnemonicCode];
                    phrase = [manager.mnemonic normalizePhrase:phrase];
                    
                    manager.seedPhrase = phrase;
                    
                    [self.navigationController popViewControllerAnimated:NO];
                }
           
            }else
            {
                 NSLog(@"handleLoginResponse: Login ok, show Wallet");
                // Show wallet
                // Todo: pop view here
                 [self.navigationController popViewControllerAnimated:NO];
            }
        }
    }else
    {
        self.textUserName.text = @"";
        self.textPass.text = @"";
        
        [self.textUserName becomeFirstResponder];
    }

}
- (void) handleSaveMemonicCodeResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\nhandleSaveMemonicCodeResponse %@ %@", response, error);
    
    if(!error)
    {
        BRSaveMnemonicCodeResponse * saveMCResponse = [[BRSaveMnemonicCodeResponse alloc] initWithDictionary:response];
        NSLog(@"handleSaveMemonicCodeResponse %d  %@", saveMCResponse.responceType, saveMCResponse.response);
        
        if(saveMCResponse.responceType == RESPONSE_TYPE_SUCCESS)
        {
            [self.navigationController popViewControllerAnimated:NO];
        }else
        {
             // Try to save Mnemonic code again
             NSLog(@" handleSaveMemonicCodeResponse isSuccess = false");
             NSLog(@" handleSaveMemonicCodeResponse ErrMesssage = %@", saveMCResponse.response);
        }

    }
}
- (void) handleGetMemonicCodeResponse:(NSDictionary *) response withError:(NSError *) error
{
    NSLog(@"\nhandleGetMemonicCodeResponse %@ %@", response, error);
}
/*
#pragma mark - Navigation
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    NSLog(@"%@",receivedDictionary);
    
    [self handleResponse:receivedDictionary withError:error];
    
    connection = nil;
    _responseData = nil;
}
- (void)dealloc
{
    if (self.protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.protectedObserver];
}
// MARK: - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqual:NSLocalizedString(@"close app", nil)]) exit(0);
}
@end
