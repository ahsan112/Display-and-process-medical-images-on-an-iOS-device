//
//  ViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 28/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientViewController.h"
#import "SWTableViewCell.h"
#import <MessageUI/MessageUI.h>

@interface MainViewController : UIViewController <UISplitViewControllerDelegate,PatientViewController, UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,FCAlertViewDelegate,MFMailComposeViewControllerDelegate>


@end

