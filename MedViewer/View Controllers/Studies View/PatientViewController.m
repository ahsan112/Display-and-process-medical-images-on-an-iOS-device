//
//  PatientViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "PatientViewController.h"
#import "StudyLibary.h"
#import "DicomDecoder.h"
#import "AddStudyViewController.h"
#import "SettingsViewController.h"
#import "SSZipArchive.h"
#import "SWTableViewCell.h"
#import "FCAlertView.h"

#define MAINLABEL_TAG 1
#define PID_TAG 2
#define Mod_TAG 3
#define IMG_Count_TAG 4

@interface PatientViewController ()

@property (nonatomic)UITableView     *tableView;
@property (nonatomic)NSMutableArray  *testArray;
@property (nonatomic)NSIndexPath     *myCellIndex;
@property (nonatomic)SWTableViewCell *cCell;
@property (nonatomic)NSString        *emailPath;
@property (nonatomic)NSString        *titleOFPath;
@property (nonatomic)DicomDecoder    *decoder;

@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic) NSArray             *allContentsArray;
@property (nonatomic) NSArray             *fillteredContents;
@property (nonatomic) NSMutableArray      *decodedContents;
@property (nonatomic) NSMutableDictionary *pathOfDecodedContents;
@property (nonatomic) NSMutableDictionary *uIDs;

@property (nonatomic)    NSMutableArray *addedKeys;


@end

@implementation PatientViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTableView];
    [self setupSearch];
    self.title = @"Patient Studies";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

#pragma mark - Creating the Table View

- (void)createTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 700)
                                                 style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.rowHeight = 110;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStudy)];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    UIBarButtonItem * settingButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Settings-25"] style:UIBarButtonItemStylePlain target:self action:@selector(settingPage)];
    
    [self.navigationItem setLeftBarButtonItem:settingButton];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
}




