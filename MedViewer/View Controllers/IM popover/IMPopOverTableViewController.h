//
//  IMPopOverTableViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 13/04/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol windowPopover

- (void) displayW:(NSInteger)windowW windowCenter:(NSInteger)windowC;
- (void)reset;
@end

@interface IMPopOverTableViewController : UITableViewController

@property (nonatomic, assign) id <windowPopover>windowPopoverDelegate;

@end
