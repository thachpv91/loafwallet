//
//  BRLoginViewController.m
//  LoafWallet
//
//  Created by BapVn on 12/22/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import "BRLoginViewController.h"
#import "BRWalletManager.h"
@interface BRLoginViewController ()

@end

@implementation BRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textPass.delegate = self;
    self.textUserName.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginClick:(id)sender {
    
    // check login here
    NSString * UserName = self.textUserName.text;
    NSString * Pass = self.textPass.text;
    
    NSLog(@"Username: %@ - Pass: %@", UserName, Pass);
    
    [self.navigationController popViewControllerAnimated:NO];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
