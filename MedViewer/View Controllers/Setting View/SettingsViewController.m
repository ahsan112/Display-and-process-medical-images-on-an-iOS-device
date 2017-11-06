//
//  SettingsViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 03/04/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "SettingsViewController.h"
#import <VENTouchLock/VENTouchLock.h>
#import "SSBouncyButton.h"
#import "FCAlertView.h"
@interface SettingsViewController ()

@property(nonatomic)UISwitch *touchIDSwitch;
@property(nonatomic)UILabel  *touchIDLabel;

@property(nonatomic)SSBouncyButton *setPasswordButton;
@property(nonatomic)SSBouncyButton *deleteButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Settings";
    [self createButtons];
    [self setup];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self configureTouchIDToggle];
}



- (IBAction)userTappedSetPasscode:(id)sender {
    
    
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertInView:self
                     withTitle:@"Password Already Set"
                  withSubtitle:@"Delete password to create a new one"
               withCustomImage:nil
           withDoneButtonTitle:nil // @"No"
                    andButtons:nil];
        [alert makeAlertTypeCaution];
        
        _deleteButton.selected = NO;
        _setPasswordButton.selected = YES;
    }
    
    
    else {
        VENTouchLockCreatePasscodeViewController *createPasscodeVC = [[VENTouchLockCreatePasscodeViewController alloc] init];
        [self presentViewController:[createPasscodeVC embeddedInNavigationController] animated:YES completion:nil];
        _deleteButton.selected = NO;
        _setPasswordButton.selected = YES;
    }
    
}



- (IBAction)userTappedDeletePasscode:(id)sender {
    
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        [[VENTouchLock sharedInstance] deletePasscode];
        [self configureTouchIDToggle];
        _deleteButton.selected = YES;
        _setPasswordButton.selected = NO;
    }
    else {
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertInView:self
                     withTitle:@"Password Deleted"
                  withSubtitle:@"Password has been delelted or does not exist"
               withCustomImage:nil
           withDoneButtonTitle:nil // @"No"
                    andButtons:nil];
        [alert makeAlertTypeCaution];
        _deleteButton.selected = YES;
        _setPasswordButton.selected = NO;
    }
    
    
}


- (IBAction)userTappedSwitch:(UISwitch *)toggle {
    [VENTouchLock setShouldUseTouchID:toggle.on];
    
}


- (void)configureTouchIDToggle {
    self.touchIDSwitch.enabled = [[VENTouchLock sharedInstance] isPasscodeSet] && [VENTouchLock canUseTouchID];
    self.touchIDSwitch.on = [VENTouchLock shouldUseTouchID];
}


- (void)dismiss {
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}



- (void)createButtons {
    
    _setPasswordButton = [[SSBouncyButton alloc]initWithFrame:CGRectMake(150, 150, 200, 45)];

    [_setPasswordButton setTitle:@"Set Password" forState:UIControlStateNormal];
    [_setPasswordButton setTitle:@"Password Set" forState:UIControlStateSelected];
    [_setPasswordButton addTarget:self action:@selector(userTappedSetPasscode:) forControlEvents:UIControlEventTouchUpInside];
    [_setPasswordButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.view addSubview:_setPasswordButton];
    
    
    
    _deleteButton = [[SSBouncyButton alloc]initWithFrame:CGRectMake(150, 250, 200, 45)];
    [_deleteButton setTitle:@"Delete Password" forState:UIControlStateNormal];
    [_deleteButton setTitle:@"Deleted" forState:UIControlStateSelected];
    [_deleteButton setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(userTappedDeletePasscode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteButton];
    
    
    
    _touchIDLabel = [[UILabel alloc]init];
    _touchIDLabel.frame = CGRectMake(150, 350, 100, 40);
    _touchIDLabel.text = @"Use TouchID";
    [self.view addSubview:_touchIDLabel];
    
    _touchIDSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(300, 350, 250 , 25)];
    [_touchIDSwitch addTarget:self action:@selector(userTappedSwitch:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_touchIDSwitch];
    
    

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    self.navigationItem.rightBarButtonItem = rightButton;

}


- (void)setup {
    
    if ([[VENTouchLock sharedInstance] isPasscodeSet]) {
        _deleteButton.selected = NO;
        _setPasswordButton.selected = YES;
    }
    
    else {
        
        _deleteButton.selected = YES;
        _setPasswordButton.selected = NO;
    }
    
}

@end
