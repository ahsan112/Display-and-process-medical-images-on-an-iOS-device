//
//  AddStudyViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 13/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "AddStudyViewController.h"

@interface AddStudyViewController ()

@property(nonatomic)UITextField *URLTextField;

@end

@implementation AddStudyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createTextField];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // creating the bar button for adding and canceling
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(add)];

    //setting the bar button items to the nav bar
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.title = @"Downlaod Study";
    
    // condition to check if the textfeild is empty to disable the add button
//    if ([_URLTextField.text length] == 0) {
//        leftButton.enabled = NO;
//    }
//    else if ([_URLTextField.text length] != 0) {
//        leftButton.enabled = YES;
//    }
//    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



// method called to dismiss the view controller
- (void)dismiss {
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
}

// method called to pass the text in the textfield to the delegate method
- (void)add {
    
    [self.addStudyDelegate download:_URLTextField.text];
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
    
}


// creating the textfield
- (void)createTextField {
    
    _URLTextField= [[UITextField alloc]initWithFrame:CGRectMake(40, 100, 460, 45)];
    //_URLTextField.backgroundColor = [UIColor redColor];
    _URLTextField.placeholder = @"URL";
    
    _URLTextField.borderStyle = UITextBorderStyleRoundedRect;
    _URLTextField.font = [UIFont systemFontOfSize:15];
    //_URLTextField.placeholder = @"enter text";
    _URLTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _URLTextField.keyboardType = UIKeyboardTypeDefault;
    _URLTextField.returnKeyType = UIReturnKeyDone;
    _URLTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _URLTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _URLTextField.layer.borderColor = [[UIColor grayColor]CGColor];
    _URLTextField.layer.borderWidth = 0.75f;
    [self.view addSubview:_URLTextField];
    
}

@end
