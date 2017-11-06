//
//  PasswordViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 03/04/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "PasswordViewController.h"
#import <VENTouchLock/VENTouchLock.h>

@interface PasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@end

@implementation PasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.touchIDButton.hidden = ![VENTouchLock shouldUseTouchID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (instancetype)init {
    
    
    self = [super init];
    
    if (self) {
        self.didFinishWithSuccess = ^(BOOL success, VENTouchLockSplashViewControllerUnlockType unlockType) {
            if (success) {
                NSString *logString = @"Sample App Unlocked";
                switch (unlockType) {
                    case VENTouchLockSplashViewControllerUnlockTypeTouchID: {
                        logString = [logString stringByAppendingString:@" with Touch ID."];
                        break;
                    }
                    case VENTouchLockSplashViewControllerUnlockTypePasscode: {
                        logString = [logString stringByAppendingString:@" with Passcode."];
                        break;
                    }
                    default:
                        break;
                }
                NSLog(@"%@", logString);
                
            }
            
            else {
                [[[UIAlertView alloc] initWithTitle:@"Limit Exceeded"
                                            message:@"You have exceeded the maximum number of passcode attempts"
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
        };
    }
    
    return self;
}


- (IBAction)userTappedShowTouchID:(id)sender
{
    [self showTouchID];
}

- (IBAction)userTappedEnterPasscode:(id)sender
{
    [self showPasscodeAnimated:YES];
}









@end
