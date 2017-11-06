//
//  DicomSplitViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DicomSplitViewController : UIViewController

@property (nonatomic)NSString        *path;
@property (nonatomic)NSString        *fullPath;

@property (nonatomic)NSString        *view1Path;
@property (nonatomic)NSString        *view2Path;

@property (nonatomic)NSString        *fullView1Path;
@property (nonatomic)NSString        *fullView2Path;

@property (nonatomic)NSInteger        imageNum;
@property (nonatomic)NSInteger        imageNum2;

@property (nonatomic)UINavigationBar *navBar;

@property (nonatomic)UITapGestureRecognizer *tapGesture;

@end
