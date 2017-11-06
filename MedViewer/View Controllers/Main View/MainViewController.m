//
//  ViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 28/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "MainViewController.h"
#import "Dicom2DView.h"
#import "DicomDecoder.h"
#import "StudyLibary.h"
#import "SWTableViewCell.h"
#import "SSZipArchive.h"
#import "DicomImageViewController.h"
#import "DicomSplitViewController.h"
#import "DicomThreeViewController.h"
#import "DicomFourViewController.h"

#define desc_TAG 1
#define date_TAG 2
#define Mod_TAG 3
#define IMG_Count_TAG 4
#define bod_Part_TAG 5
@interface MainViewController ()

//@property (weak, nonatomic) IBOutlet Dicom2DView *dicom2dView;
//@property (nonatomic) IBOutlet Dicom2DView *dicom2dView;

@property (nonatomic) DicomDecoder           *dicomDecoder;
@property (nonatomic) Dicom2DView            *dicom2dView;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGAffineTransform       prevTransform;
@property (nonatomic) CGPoint                 startPoint;

@property (nonatomic) UILabel *pNameLabel;
@property (nonatomic) UILabel *pNameL;

@property (nonatomic) UILabel *pIDLabel;
@property (nonatomic) UILabel *pIDL;

@property (nonatomic) UILabel *pSexLabel;
@property (nonatomic) UILabel *pSexL;

@property (nonatomic) UILabel *pBirthDateLabel;
@property (nonatomic) UILabel *pBirthDateL;

@property (nonatomic) UILabel *sDescLabel;
@property (nonatomic) UILabel *sDescL;

@property (nonatomic) UILabel *sModDateLabel;
@property (nonatomic) UILabel *sModDateL;

@property (nonatomic) UILabel *sModLabel;
@property (nonatomic) UILabel *sModL;

@property (nonatomic) UILabel *institutionNameL ;
@property (nonatomic) UILabel *institutionNameLabel;

@property (nonatomic) UILabel *referringPhysicianNameL;
@property (nonatomic) UILabel *referringPhysicianNameLabel;

@property (nonatomic) UILabel *performingPhysicianNameL;
@property (nonatomic) UILabel *performingPhysicianNameLabel;

@property (nonatomic) UILabel *totalL;
@property (nonatomic) UILabel *totalLabel;

@property (nonatomic)UIBarButtonItem *rightButton;

