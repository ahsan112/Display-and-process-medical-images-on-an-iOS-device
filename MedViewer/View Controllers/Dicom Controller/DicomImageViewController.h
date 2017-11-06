//
//  DicomImageViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 07/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopOverTableViewController.h"
#import "IMPopOverTableViewController.h"
@interface DicomImageViewController : UIViewController <viewPopDelegate,windowPopover>

@property(nonatomic)NSString *imagePath;
@property(nonatomic)NSString *fullPath;
@property(nonatomic)NSUInteger imageNum;

@end
