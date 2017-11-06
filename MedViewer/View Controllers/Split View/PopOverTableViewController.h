//
//  PopOverTableViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol viewPopDelegate <NSObject>

- (void)twoSplitView;
- (void)endSplitView;
- (void)threeSplit;
- (void)fourSplitView;

@end

@interface PopOverTableViewController : UITableViewController

@property (nonatomic, assign) id <viewPopDelegate>popDelgate;

@end