@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSString *path;
@property (nonatomic)SWTableViewCell *cCell;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createLabels];
    [self createTableView];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"uitableviewcell"];
    
    self.pNameL.text = @"Patient Name: ";
    self.pIDL.text = @"Patient ID: ";
    self.pSexL.text = @"Patient Sex: ";
    self.pBirthDateL.text = @"Pateint DOB: ";
    self.sModL.text = @"Modularity: ";
    self.sModDateL.text = @"Study Date: ";
    self.sDescL.text = @"Study Description: ";
    

    NSLog(@"%@",[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);

    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - TableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // if the path is a directory return the count of the files within it
    BOOL isDir;
    if([[NSFileManager defaultManager] fileExistsAtPath:_path isDirectory:&isDir] &&isDir){

        return [[[StudyLibary sharedInstance]getAllStudies:_path] count];

    }
    else{
        return 1;
    }
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"uitableviewcell" forIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
     UILabel *imageCountLabel, *modLabel, *descLabel, *dateLabel, *bodyPartLabel;
     UILabel *imageCountL, *modL, *descL, *dateL, *bodyPartL;
     Dicom2DView *dicomView;
    DicomDecoder *dicomDecoder;
    
    if (cell == nil) {
        
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        //cell.leftUtilityButtons = [self leftButtons];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        
        CGFloat size = 14;
        UIFont *boldFont = [UIFont boldSystemFontOfSize:size];
        
        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, -5.0, 320.0, 57.0)];
        descLabel.tag = desc_TAG;
        descLabel.font = boldFont;
        //mainLabel.textAlignment = UITextAlignmentRight;
        descLabel.textColor = [UIColor blackColor];
        //mainLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:descLabel];
        
        descL = [[UILabel alloc] initWithFrame:CGRectMake(150.0, -5.0, 320.0, 57.0)];
        descL.font = [UIFont systemFontOfSize:14.0];
        //mainLabel.textAlignment = UITextAlignmentRight;
        descL.textColor = [UIColor blackColor];
        descL.text = @"Desciption:";
        [cell.contentView addSubview:descL];
        
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 30.0, 320.0, 37.0)];
        dateLabel.tag = date_TAG;
        dateLabel.font = boldFont;
        dateLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:dateLabel];
        
        dateL = [[UILabel alloc] initWithFrame:CGRectMake(150.0, 30, 50, 37.0)];
        dateL.font = [UIFont systemFontOfSize:14.0];
        dateL.textColor = [UIColor blackColor];
        dateL.text = @"Date: ";
        [cell.contentView addSubview:dateL];
        
        
        modLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 53.0, 100, 37.0)];
        modLabel.tag = Mod_TAG;
        modLabel.font = boldFont;
        modLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:modLabel];
        
        modL = [[UILabel alloc] initWithFrame:CGRectMake(150.0, 53.0, 60.0, 37.0)];
        modL.font = [UIFont systemFontOfSize:14.0];
        modL.textColor = [UIColor blackColor];
        modL.text = @"Modality: ";
        [cell.contentView addSubview:modL];
        
        
        imageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 75.0, 100, 37.0)];
        imageCountLabel.tag = IMG_Count_TAG;
        imageCountLabel.font = boldFont;
        imageCountLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:imageCountLabel];
        
        imageCountL = [[UILabel alloc] initWithFrame:CGRectMake(150, 75.0, 70, 37.0)];
        imageCountL.font = [UIFont systemFontOfSize:14.0];
        imageCountL.textColor = [UIColor blackColor];
        imageCountL.text = @"Images: ";
        [cell.contentView addSubview:imageCountL];
        
        bodyPartL = [[UILabel alloc] initWithFrame:CGRectMake(350, 75.0, 70, 37.0)];
        bodyPartL.font = [UIFont systemFontOfSize:14.0];
        bodyPartL.textColor = [UIColor blackColor];
        bodyPartL.text = @"Body Part: ";
        [cell.contentView addSubview:bodyPartL];
        
        bodyPartLabel = [[UILabel alloc] initWithFrame:CGRectMake(420, 75.0, 100, 37.0)];
        bodyPartLabel.font = boldFont;
        bodyPartLabel.tag = bod_Part_TAG;
        [cell.contentView addSubview:bodyPartLabel];
        
        dicomDecoder = [[DicomDecoder alloc]init];
        
        dicomView = [[Dicom2DView alloc]init];
        dicomView.frame = CGRectMake(0, 0, 110, 110);
        [cell.contentView addSubview:dicomView];
        
        
    }
    
    else {
        descLabel = (UILabel *)[cell.contentView viewWithTag:desc_TAG];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:date_TAG];
        modLabel = (UILabel *)[cell.contentView viewWithTag:Mod_TAG];
        imageCountLabel = (UILabel *)[cell.contentView viewWithTag:IMG_Count_TAG];
        bodyPartLabel = (UILabel *)[cell.contentView viewWithTag:bod_Part_TAG];

        dicomDecoder = nil;
        dicomDecoder = [[DicomDecoder alloc]init];
        
        dicomView = nil;
        dicomView = [[Dicom2DView alloc]init];
        dicomView.frame = CGRectMake(0, 0, 110, 110);
        [cell.contentView addSubview:dicomView];
    }
    
    
        NSString *allpaths = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:indexPath.row];

        NSString *fullPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:allpaths pathIndex:0];

        [dicomDecoder setDicomFilename:fullPath];

        NSString * description = [dicomDecoder infoFor:STUDY_DESCRIPTION];
        NSString * modType = [dicomDecoder infoFor:MODALITY];
        NSString * date = [dicomDecoder infoFor:STUDY_DATE];
        NSString * bodPart = [dicomDecoder infoFor:BodyPartExamined];

        descLabel.text = description;
        modLabel.text = modType;
        dateLabel.text =  date;//[NSString stringWithFormat:@"%@",[dateFormat stringFromDate:dte]];
    
        NSString *im = [NSString stringWithFormat:@"%lu",(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:allpaths]count]];
        imageCountLabel.text = im;
        bodyPartLabel.text = bodPart;
        
        
        [self displayWith:dicomDecoder.windowWidth windowCenter:dicomDecoder.windowCenter with:dicomView];
    
    
    return cell;
    
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!_tableView.isEditing) {
        DicomImageViewController *dv = [[DicomImageViewController alloc]init];
        NSString *fullPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:indexPath.row];
        dv.imagePath = fullPath;
        dv.fullPath = _path;

        NSArray *p =  [[StudyLibary sharedInstance]getAllStudies:fullPath];
        dv.imageNum = [p count] -1;
        [self presentViewController:dv animated:YES completion:nil];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.indexPathsForSelectedRows.count == 2 && ![tableView.indexPathsForSelectedRows containsObject:indexPath]) {
        
        return nil;
    }
    
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self tableView:tableView willSelectRowAtIndexPath:indexPath] != nil);
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



