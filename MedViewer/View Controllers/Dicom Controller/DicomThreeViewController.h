//
//  DicomThreeViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DicomThreeViewController : UIViewController

@property (nonatomic)NSString        *path;
@property (nonatomic)NSString        *fullPath;

@property (nonatomic)NSString        *view1Path;
@property (nonatomic)NSString        *view2Path;
@property (nonatomic)NSString        *view3Path;

@property (nonatomic)NSString        *fullPathView1;
@property (nonatomic)NSString        *fullPathView2;
@property (nonatomic)NSString        *fullPathView3;

@property (nonatomic)NSInteger        imageNum;
@property (nonatomic)NSInteger        imageNum2;
@property (nonatomic)NSInteger        imageNum3;

@property (nonatomic)UINavigationBar *navBar;

@end