#pragma mark - Table View Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if (![self.searchController.searchBar.text  isEqual: @""] && self.searchController.isActive)
    {
        return [self.fillteredContents count];
    }
    
    return [[StudyLibary sharedInstance]getStudyCount];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"uitableviewcell" forIndexPath:indexPath];
    static NSString *cellIdentifier = @"Cell";
    
    SWTableViewCell *cell = (SWTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *imageCountLabel, *modLabel, *mainLabel, *pIDLabel;
    _decoder = [[DicomDecoder alloc]init];
    
    // settting up
    if (cell == nil) {
        cell = [[SWTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.leftUtilityButtons = [self leftButtons];
        cell.rightUtilityButtons = [self rightButtons];
        cell.delegate = self;
        
        
        mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 8.0, 220.0, 27.0)];
        mainLabel.tag = MAINLABEL_TAG;
        mainLabel.font = [UIFont systemFontOfSize:22.0];
        mainLabel.textColor = [UIColor blackColor];
        [cell.contentView addSubview:mainLabel];
        
        
        pIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 45.0, 180.0, 25.0)];
        pIDLabel.tag = PID_TAG;
        pIDLabel.font = [UIFont systemFontOfSize:14.0];
        pIDLabel.textColor = [UIColor darkGrayColor];
        pIDLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:pIDLabel];
        
        
        modLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 45.0, 37.0, 37.0)];
        modLabel.tag = Mod_TAG;
        modLabel.font = [UIFont systemFontOfSize:14.0];
        modLabel.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:modLabel];
        
        
        imageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(280.0, 80.0, 37.0, 37.0)];
        imageCountLabel.tag = IMG_Count_TAG;
        imageCountLabel.font = [UIFont systemFontOfSize:14.0];
        imageCountLabel.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:imageCountLabel];
        
        
    }
    
    else {
        
        mainLabel = (UILabel *)[cell.contentView viewWithTag:MAINLABEL_TAG];
        pIDLabel = (UILabel *)[cell.contentView viewWithTag:PID_TAG];
        modLabel = (UILabel *)[cell.contentView viewWithTag:Mod_TAG];
        imageCountLabel = (UILabel *)[cell.contentView viewWithTag:IMG_Count_TAG];
    
    }
    
    
    NSString *searchPath = nil;
    
    
    // when the search bar is active
    if (![self.searchController.searchBar.text  isEqual: @""] && self.searchController.isActive) {
        
        searchPath = _fillteredContents[indexPath.row];
        //[_uIDs allKeysForObject:@[searchPath]];
        DLog(@"FILsssss-----------------------------------------------------------------------------------: %@ ",_fillteredContents[indexPath.row]);
        DLog(@"SEARCH PATH -----------------------------------------------------------------------------------: %@ ",searchPath);
        NSArray *keys = [_uIDs allKeysForObject:searchPath];
        
        NSString *key = [keys firstObject];
         DLog(@"KEYsssss-----------------------------------------------------------------------------------: %@ ", keys);
        
        DLog(@"UID-----------------------------------------------------------------------------------: %@ ", [_uIDs description]);
        NSString *keyPath = [_pathOfDecodedContents objectForKey:key];
        DLog(@"KEY Path-----------------------------------------------------------------------------------: %@ ", keyPath);
        
        // determine if the returned path is a directory
        BOOL isDir;
        if([[NSFileManager defaultManager] fileExistsAtPath:keyPath isDirectory:&isDir] &&isDir){
           
            NSString *pathInDirectory = [[StudyLibary sharedInstance]getFullPathOfAllStudies:keyPath pathIndex:0];
            NSString *fileInDirectory = [[StudyLibary sharedInstance]getFullPathOfAllStudies:pathInDirectory pathIndex:0];
            [_decoder setDicomFilename:fileInDirectory];
            
         
            
            // make these gloabl if it donest work
            NSString * pName = [_decoder infoFor:PATIENT_NAME];
            NSString * modType = [_decoder infoFor:MODALITY];
            NSString * idType = [_decoder infoFor:PATIENT_ID];
            
            mainLabel.text = pName;
            modLabel.text = modType;
            pIDLabel.text = idType;
            imageCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:keyPath] count]];
            
        }
        // not a directory
        else {
            [_decoder setDicomFilename:keyPath];
            
            NSString * pName = [_decoder infoFor:PATIENT_NAME];
            NSString * modType = [_decoder infoFor:MODALITY];
            NSString * idType = [_decoder infoFor:PATIENT_ID];
            
            mainLabel.text = pName;
            modLabel.text = modType;
            pIDLabel.text = idType;
            imageCountLabel.text = @"1";

            
        }
        
        
    }
    
    // search bar not active
    
    else {
    
        NSString *sPath = [[StudyLibary sharedInstance]getStudy:indexPath.row];
        
        
        BOOL isDir;
        if([[NSFileManager defaultManager] fileExistsAtPath:sPath isDirectory:&isDir] &&isDir){
            
            [[[StudyLibary sharedInstance]getAllStudies:sPath] count];
            imageCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:sPath] count]];
            
            //NSString *test = [[StudyLibary sharedInstance]getFullPathOfAllStudies:sPath pathIndex:0]; //indexPath.row
            NSArray *allFileInDirectory = [[StudyLibary sharedInstance]getAllFiles:sPath];
            NSString *file = [allFileInDirectory firstObject];
            
            [_decoder setDicomFilename:file];
            NSString * pName = [_decoder infoFor:PATIENT_NAME];
            NSString * modType = [_decoder infoFor:MODALITY];
            NSString * idType = [_decoder infoFor:PATIENT_ID];
            
            mainLabel.text = pName;
            modLabel.text = modType;
            pIDLabel.text = idType;
            _titleOFPath = mainLabel.text;

        }
        
        else {
            [_decoder setDicomFilename:sPath];

            NSString * pName   =  [_decoder infoFor:PATIENT_NAME];
            NSString * modType =  [_decoder infoFor:MODALITY];
            NSString * idType  =  [_decoder infoFor:PATIENT_ID];
            
            mainLabel.text = pName;
            pIDLabel.text = idType;
            modLabel.text = modType;
            imageCountLabel.text = @"1";
            
        }
    }
    
    
    
    _myCellIndex = indexPath;
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // for selecting search bar result
    NSArray *keys;
    //NSMutableArray *addedKeys;
    if (![self.searchController.searchBar.text  isEqual: @""] && self.searchController.isActive) {
        
        NSString * searchPath = _fillteredContents[indexPath.row];
        DLog(@"----------------------------------FILITERED---------------------------- %@",[_fillteredContents description]);
        DLog(@"----------------------------------SEARCH PATH---------------------------- %@",_fillteredContents[indexPath.row]);
        keys = [_uIDs allKeysForObject:searchPath];
        
        
        DLog(@"----------------------------------ALLLLLL KEYSSSSS---------------------------- %@",[keys description]);
        NSString *key = keys[indexPath.row];//[keys firstObject];
        DLog(@"----------------------------------SEKEYS---------------------------- %@",key);

        
        NSString *ss =  [_pathOfDecodedContents objectForKey:key];
        
        if (_patientDelegate) {
            [_patientDelegate decodeAndDisplay:ss];
        }
        
    }
    
    // not search bar
    else {
        NSString *sPath = [[StudyLibary sharedInstance]getStudy:indexPath.row];
        
        if (_patientDelegate) {
            [_patientDelegate decodeAndDisplay:sPath];


        }
    }

}





#pragma mark - download view controller