#pragma mark - display

- (void)decodeAndDisplay:(NSString *)path {

    NSArray *allfileOFDirectory = [[StudyLibary sharedInstance]getAllFiles:path];

    self.dicomDecoder = [[DicomDecoder alloc] init];
    [self.dicomDecoder setDicomFilename:[allfileOFDirectory firstObject]];

   
    
    // asssing the path that is passed to the viewcontroller to the internal path variable. then reload table data
    _path = path;
    [_tableView reloadData];
    
    self.pNameLabel.text = [self.dicomDecoder infoFor:PATIENT_NAME];
    self.pBirthDateLabel.text = [self.dicomDecoder infoFor:PATIENT_AGE];
    self.pSexLabel.text = [self.dicomDecoder infoFor:PATIENT_SEX];
    self.pIDLabel.text = [self.dicomDecoder infoFor:PATIENT_ID];
    
    self.sDescLabel.text = [self.dicomDecoder infoFor:STUDY_DESCRIPTION];
    self.sModDateLabel.text = [self.dicomDecoder infoFor:STUDY_DATE];
    self.sModLabel.text = [self.dicomDecoder infoFor:MODALITY];
    self.institutionNameLabel.text = [self.dicomDecoder infoFor:InstitutionName ];
    self.referringPhysicianNameLabel.text = [self.dicomDecoder infoFor:ReferringPhysicianName];
    self.performingPhysicianNameLabel.text = [self.dicomDecoder infoFor:PerformingPhysicianName];
    
    NSArray *series = [[StudyLibary sharedInstance]getAllStudies:_path];
    
    
    NSString *totalCount = [NSString stringWithFormat:@"%lu Series , %lu Images ", (unsigned long)[series count],(unsigned long)[allfileOFDirectory count]];
    self.totalLabel.text = totalCount;
}



#pragma mark - Creating the UI

