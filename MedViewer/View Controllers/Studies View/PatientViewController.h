//
//  PatientViewController.h
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddStudyViewController.h"
#import "SWTableViewCell.h"
#import "FCAlertView.h"
#import <MessageUI/MessageUI.h>
@class DicomDecoder;

//deletage methods
@protocol PatientViewController <NSObject>

- (void)decodeAndDisplay:(NSString *)path;
- (void)setTitleWithPath:(NSString *)title;
- (void)reloadData;
@end

@interface PatientViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,AddStudyViewControllerDelegate,SWTableViewCellDelegate,FCAlertViewDelegate,MFMailComposeViewControllerDelegate,UISearchBarDelegate, UISearchControllerDelegate,UISearchResultsUpdating>

// create refrence to delegate
@property(nonatomic,assign) id <PatientViewController> patientDelegate;

@end