- (void)addStudy {

    AddStudyViewController *addView = [[AddStudyViewController alloc]init];
    
    UINavigationController *addStudyController = [[UINavigationController alloc]initWithRootViewController:addView];
    
    addView.controller = addStudyController;
    addView.addStudyDelegate = self;
    addStudyController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:addStudyController animated:YES completion:nil];
    
}




#pragma mark Download

- (void)download: (NSString *)URL {
    

    // get link to downlaod
    NSURL *url = [NSURL URLWithString:URL];
    dispatch_async(dispatch_get_main_queue(), ^{
       
    
    // create download session
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]dataTaskWithURL:
    url completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
    // 4: Handle response here
    if (!error) {
        
        //get doucments direcory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];

        
        NSString *appFile = [documentsDirectory stringByAppendingPathComponent:[response suggestedFilename]];
        
        // create this to handle zip files
        NSString *unZippedFile = [documentsDirectory stringByAppendingPathComponent:[URL lastPathComponent]];
        //[response suggestedFilename]
                                                  
        
                                                  
        // downlonad the file
        //what ever the file is it is downloaded
        [data writeToFile:appFile atomically:YES];
        NSLog(@"Saved At WADOOOO %@: ", appFile);
        
        
        
        BOOL isDir;

        // determine if the file is a zip file
        
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:appFile];
                                                      
            NSData *data = [fh readDataOfLength:4];
                                                      
            if ([data length] == 4) {
                                                          
                const char *bytes = [data bytes];
                
                // file is a zip
                if (bytes[0] == 'P' && bytes[1] == 'K' && bytes[2] == 3 && bytes[3] == 4) {

                    // unzip the file
                    [SSZipArchive unzipFileAtPath:appFile toDestination:unZippedFile];

                    // remove the zip file
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:appFile error:&error];
                    NSLog(@"File is a ZIP !!!!!!!!!!!!!");

                    NSString *UUID = [[NSUUID UUID] UUIDString];
                    _decoder = [[DicomDecoder alloc]init];
                    
                   
                    // determine if directory then read file within it. if file cannot be read remove it.
                    BOOL isDir;
                    if([[NSFileManager defaultManager] fileExistsAtPath:unZippedFile isDirectory:&isDir] &&isDir){
                        NSLog(@"UNZIPPED FILE %@", unZippedFile);
                        
                        
                        
                        
                        //
                        //                                if([[NSFileManager defaultManager] fileExistsAtPath:directory[0] isDirectory:&isDir] &&isDir)
                        
                        //NSString *filePath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:unZippedFile pathIndex:0];
                        
                        NSArray *allFiles = [[StudyLibary sharedInstance]getAllFiles:unZippedFile];
                        NSLog(@"ALL Files %@",allFiles);
                        
                         [_decoder setDicomFilename:[allFiles firstObject]];
                        NSLog(@"Directory FILE PATH %@", [allFiles firstObject]);
                        
                        // is the file readable
                        if (_decoder.dicomFileReadSuccess) {
                            NSString * pName = [_decoder infoFor:PATIENT_NAME];
                            
                            NSLog(@"DECODED CONTENTS Dwonloading ------- %@", _decodedContents);
                            
                            // check is person alread exists
                            if ([_decodedContents containsObject:pName]) {
                                
                                //get path of existing patient
                                NSArray *keys = [_uIDs allKeysForObject:pName];
//                                NSLog(@"KEYS ------- %@", keys);
//                                NSLog(@"Decded KEYS ------- %@", _decodedContents);
//                                NSLog(@"PATH KEYS ------- %@", _pathOfDecodedContents);
//                                
                                // the path of the existing person need to move to
                                NSString *pathToMoveTo = [_pathOfDecodedContents objectForKey:[keys firstObject]];
                                NSLog(@"PAth to Move TO ------- %@", pathToMoveTo);
                                
                                // does the unzipped file contain directories or file
                                NSArray *directory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unZippedFile error:nil];
                                NSString *dirAt = [NSString stringWithFormat:@"%@/%@",unZippedFile,directory[0]];
                                NSLog(@"Directory AT After %@", dirAt);
                                
                                // is it a directory
                                if([[NSFileManager defaultManager] fileExistsAtPath:dirAt isDirectory:&isDir] &&isDir) {
                                    NSLog(@"is a directoy with an exisiting person");
                                    
                                    //dir to move the download to
                                    NSString *dirToMove = dirAt;
                                    NSString *pathToAdd = [unZippedFile lastPathComponent];
                                    
                                    // creating the path to move to
                                    NSString *dirMovingTO = [NSString stringWithFormat:@"%@/%@",pathToMoveTo,pathToAdd];
                                    
                                    NSLog(@"DIR move TO %@", dirToMove);
                                    NSLog(@"DIR moving TO %@", dirMovingTO);
                                    
                                    // move the folder
                                    BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:dirToMove toPath:dirMovingTO error:nil];
                                    
                                    // remove the origianl zipp folder
                                    [[NSFileManager defaultManager]removeItemAtPath:unZippedFile error:nil];
                                    NSLog(@"worker d %d", worker);
                                }
                                // is a file that has an exisiting person
                                else {
                                    NSLog(@"Not Directory but has exisiting person");
                                }
                                
                                
//                                NSString *dirToMove = unZippedFile;
//                                NSString *pathToAdd = [unZippedFile lastPathComponent];
//                                //NSString *movingTo = [pathToMoveTo stringByAppendingString:pathToAdd];
//                                NSString *m = [NSString stringWithFormat:@"%@/%@",pathToMoveTo,pathToAdd];
//                                NSLog(@"DIR move TO %@", dirToMove);
//                                NSLog(@"DIR mogind  TO %@", m);
//                                
//                                BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:dirToMove toPath:m error:nil];
//
//                                  NSLog(@"WORKER GR %d", worker);
                            }

                            
                            
                            // same person not already downloaded
                            else {
                                NSLog(@"A ZIP FILE THAT DOES NOT HAVE EXISTING PERSON");
                                
                                NSArray *directory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:unZippedFile error:nil];
                                NSString *fileToMove = [NSString stringWithFormat:@"%@/%@",unZippedFile,directory[0]];
                                NSLog(@"single zip file to move %@", fileToMove);
                                
                                // if it is a single file
                                if(([[NSFileManager defaultManager] fileExistsAtPath:fileToMove isDirectory:&isDir] &&isDir) == NO) {
                                    NSLog(@"ZIP FILE WITH SINGLE FILE CONFIRMED NO EXISITING PERSON");
                                    NSString *newDirName = [[NSUUID UUID] UUIDString];
                                    BOOL isDirectory;
                                    NSFileManager *manager = [[NSFileManager alloc]init];
                                    NSString *newDir = [documentsDirectory stringByAppendingPathComponent:newDirName];
                                    if (![manager fileExistsAtPath:newDir isDirectory:&isDirectory] || !isDirectory) {
                                        NSError *error = nil;
                                        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                                         forKey:NSFileProtectionKey];
                                        [manager createDirectoryAtPath:newDir
                                           withIntermediateDirectories:YES
                                                            attributes:attr
                                                                 error:&error];
                                        if (error)
                                            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
                                    }
                                    
                                    NSString *dirToMove = unZippedFile;
                                    NSString *pathToAdd = [unZippedFile lastPathComponent];
                                    NSString *movingToPath = [NSString stringWithFormat:@"%@/%@",newDir,pathToAdd];
                                    NSLog(@"DIR move TO %@", dirToMove);
                                    NSLog(@"DIR moving TO %@", movingToPath);
                                    
                                    BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:dirToMove toPath:movingToPath error:nil];
                                    
                                }
                                
                                [_decodedContents addObject:pName];
                                [_uIDs setObject:pName forKey:UUID];
                                //[_pathOfDecodedContents setObject:appFile forKey:UUID];
                                [_pathOfDecodedContents setObject:unZippedFile forKey:UUID];
                            }
                            
                        
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FCAlertView *alert = [[FCAlertView alloc] init];
                                [alert showAlertInView:self
                                             withTitle:@"File Downloaded Sucessfully!"
                                          withSubtitle:@"pull to refresh"
                                       withCustomImage:nil
                                   withDoneButtonTitle:nil // @"No"
                                            andButtons:nil];
                                alert.delegate = self;
                                
                                [alert makeAlertTypeSuccess];
                                NSLog(@"Added File Directory: %@",unZippedFile);
                            });
                        }
                        
                        // file cannot be read
                        else {
                            
                            [[NSFileManager defaultManager]removeItemAtPath:unZippedFile error:nil];
                            NSLog(@"Removed File Directory: %@",unZippedFile);
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FCAlertView *alert = [[FCAlertView alloc] init];
                                [alert showAlertInView:self
                                             withTitle:@"Download Stopped File Cannot Be Read!"
                                          withSubtitle:@"The File Cannot Be Read Please use uncommpresed .dcm file"
                                       withCustomImage:nil
                                   withDoneButtonTitle:nil // @"No"
                                            andButtons:nil];
                                alert.delegate = self;
                                
                                [alert makeAlertTypeWarning];
                                NSLog(@"Added File Directory: %@",unZippedFile);
                            });
                            }
                    
                    }
                    
 //=======================================================TEST THIS ============================================================================
                    // file is not directory read file remove if cant read.
                    else {
                         [_decoder setDicomFilename:unZippedFile];
                        
                        if (_decoder.dicomFileReadSuccess) {
                            NSString * pName = [_decoder infoFor:PATIENT_NAME];
                            //NSString * modType = [dc infoFor:MODALITY];
                            //NSString * idType = [dc infoFor:PATIENT_ID];
                            [_decodedContents addObject:pName];
                            [_uIDs setObject:pName forKey:UUID];
                            [_pathOfDecodedContents setObject:appFile forKey:UUID];
                            NSLog(@"Added File Sigle: %@",unZippedFile);
                        }
                        else {
                            
                            [[NSFileManager defaultManager]removeItemAtPath:unZippedFile error:nil];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FCAlertView *alert = [[FCAlertView alloc] init];
                                [alert showAlertInView:self
                                             withTitle:@"File Removed, Cannot Be Read!"
                                          withSubtitle:@"The File Cannot Be Read Please use uncommpresed .dcm file"
                                       withCustomImage:nil
                                   withDoneButtonTitle:nil // @"No"
                                            andButtons:nil];
                                alert.delegate = self;
                                
                                [alert makeAlertTypeWarning];
                                
                            });
                            NSLog(@"Removed File Single: %@",unZippedFile);
                        }
                        
                    }
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                    
//                    return;
                }
                
                // length of 4 but single file
                else if(![[NSFileManager defaultManager] fileExistsAtPath:appFile isDirectory:&isDir] &&isDir) {
                    NSLog(@"File Not ZipPPPPPPP");
                    
                }

            }
        
        // file is not zip
        
            else if(![[NSFileManager defaultManager] fileExistsAtPath:appFile isDirectory:&isDir]) {
                NSLog(@"File Not ZipPPPPPPP");
                
                NSString *UUID = [[NSUUID UUID] UUIDString];
                _decoder = [[DicomDecoder alloc]init];
                
                BOOL isDir;
                if([[NSFileManager defaultManager] fileExistsAtPath:appFile isDirectory:&isDir] &&isDir){
                    
                    NSString *filePath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:appFile pathIndex:0];
                    [_decoder setDicomFilename:filePath];
                    
                    if (_decoder.dicomFileReadSuccess) {
                        NSString * pName = [_decoder infoFor:PATIENT_NAME];
                        //NSString * modType = [dc infoFor:MODALITY];
                        //NSString * idType = [dc infoFor:PATIENT_ID];
                        [_decodedContents addObject:pName];
                        [_uIDs setObject:pName forKey:UUID];
                        [_pathOfDecodedContents setObject:appFile forKey:UUID];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FCAlertView *alert = [[FCAlertView alloc] init];
                            [alert showAlertInView:self
                                         withTitle:@"File Downloaded Succesfully!"
                                      withSubtitle:@"The File has downloaded sucessfully pull to refresh"
                                   withCustomImage:nil
                               withDoneButtonTitle:nil // @"No"
                                        andButtons:nil];
                            alert.delegate = self;
                            
                            [alert makeAlertTypeSuccess];
                            
                        });
                        NSLog(@"Added File NON Zip Directory: %@",appFile);
                    }
                    else {
                        
                        [[NSFileManager defaultManager]removeItemAtPath:appFile error:nil];
                        NSLog(@"Removed File NON ZIP Directory: %@",appFile);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FCAlertView *alert = [[FCAlertView alloc] init];
                            [alert showAlertInView:self
                                         withTitle:@"Download Stopped File Cannot Be Read!"
                                      withSubtitle:@"The File Cannot Be Read Please use uncommpresed .dcm file"
                                   withCustomImage:nil
                               withDoneButtonTitle:nil // @"No"
                                        andButtons:nil];
                            alert.delegate = self;
                            
                            [alert makeAlertTypeWarning];
                            
                        });
                    }
                    
                }
                
                // file is not directory read file remove if cant read.
                else {
                     NSLog(@"File Not ZipPPPPPPP");
                    [_decoder setDicomFilename:appFile];
                    
                    if (_decoder.dicomFileReadSuccess) {
                        NSString * pName = [_decoder infoFor:PATIENT_NAME];
                        //NSString * modType = [dc infoFor:MODALITY];
                        //NSString * idType = [dc infoFor:PATIENT_ID];
                        [_decodedContents addObject:pName];
                        [_uIDs setObject:pName forKey:UUID];
                        [_pathOfDecodedContents setObject:appFile forKey:UUID];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FCAlertView *alert = [[FCAlertView alloc] init];
                            [alert showAlertInView:self
                                         withTitle:@"File Downloaded Succesfully!"
                                      withSubtitle:@"The File has downloaded sucessfully pull to refresh"
                                   withCustomImage:nil
                               withDoneButtonTitle:nil // @"No"
                                        andButtons:nil];
                            alert.delegate = self;
                            
                            [alert makeAlertTypeSuccess];
                            
                        });
                        NSLog(@"Added File NONE ZIP Sigle: %@",appFile);
                    }
                    else {
                        
                        [[NSFileManager defaultManager]removeItemAtPath:unZippedFile error:nil];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FCAlertView *alert = [[FCAlertView alloc] init];
                            [alert showAlertInView:self
                                         withTitle:@"Download Stopped File Cannot Be Read!"
                                      withSubtitle:@"The File Cannot Be Read Please use uncommpresed .dcm file"
                                   withCustomImage:nil
                               withDoneButtonTitle:nil // @"No"
                                        andButtons:nil];
                            alert.delegate = self;
                            
                            [alert makeAlertTypeWarning];
                            NSLog(@"Added File Directory: %@",unZippedFile);
                        });
                        NSLog(@"Removed File NON ZIP Single: %@",appFile);
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
                
            }