- (void)createLabels {
    CGFloat size = 18;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:size];
    
    self.pNameLabel = [[UILabel alloc]init];
    self.pNameLabel.frame = CGRectMake(140,110,220,21);
    [self.pNameLabel setFont:boldFont];
    [self.view addSubview:self.pNameLabel];

    
    self.pNameL = [[UILabel alloc]init];
    self.pNameL.frame = CGRectMake(20, 110, 173, 21);
    [self.view addSubview:self.pNameL];
    
    self.pIDLabel = [[UILabel alloc]init];
    self.pIDLabel.frame = CGRectMake(140, 145,220,21);
    [self.pIDLabel setFont:boldFont];
    [self.view addSubview:self.pIDLabel];

    
    self.pIDL = [[UILabel alloc]init];
    self.pIDL.frame = CGRectMake(20, 145, 173, 21);
    [self.view addSubview:self.pIDL];
    
    self.pBirthDateLabel = [[UILabel alloc]init];
    self.pBirthDateLabel.frame = CGRectMake(140, 180,120,21);
    [self.pBirthDateLabel setFont:boldFont];
    [self.view addSubview:self.pBirthDateLabel];

    
    self.pBirthDateL = [[UILabel alloc]init];
    self.pBirthDateL.frame = CGRectMake(20, 180, 173, 21);
    [self.view addSubview:self.pBirthDateL];
    
    self.pSexLabel = [[UILabel alloc]init];
    self.pSexLabel.frame = CGRectMake(140, 215,72,21);
    [self.pSexLabel setFont:boldFont];
    [self.view addSubview:self.pSexLabel];
    
    self.pSexL = [[UILabel alloc]init];
    self.pSexL.frame = CGRectMake(20, 215, 173, 21);
    [self.view addSubview:self.pSexL];
    
    self.totalL = [[UILabel alloc]init];
    self.totalL.frame = CGRectMake(20, 250, 173, 21);
    self.totalL.text = @"Total: ";
    [self.view addSubview:self.totalL];
    
    self.totalLabel = [[UILabel alloc]init];
    self.totalLabel.frame = CGRectMake(140, 250, 180, 21);
    [self.totalLabel setFont:boldFont];
    [self.view addSubview:self.totalLabel];
    
    self.sModLabel = [[UILabel alloc]init];
    self.sModLabel.frame = CGRectMake(550,110,90,21);
    [self.sModLabel setFont:boldFont];
    [self.view addSubview:self.sModLabel];
    
    self.sModL = [[UILabel alloc]init];
    self.sModL.frame = CGRectMake(380, 110, 173, 21);
    [self.view addSubview:self.sModL];
    
    
    self.sModDateLabel = [[UILabel alloc]init];
    self.sModDateLabel.frame = CGRectMake(550, 145,120,21);
    [self.sModDateLabel setFont:boldFont];
    [self.view addSubview:self.sModDateLabel];

    self.sModDateL = [[UILabel alloc]init];
    self.sModDateL.frame = CGRectMake(380, 145, 173, 21);
    [self.view addSubview:self.sModDateL];
    
    
    self.sDescLabel = [[UILabel alloc]init];
    self.sDescLabel.frame = CGRectMake(550, 180,200,21);
    [self.sDescLabel setFont:boldFont];
    [self.view addSubview:self.sDescLabel];
    
    self.sDescL = [[UILabel alloc]init];
    self.sDescL.frame = CGRectMake(380, 180, 173, 21);
    [self.view addSubview:self.sDescL];
    
    self.institutionNameL = [[UILabel alloc]init];
    self.institutionNameL.frame = CGRectMake(380, 215, 173, 21);
    self.institutionNameL.text = @"Instituation: ";
    [self.view addSubview:self.institutionNameL];
    
    self.institutionNameLabel = [[UILabel alloc]init];
    self.institutionNameLabel.frame = CGRectMake(550, 215, 173, 21);
    [self.institutionNameLabel setFont:boldFont];
    [self.view addSubview:self.institutionNameLabel];
    
    self.referringPhysicianNameL = [[UILabel alloc]init];
    self.referringPhysicianNameL.frame = CGRectMake(380, 250, 173, 21);
    self.referringPhysicianNameL.text = @"Referring Physician: ";
    [self.view addSubview:self.referringPhysicianNameL];
    
    self.referringPhysicianNameLabel = [[UILabel alloc]init];
    self.referringPhysicianNameLabel.frame = CGRectMake(550, 250, 173, 21);
    [self.referringPhysicianNameLabel setFont:boldFont];
    [self.view addSubview:self.referringPhysicianNameLabel];
    
    self.performingPhysicianNameL = [[UILabel alloc]init];
    self.performingPhysicianNameL.frame = CGRectMake(380, 285, 173, 21);
    self.performingPhysicianNameL.text = @"Performing Physician: ";
    [self.view addSubview:self.performingPhysicianNameL];
    
    self.performingPhysicianNameLabel = [[UILabel alloc]init];
    self.performingPhysicianNameLabel.frame = CGRectMake(550, 285, 173, 21);
    [self.view addSubview:self.performingPhysicianNameLabel];
    
    if (self.tableView.isEditing == NO) {
        _rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(select)];
        [self.navigationItem setRightBarButtonItem:_rightButton];
        //[self.tableView setEditing:YES animated:YES];
    }
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"View" style:UIBarButtonItemStylePlain target:self action:@selector(viewMultiple)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    [leftButton setEnabled:NO];
    [leftButton setTintColor:[UIColor clearColor]];
    
}


