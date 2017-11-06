//
//  DicomFourViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DicomFourViewController : UIViewController
@property (nonatomic) NSString             *path;
@property (nonatomic) NSString             *fullPath;

@property (nonatomic) NSString             *view1Path;
@property (nonatomic) NSString             *view2Path;
@property (nonatomic) NSString             *view3Path;
@property (nonatomic) NSString             *view4Path;

@property (nonatomic)NSInteger        imageNum;

@property (nonatomic) UINavigationBar      *navBar;
@end