//=============================================================TEST THE ONES IN BETWEEN=====================================================================
        
        // single non zip file
        if ([[NSFileManager defaultManager] fileExistsAtPath:appFile] ) {
            NSLog(@"SINGLE NON ZIP FILE  ");
            
            /**
             *  two options
                1) does not have exisiting study
                    - create dir within a dir and move file into it
                2) has exisiting study
                    - create one dir move file into it then move dir to exisitng study dir
             */
            
            
            // creating first directory to put first file in
            NSString *newPathName = [[NSUUID UUID] UUIDString];
            BOOL isDirectory;
            NSFileManager *manager = [[NSFileManager alloc]init];
            NSString *newDir = [documentsDirectory stringByAppendingPathComponent:newPathName];
            if (![manager fileExistsAtPath:newDir isDirectory:&isDirectory] || !isDirectory) {
                NSError *error = nil;
                NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                 forKey:NSFileProtectionKey];
                [manager createDirectoryAtPath:newDir
                   withIntermediateDirectories:YES
                                    attributes:attr
                                         error:&error];
                if (error)
                    NSLog(@"Error creating directory path: %@", [error localizedDescription]);
            }
            // end of creating dir
            
            // moving file into the first created dir
            NSString *pathToAdd = newPathName;
            NSString *movingDir = [NSString stringWithFormat:@"%@/%@",newDir,pathToAdd];
            NSLog(@"DIR moving TO %@", movingDir);
            BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:appFile toPath:movingDir error:nil];
            // file is now in a dir
             NSLog(@"FILE IN FIRST DIR %d", worker);

            
            
    
            NSString *UUID = [[NSUUID UUID] UUIDString];
            _decoder = [[DicomDecoder alloc]init];
            NSLog(@"File Not ZipPPPPPPP");
            [_decoder setDicomFilename:movingDir];
            
            // is the file readable
            if (_decoder.dicomFileReadSuccess) {
                
                NSString * pName = [_decoder infoFor:PATIENT_NAME];
                
                // if the person already exist move the dir into the existing one
                // create the inner dir
                if ([_decodedContents containsObject:pName]) {
                    
                    NSArray *keys = [_uIDs allKeysForObject:pName];
//                    NSLog(@"KEYS ------- %@", keys);
//                    NSLog(@"Decded KEYS ------- %@", _decodedContents);
//                    NSLog(@"PATH KEYS ------- %@", _pathOfDecodedContents);
                    
                    NSString *pathToMoveTo = [_pathOfDecodedContents objectForKey:[keys firstObject]];
                    NSLog(@"PAth to Move TO ------- %@", pathToMoveTo);
                    
                    // could change this to last of movingDir
                    NSString *pathToAdd = [movingDir lastPathComponent];
                    NSString *movings = [NSString stringWithFormat:@"%@/%@",pathToMoveTo,pathToAdd];
                    
                    // moving the dir to the exisitng dir
                    BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:newDir toPath:movings error:nil];
                    
                    NSLog(@"MOVED TO EXISTING DIR  %d", worker);
                }
                
                
                // same person not already downloaded
                else {
                    NSLog(@"CREATING INNER DIR");
                    
                    // create a new dir
                    NSString *anotherPathName = [[NSUUID UUID] UUIDString];
                    NSString *innerDir = [newDir stringByAppendingPathComponent:anotherPathName];
                    NSLog(@"INNER DIR PATH %@", innerDir);
                    
                    if (![manager fileExistsAtPath:innerDir isDirectory:&isDirectory] || !isDirectory) {
                        NSError *error = nil;
                        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                                         forKey:NSFileProtectionKey];
                        [manager createDirectoryAtPath:innerDir
                           withIntermediateDirectories:YES
                                            attributes:attr
                                                 error:&error];
                        if (error)
                            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
                    }
        
                    NSString *moving = [NSString stringWithFormat:@"%@/%@",innerDir,pathToAdd];
                    NSLog(@"INNER DIR MOVING PATH  %@", innerDir);
                    BOOL worker =  [[NSFileManager defaultManager]moveItemAtPath:movingDir toPath:moving error:nil];
                    
                    NSLog(@"MOVED TO INNER %d", worker);
                    [_decodedContents addObject:pName];
                    [_uIDs setObject:pName forKey:UUID];
                    [_pathOfDecodedContents setObject:moving forKey:UUID];
                }
                

                
                
                
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert showAlertInView:self
                                 withTitle:@"File Downloaded Succesfully!"
                              withSubtitle:@"The File has downloaded sucessfully pull to refresh"
                           withCustomImage:nil
                       withDoneButtonTitle:nil // @"No"
                                andButtons:nil];
                    alert.delegate = self;
                    
                    [alert makeAlertTypeSuccess];
                    
                });
                NSLog(@"Added File NONE ZIP Sigle: %@",appFile);
            }
            
            
            
            else {
                
                //[[NSFileManager defaultManager]removeItemAtPath:unZippedFile error:nil];
                //[[NSFileManager defaultManager]removeItemAtPath:movingDir error:nil];
                [[NSFileManager defaultManager]removeItemAtPath:newDir error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    FCAlertView *alert = [[FCAlertView alloc] init];
                    [alert showAlertInView:self
                                 withTitle:@"Download Stopped!"
                              withSubtitle:@"The File Cannot Be Read Please use uncommpresed .dcm file"
                           withCustomImage:nil
                       withDoneButtonTitle:nil // @"No"
                                andButtons:nil];
                    alert.delegate = self;
                    
                    [alert makeAlertTypeWarning];
                    NSLog(@"Added File Directory: %@",unZippedFile);
                });
                NSLog(@"Removed File NON ZIP Single: %@",appFile);
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        }
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            FCAlertView *alert = [[FCAlertView alloc] init];
            [alert showAlertInView:self
                         withTitle:@"File Cannot Be Dwonlaoded!"
                      withSubtitle:@"Please use a secure HTTPS connection"
                   withCustomImage:nil
               withDoneButtonTitle:nil // @"No"
                        andButtons:nil];
            alert.delegate = self;
            
            [alert makeAlertTypeWarning];
            
        });
    }
        
        
