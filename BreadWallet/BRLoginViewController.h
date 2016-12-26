//
//  BRLoginViewController.h
//  LoafWallet
//
//  Created by BapVn on 12/22/16.
//  Copyright © 2016 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRLoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textUserName;
@property (weak, nonatomic) IBOutlet UITextField *textPass;

@end