- (void)createTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(45, 330, 600, 400) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 110;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    [self.view addSubview:self.tableView];
    
    
}

// Displaying methods for cell view
- (void) displayWith:(NSInteger)windowWidth windowCenter:(NSInteger)windowCenter with:(Dicom2DView *)dicomView {
    if (!self.dicomDecoder.dicomFound || !self.dicomDecoder.dicomFileReadSuccess) {
        self.dicomDecoder = nil;
        return;
    }
    
    NSInteger winWidth        = windowWidth;
    NSInteger winCenter       = windowCenter;
    NSInteger imageWidth      = self.dicomDecoder.width;
    NSInteger imageHeight     = self.dicomDecoder.height;
    NSInteger bitDepth        = self.dicomDecoder.bitDepth;
    NSInteger samplesPerPixel = self.dicomDecoder.samplesPerPixel;
    BOOL signedImage          = self.dicomDecoder.signedImage;
    
    BOOL needsDisplay = NO;
    
    if (samplesPerPixel == 1 && bitDepth == 8) {
        Byte * pixels8 = [self.dicomDecoder getPixels8];
        if (winWidth == 0 && winCenter == 0) {
            Byte max = 0, min = 255;
            NSInteger num = imageWidth * imageHeight;
            for (NSInteger i = 0; i < num; i++) {
                if (pixels8[i] > max) {
                    max = pixels8[i];
                }
                if (pixels8[i] < min) {
                    min = pixels8[i];
                }
            }
            winWidth = (NSInteger)((max + min)/2.0 + 0.5);
            winCenter = (NSInteger)((max - min)/2.0 + 0.5);
        }
        
        [dicomView setPixels8:pixels8
                               width:imageWidth
                              height:imageHeight
                         windowWidth:winWidth
                        windowCenter:winCenter
                     samplesPerPixel:samplesPerPixel
                         resetScroll:YES];
        needsDisplay = YES;
    }
    if (samplesPerPixel == 1 && bitDepth == 16) {
        ushort * pixels16 = [self.dicomDecoder getPixels16];
        if (winWidth == 0 || winCenter == 0) {
            ushort max = 0, min = 65535;
            NSInteger num = imageWidth * imageHeight;
            for (NSInteger i = 0; i < num; i++) {
                if (pixels16[i] > max) {
                    max = pixels16[i];
                }
                if (pixels16[i] < min) {
                    min = pixels16[i];
                }
            }
            winWidth = (NSInteger)((max + min)/2.0 + 0.5);
            winCenter = (NSInteger)((max - min)/2.0 + 0.5);
        }
        
        dicomView.signed16Image = signedImage;
        
        [dicomView setPixels16:pixels16
                                width:imageWidth
                               height:imageHeight
                          windowWidth:winWidth
                         windowCenter:winCenter
                      samplesPerPixel:samplesPerPixel
                          resetScroll:YES];
        
        needsDisplay = YES;
    }
    
    if (samplesPerPixel == 3 && bitDepth == 8) {
        Byte * pixels24 = [self.dicomDecoder getPixels24];
        if (winWidth == 0 || winCenter == 0) {
            Byte max = 0, min = 255;
            NSInteger num = imageWidth * imageHeight * 3;
            for (NSInteger i = 0; i < num; i++) {
                if (pixels24[i] > max) {
                    max = pixels24[i];
                }
                if (pixels24[i] < min) {
                    min = pixels24[i];
                }
            }
            winWidth = (max + min)/2 + 0.5;
            winCenter = (max - min)/2 + 0.5;
        }
        
        [dicomView setPixels8:pixels24
                               width:imageWidth
                              height:imageHeight
                         windowWidth:winWidth
                        windowCenter:winCenter
                     samplesPerPixel:samplesPerPixel
                         resetScroll:YES];
        
        needsDisplay = YES;
    }
    
    if (needsDisplay) {

        [dicomView setNeedsDisplay];
        
        //NSString * info = [NSString stringWithFormat:@"WW/WL: %ld / %ld", (long)self.dicom2dView.winWidth, (long)self.dicom2dView.winCenter];
        //NSLog(@"%@", info);
    }
}