//            else {
//                NSLog(@"ERRROROROOR");
//            }
        
    }];
    
     //[_tableView reloadData];
    [downloadTask resume];
   });
}


- (void)showalert {
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert showAlertInView:self
                 withTitle:@"No Mail Account?"
              withSubtitle:@"set up a mail account to share file"
           withCustomImage:nil
       withDoneButtonTitle:nil // @"No"
                andButtons:nil];
    
    
    [alert makeAlertTypeCaution];
    
}




#pragma mark Settings

- (void)settingPage {
    
    SettingsViewController *settingView = [[SettingsViewController alloc]init];
    
    UINavigationController *settingsController = [[UINavigationController alloc]initWithRootViewController:settingView];
    settingView.controller = settingsController;
    settingsController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:settingsController animated:YES completion:nil];
    
}



#pragma mark swipe buttons for cell

- (NSArray *)rightButtons {
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f
                                                                      green:0.231f
                                                                       blue:0.188f
                                                                      alpha:1.0]
                                                 icon:[UIImage imageNamed:@"cross.png"]];
    
    return rightUtilityButtons;
}

- (NSArray *)leftButtons {
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor:
    [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                               title:@"Share"];
    return leftUtilityButtons;
}





- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSLog(@"More button was pressed");
            [self showEmail];

            break;
        }
        default:
            break;
    }
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
            
        default:
            break;
    }
}



