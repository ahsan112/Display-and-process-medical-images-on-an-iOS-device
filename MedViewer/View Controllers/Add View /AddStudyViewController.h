//
//  AddStudyViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 13/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddStudyViewControllerDelegate <NSObject>

- (void)download: (NSString *)URL;

@end


@interface AddStudyViewController : UIViewController


@property(nonatomic,weak) id <AddStudyViewControllerDelegate> addStudyDelegate;
@property(nonatomic)UINavigationController *controller;

@end