#pragma mark swipe buttons for cell

- (NSArray *)rightButtons {
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f
                                                                      green:0.231f
                                                                       blue:0.188f
                                                                      alpha:1.0]
                                                 icon:[UIImage imageNamed:@"cross.png"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:0.78f
                                                                      green:0.78f
                                                                       blue:0.8f
                                                                      alpha:1.0]
                                                title:@"Share"];
    
    return rightUtilityButtons;
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            
            NSLog(@"delete button 0  index");
            _cCell = cell;
            
            
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert showAlertInView:self
                         withTitle:@"Delete?"
                      withSubtitle:@"Are You Sure You want To Delete"
                   withCustomImage:nil
               withDoneButtonTitle:nil // @"No"
                        andButtons:@[@"Yes", @"No"]];
            alert.delegate = self;
            
            [alert makeAlertTypeWarning];
            
            alert.hideDoneButton = YES;
            
            break;
        }
        case 1:
        {
            NSLog(@"Sahre button 1  index");
            [self showEmail];
        }
            
        default:
            break;
    }
}

- (void) FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title {
    
    if ([title isEqualToString:@"Yes"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:_cCell];//self.tableView.indexPathForSelectedRow;//_myCellIndex;//[self.tableView indexPathForCell:[];
        
        NSString *deleteStudy = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:indexPath.row];
        NSLog(@"Study to Delelte %@", deleteStudy);
        [[StudyLibary sharedInstance]deleteStudyAtPath:deleteStudy];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
    }
    
    if ([title isEqualToString:@"No"]) {
        
        
    }
}

#pragma mark - mail Methods

- (void)showEmail{
    
    NSString *emailTitle = @"Dicom File";
    NSString *messageBody = @"Hey, check this out!";
    NSArray *toRecipents = [NSArray arrayWithObject:@"ahsan186@hotmail.co.uk"];
    
    
    
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"email.zip"];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:_cCell];
        NSString *emailStudy = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:indexPath.row];
        
        [SSZipArchive createZipFileAtPath: appFile withContentsOfDirectory:emailStudy];

        NSData *fileData = [NSData dataWithContentsOfFile:appFile];

        [mc addAttachmentData:fileData mimeType:@"application/zip" fileName:@"dicom.zip"];
        
        [self presentViewController:mc animated:YES completion:NULL];
        
    }
    else {
        
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertInView:self
                     withTitle:@"No Mail Account?"
                  withSubtitle:@"set up a mail account to share file"
               withCustomImage:nil
           withDoneButtonTitle:nil // @"No"
                    andButtons:nil];
        alert.delegate = self;
        
        [alert makeAlertTypeCaution];
        
    }
}


- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"email.zip"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            
            [fileManager removeItemAtPath:appFile error:&error];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            [fileManager removeItemAtPath:appFile error:&error];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            [fileManager removeItemAtPath:appFile error:&error];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark barbutton methods

- (void)select {
    
    [_tableView setEditing:YES animated:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setTintColor:nil];
    
    if(_tableView.isEditing == YES) {
        [_rightButton setTitle:@"Cancel"];
        //[self.tableView setEditing:NO animated:YES];
        [_rightButton setAction:@selector(doneEdit)];
        
        
    }

}


- (void)doneEdit {
    
    [_tableView setEditing:NO animated:YES];
    [_rightButton setTitle:@"Select"];
    [_rightButton setAction:@selector(select)];
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor clearColor]];
}