- (void) FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title {
    
    if ([title isEqualToString:@"Yes"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:_cCell];//self.tableView.indexPathForSelectedRow;//_myCellIndex;//[self.tableView indexPathForCell:[];
        
        NSLog(@"index path %ld", (long)indexPath.row);
        NSString *deleteStudy = [[StudyLibary sharedInstance]getStudy:indexPath.row];
        
        
        [[StudyLibary sharedInstance]deleteStudyAtPath:deleteStudy];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        if (_patientDelegate) {
            [_patientDelegate reloadData];
            //            [_patientDelegate setTitleWithPath:_titleOFPath];
            
        }
        
    }
    
    if ([title isEqualToString:@"No"]) {
       

    }
}




#pragma mark - Mail Methods

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
        
        
        [SSZipArchive createZipFileAtPath: appFile withContentsOfDirectory: _emailPath];
        NSLog(@"Full path %@", _emailPath);
        NSLog(@"APP File %@", appFile);
        //NSString *filePath = _emailPath;
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




#pragma mark - Search Bar Methods


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    
    NSString *searchString = searchController.searchBar.text;
    
    [self searchForText:searchString];
    [self.tableView reloadData];
    
}

- (void)searchForText: (NSString *)searchText {
    
    
//  NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@" SELF contains[c] %@", searchText];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@" SELF BEGINSWITH[c] %@", searchText];

    _fillteredContents = [_decodedContents filteredArrayUsingPredicate:resultPredicate];
    DLog(@"Filererded ARRAY: %@ -----------------------------------------------",_fillteredContents);
     DLog(@"DECODED ARRAY: %@ -----------------------------------------------",_decodedContents);
}