- (void)viewMultiple {
    NSLog(@"Working multipler");
    DicomSplitViewController *dicomMultiple = [[DicomSplitViewController alloc]init];
    DicomThreeViewController *dicomThreeView = [[DicomThreeViewController alloc]init];
    DicomFourViewController  *dicomFourView = [[DicomFourViewController alloc]init];
    DicomImageViewController *firstView = [[DicomImageViewController alloc]init];
    
    
    NSArray *sRows = _tableView.indexPathsForSelectedRows;
    
    if ([_tableView.indexPathsForSelectedRows count] == 1) {
        //        dicomMultiple.view1Path = fullPath;
        //        dicomMultiple.view2Path = fPath;
        NSLog(@"Pressed 1");
        [self presentViewController:firstView animated:YES completion:nil];
        
    }
    
    
    else if ([_tableView.indexPathsForSelectedRows count] == 2) {
        
        NSIndexPath *one = sRows[0];
        NSIndexPath *two = sRows[1];
        
        NSString *pOne = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:one.row];
        NSString *ptwo = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:two.row];
        
        NSString *pathOne = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pOne pathIndex:0];
        NSString *pathTwo = [[StudyLibary sharedInstance]getFullPathOfAllStudies:ptwo pathIndex:0];
        
        dicomMultiple.view1Path = pathOne;
        dicomMultiple.view2Path = pathTwo;
        dicomMultiple.fullView1Path = pOne;
        dicomMultiple.fullView2Path = ptwo;
        dicomMultiple.imageNum = [[[StudyLibary sharedInstance]getAllStudies:pOne]count]-1;
        dicomMultiple.imageNum2 = [[[StudyLibary sharedInstance]getAllStudies:ptwo]count]-1;
         NSLog(@"Pressed 1 %@", pOne);
        NSLog(@"Pressed 2 %@", ptwo);
        NSLog(@"count %lu", (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:pOne]count]);
        [self presentViewController:dicomMultiple animated:YES completion:nil];
        
    }
    
    
    else if ([_tableView.indexPathsForSelectedRows count] == 3) {
        
        NSIndexPath *one = sRows[0];
        NSIndexPath *two = sRows[1];
        NSIndexPath *three = sRows[2];
        
        NSString *pOne = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:one.row];
        NSString *ptwo = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:two.row];
        NSString *pthree = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:three.row];
        
        NSString *pathOne  = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pOne pathIndex:0];
        NSString *pathTwo  = [[StudyLibary sharedInstance]getFullPathOfAllStudies:ptwo pathIndex:0];
        NSString *pathThree= [[StudyLibary sharedInstance]getFullPathOfAllStudies:pthree pathIndex:0];
        
        dicomThreeView.view1Path = pathOne;
        dicomThreeView.view2Path = pathTwo;
        dicomThreeView.view3Path = pathThree;
        dicomThreeView.fullPathView1  = pOne;
        dicomThreeView.fullPathView2  = ptwo;
        dicomThreeView.fullPathView3  = pthree;
        
        dicomThreeView.imageNum = [[[StudyLibary sharedInstance]getAllStudies:pOne]count]-1;
        dicomThreeView.imageNum2 = [[[StudyLibary sharedInstance]getAllStudies:ptwo]count]-1;
        dicomThreeView.imageNum3 = [[[StudyLibary sharedInstance]getAllStudies:pthree]count]-1;
        
        [self presentViewController:dicomThreeView animated:YES completion:nil];
        
    }
    
    else if ([_tableView.indexPathsForSelectedRows count] == 4) {
        
        NSIndexPath *one = sRows[0];
        NSIndexPath *two = sRows[1];
        NSIndexPath *three = sRows[2];
        NSIndexPath *four = sRows[3];
        
        NSString *pOne = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:one.row];
        NSString *ptwo = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:two.row];
        NSString *pthree = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:three.row];
        NSString *pfour = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:four.row];
        
        NSString *pathOne = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pOne pathIndex:0];
        NSString *pathTwo = [[StudyLibary sharedInstance]getFullPathOfAllStudies:ptwo pathIndex:0];
        NSString *pathThree = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pthree pathIndex:0];
        NSString *pathFour = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pfour pathIndex:0];
        
        dicomFourView.view1Path = pathOne;
        dicomFourView.view2Path = pathTwo;
        dicomFourView.view3Path = pathThree;
        dicomFourView.view4Path = pathFour;
        
        [self presentViewController:dicomFourView animated:YES completion:nil];
        
    }
    
    
}


- (void)reloadData {

    NSLog(@"reloaded");
    
}

@end