- (void)setupSearch {
    
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        _fillteredContents = [[NSArray alloc]init];
        _decodedContents = [[NSMutableArray alloc]init];
        _pathOfDecodedContents = [[NSMutableDictionary alloc]init];
        _allContentsArray = [[NSArray alloc]init];
        _allContentsArray = [[StudyLibary sharedInstance]getAllStudies:documentsDirectory];
     DLog(@"ALLLLLLLLLLL: %@ -----------------------------------------------",_allContentsArray);
        _uIDs = [[NSMutableDictionary alloc]init];
    
//    if ([_allContentsArray count]==0 ) {
//        return;
//    }
//    else {}
    
    DicomDecoder *dc = [[DicomDecoder alloc]init];
    // change to -1 if breaks when remove ds
        for (int i = 0; i < [_allContentsArray count]; i++) {
            
            // get path of study
            NSString *sPath = [[StudyLibary sharedInstance]getStudy:i];
             DLog(@"SPATHHHHHHHHHH: %@ -----------------------------------------------",sPath);
            // is path a directory
            BOOL isDir;
            if([[NSFileManager defaultManager] fileExistsAtPath:sPath isDirectory:&isDir] &&isDir){
                
                // get file within directory
                NSString *studyInPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:sPath pathIndex:0];
                NSString *imageToDisplay =[[StudyLibary sharedInstance]getFullPathOfAllStudies:studyInPath pathIndex:0];
                [dc setDicomFilename:imageToDisplay];
                NSString *UUID = [[NSUUID UUID] UUIDString];
                
                // retrive the values from the file
                NSString * pName = [dc infoFor:PATIENT_NAME];
                NSString * modType = [dc infoFor:MODALITY];
                NSString * idType = [dc infoFor:PATIENT_ID];
                
                // add to decoded contents
                [_decodedContents addObject:pName];
                //[_decodedContents addObject:modType];
                //[_decodedContents addObject:idType];
                
                [_uIDs setObject:pName forKey:UUID];
                //[_uIDs setObject:@[pName,modType,idType] forKey:UUID];
                
//                [_uIDs setObject:UUID forKey:pName];
//                [_uIDs setObject:UUID forKey:modType];
//                [_uIDs setObject:UUID forKey:idType];
                
                [_pathOfDecodedContents setObject:sPath forKey:UUID];
                
                //assign the decoded contents to the path of the file
//                [_pathOfDecodedContents setObject:sPath forKey:pName];
//                [_pathOfDecodedContents setObject:sPath forKey:modType];
//                [_pathOfDecodedContents setObject:sPath forKey:idType];
                NSLog(@"Contents222222222:::::: %@",[_pathOfDecodedContents objectForKey:pName]);
            }
            
            // if not a directory
            else {
                NSString *UUID = [[NSUUID UUID] UUIDString];
                [dc setDicomFilename:sPath];
                NSString * pName = [dc infoFor:PATIENT_NAME];
//                NSString * idType = [dc infoFor:PATIENT_ID];
//                
                // add to decoded contents
                [_decodedContents addObject:pName];
                //[_decodedContents addObject:modType];
                //[_decodedContents addObject:idType];
//
                [_uIDs setObject:pName forKey:UUID];
                //[_uIDs setObject:@[pName,modType,idType] forKey:UUID];
//                [_uIDs setObject:UUID forKey:pName];
//                [_uIDs setObject:UUID forKey:modType];
//                [_uIDs setObject:UUID forKey:idType];
                
                [_pathOfDecodedContents setObject:sPath forKey:UUID];
                
                //assign the decoded contents to the path of the file
//                [_pathOfDecodedContents setObject:sPath forKey:pName];
//                [_pathOfDecodedContents setObject:sPath forKey:idType];
                NSLog(@"Contents11111111:::::: %@",[_pathOfDecodedContents objectForKey:pName]);
            }
            
            
        
        }
    
    
    
}

@end
