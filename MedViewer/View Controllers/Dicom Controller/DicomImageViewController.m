//
//  DicomImageViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 07/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "DicomImageViewController.h"
#import "Dicom2DView.h"
#import "DicomDecoder.h"
#import "StudyLibary.h"
#import "LineView.h"
#import "PopOverTableViewController.h"
#import "DicomSplitViewController.h"
#import "DicomThreeViewController.h"
#import "DicomFourViewController.h"
#import "IMPopOverTableViewController.h"

@interface DicomImageViewController ()

@property (nonatomic) IBOutlet Dicom2DView   *dicom2dView;
@property (nonatomic) DicomDecoder           *dicomDecoder;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) CGAffineTransform       prevTransform;
@property (nonatomic) CGPoint                 startPoint;
@property (nonatomic) UISlider               *slider;
@property (nonatomic) NSString               *changeingPath;
@property (nonatomic) UINavigationBar        *navBar;
@property (nonatomic) UINavigationItem       *navItem;
@property (nonatomic) UIBarButtonItem        *rightBtn;

@property (nonatomic) UILabel                *WWLLNameL;
@property (nonatomic) UILabel                *WWNameL;

@property (nonatomic) UILabel                *ImageNumLabel;
@property (nonatomic) UILabel                *ZoomLabel;

@property (nonatomic) CGPoint                 StartPoint;
@property (nonatomic) CGPoint                 EndPoint;
@property (nonatomic) CGPoint                 touchPoint;

@property (nonatomic) LineView               *lineView;
@property (nonatomic) NSMutableArray         *linesArray;


@property (nonatomic) PopOverTableViewController   *viewPicker;
@property (nonatomic) IMPopOverTableViewController *windowingPicker;
@property (nonatomic) DicomSplitViewController     *dicomSplit;
@property (nonatomic) DicomThreeViewController     *dicomThreeSplit;
@property (nonatomic) DicomFourViewController      *dicomFourSplit;
@property (nonatomic) UIView                       *childViewFrame;
@end

@implementation DicomImageViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self createView];
    [self creatingUI];
    [self.view setNeedsDisplay];
    self.view.backgroundColor = [UIColor blackColor];
    [_slider setValue:_imageNum];
    self.view.multipleTouchEnabled = true;

    _linesArray = [[NSMutableArray alloc]init];
    
    /*Pan Gestures */
    
    // pan to move
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveObject:)];
    [panRecognizer setMinimumNumberOfTouches:2];
    [panRecognizer setMaximumNumberOfTouches:2];
    [_dicom2dView addGestureRecognizer:panRecognizer];
    
    // pinch to Zoom
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self
                                                 action:@selector(twoFingerPinch:)];
    [[self dicom2dView]addGestureRecognizer:twoFingerPinch];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(showHideNavbar:)];
    [self.view addGestureRecognizer:tapGesture];
    
    
    // displayind the image with pan gesture
    [self.slider addTarget:self action:@selector(sliderValue) forControlEvents:UIControlEventValueChanged];
    
    
    // pan to change contrast
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;
    [self.dicom2dView addGestureRecognizer:self.panGesture];
    
    // display image
     NSString *pp =[[StudyLibary sharedInstance]getFullPathOfAllStudies:_imagePath pathIndex:0];
    [self decodeAndDisplay:pp];
    self.WWLLNameL.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2dView.winCenter];
    self.WWNameL.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2dView.winWidth];
    self.ImageNumLabel.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",0  ,(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_imagePath]count] -1 ];
    self.ZoomLabel.text = @"Zoom: 0%";
    
}



- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

- (void)addLines {
    
    _lineView = [[LineView alloc] initWithFrame:self.view.bounds];
    [_linesArray addObject:_lineView];
    [self.view addSubview:_lineView];
    
    
}

- (void)windowingPopover {
    
    _windowingPicker = [[IMPopOverTableViewController alloc]initWithStyle:UITableViewStylePlain];
    _windowingPicker.modalPresentationStyle= UIModalPresentationPopover;
    _windowingPicker.windowPopoverDelegate = self;
    [self presentViewController:_windowingPicker animated:YES completion:nil];
    UIPopoverPresentationController *popview = [_windowingPicker popoverPresentationController];
    
    popview.barButtonItem = _navItem.rightBarButtonItems[2];
    
}


#pragma mark - POPOVER MWTHODS

- (void)popOverView {
    
    _viewPicker = [[PopOverTableViewController alloc]initWithStyle:UITableViewStylePlain];
    _viewPicker.modalPresentationStyle= UIModalPresentationPopover;
    _viewPicker.popDelgate =self;
    [self presentViewController:_viewPicker animated:YES completion:nil];
    
    UIPopoverPresentationController *popview = [_viewPicker popoverPresentationController];
    popview.barButtonItem = _navItem.rightBarButtonItems.firstObject;

}

// need to fix the label appering from the view bellow

- (void)twoSplitView {
    
    NSLog(@"Pressed 2");
    _childViewFrame = [[UIView alloc]init];
    _childViewFrame.frame = CGRectMake(0, 64, 1024, 704);
    
    if (_dicomThreeSplit !=nil) {
        [self endThreeSplitView];
    }

    if (_dicomFourSplit != nil) {
        [self endFourSplitView];
    }
    
    
    if (_dicomSplit == nil) {
        _dicomSplit = [[DicomSplitViewController alloc]init];
        _dicomSplit.navBar = nil;
        _dicomSplit.tapGesture = nil;
        
        [self addChildViewController:_dicomSplit];
        _dicomSplit.path  = _imagePath;
        _dicomSplit.fullPath = _fullPath;
        _dicomSplit.imageNum = _imageNum;
        _dicomSplit.imageNum2 = _imageNum;
        _dicomSplit.tapGesture = [[UITapGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(showHideNavbar:)];
        //[_dicomSplit.view addGestureRecognizer:self.panGesture];
        
        _dicomSplit.view.frame = _childViewFrame.frame;
        [self.view addSubview:_dicomSplit.view];
        [_dicomSplit didMoveToParentViewController:self];
        
    }
    
    [_viewPicker dismissViewControllerAnimated:YES completion:nil];
    
    
    _dicomSplit.navBar.hidden = YES;
    _dicomSplit.navBar = nil;
    
    _WWNameL.hidden = YES;
    _WWLLNameL.hidden = YES;
    
}

- (void)threeSplit {
    
    NSLog(@"Pressed 3");
    _childViewFrame = [[UIView alloc]init];
    _childViewFrame.frame = CGRectMake(0, 64, 1024, 704);
    
    if (_dicomSplit != nil) {
        [self endSplitView];
    }
    
    if (_dicomFourSplit != nil) {
        [self endFourSplitView];
    }
    
    if (_dicomThreeSplit == nil) {
        _dicomThreeSplit = [[DicomThreeViewController alloc]init];
        _dicomThreeSplit.navBar = nil;
        
        [self addChildViewController:_dicomThreeSplit];
        _dicomThreeSplit.path  = _imagePath;
        _dicomThreeSplit.fullPath = _fullPath;
        _dicomThreeSplit.imageNum = _imageNum;
        //[_dicomSplit.view addGestureRecognizer:self.panGesture];
        
        _dicomThreeSplit.view.frame = _childViewFrame.frame;
        [self.view addSubview:_dicomThreeSplit.view];
        [_dicomThreeSplit didMoveToParentViewController:self];
        
    }
    
    [_viewPicker dismissViewControllerAnimated:YES completion:nil];
    
    
    _dicomThreeSplit.navBar.hidden = YES;
    _dicomThreeSplit.navBar = nil;
    
    _WWNameL.hidden = YES;
    _WWLLNameL.hidden = YES;
}


- (void)fourSplitView {
    
//    NSLog(@"Pressed 4 ");
//    UIView *b = [[UIView alloc]init];
//    b.frame = CGRectMake(0, 64, 1024, 704);
    
    _childViewFrame = [[UIView alloc]init];
    _childViewFrame.frame = CGRectMake(0, 64, 1024, 704);
    
    if (_dicomSplit != nil) {
        [self endSplitView];
    }
    
    if (_dicomThreeSplit !=nil) {
        [self endThreeSplitView];
    }
    
    if (_dicomFourSplit == nil) {
        _dicomFourSplit = [[DicomFourViewController alloc]init];
        _dicomFourSplit.navBar = nil;
        
        [self addChildViewController:_dicomFourSplit];
        _dicomFourSplit.path  = _imagePath;
        _dicomFourSplit.fullPath = _fullPath;
        _dicomFourSplit.imageNum = _imageNum;
        
        //[_dicomSplit.view addGestureRecognizer:self.panGesture];
        
        _dicomFourSplit.view.frame = _childViewFrame.frame;
        [self.view addSubview:_dicomFourSplit.view];
        [_dicomFourSplit didMoveToParentViewController:self];
        
    }
    
    [_viewPicker dismissViewControllerAnimated:YES completion:nil];
    
    
    _dicomFourSplit.navBar.hidden = YES;
    _dicomFourSplit.navBar = nil;
    
    _WWNameL.hidden = YES;
    _WWLLNameL.hidden = YES;
}


- (void)endSplitView {
    
    if (_dicomThreeSplit != nil) {
        [self endThreeSplitView];
    }

    if (_dicomFourSplit != nil) {
        [self endFourSplitView];
    }
    
    _WWNameL.hidden = NO;
    _WWLLNameL.hidden = NO;
    
    [_dicomSplit willMoveToParentViewController:nil];  // 1
    [_dicomSplit.view removeFromSuperview];            // 2
    [_dicomSplit removeFromParentViewController];      // 3
    _dicomSplit = nil;
    
    [_viewPicker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)endThreeSplitView {
    
    [_dicomThreeSplit willMoveToParentViewController:nil];  // 1
    [_dicomThreeSplit.view removeFromSuperview];            // 2
    [_dicomThreeSplit removeFromParentViewController];      // 3
    _dicomThreeSplit = nil;
}

- (void)endFourSplitView {
    
    [_dicomFourSplit willMoveToParentViewController:nil];  // 1
    [_dicomFourSplit.view removeFromSuperview];            // 2
    [_dicomFourSplit removeFromParentViewController];      // 3
    _dicomFourSplit = nil;
}






#pragma mark - Gesture Methods


// Pinch
- (void)twoFingerPinch:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateChanged) {
        NSLog(@"gesture.scale = %f", gesture.scale);
        
        CGFloat currentScale = _dicom2dView.frame.size.width / _dicom2dView.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;
        int MINIMUM_SCALE = 1;
        int MAXIMUM_SCALE = 100;
        if (newScale < MINIMUM_SCALE) {
            newScale = MINIMUM_SCALE;
        }
        if (newScale > MAXIMUM_SCALE) {
            newScale = MAXIMUM_SCALE;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        _dicom2dView.transform = transform;
        gesture.scale = 1;

        //NSLog(@"NEW SCALE %f", newScale);
        self.ZoomLabel.text = [NSString stringWithFormat:@"Zoom: %.0f%% ", currentScale *10];
    }
}

// pan to move

-(void)moveObject:(UIPanGestureRecognizer *)recognizer {
    
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}



// value of the slider
- (void)sliderValue {
    

    self.slider.minimumValue = 0;
    self.slider.maximumValue = _imageNum;
    
    _changeingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_imagePath pathIndex:_slider.value];
    [self decodeAndDisplay:_changeingPath];
    
    self.WWLLNameL.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2dView.winCenter];
    self.WWNameL.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2dView.winWidth];
    self.ImageNumLabel.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider.value,
                               (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_imagePath]count]];
    
}



- (void)done {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void) showHideNavbar:(id) sender {

    if (_navBar.isHidden == NO)
    {
        // hide the Navigation Bar
       // [self.navigationController setNavigationBarHidden:YES animated:YES];
        [_navBar setHidden:YES];
     
        self.WWNameL.frame = CGRectMake(922, 30, 173, 21);
        self.WWLLNameL.frame = CGRectMake(927,50,80,21);
        self.ZoomLabel.frame = CGRectMake(927, 70, 100, 21);
    }
    // if Navigation Bar is already hidden
    else if (_navBar.isHidden == YES)
    {
        // Show the Navigation Bar
        [_navBar setHidden:NO];
        
        self.WWNameL.frame = CGRectMake(922, 110, 173, 21);
        self.WWLLNameL.frame = CGRectMake(927,130,80,21);
        self.ZoomLabel.frame = CGRectMake(927, 150, 100, 21);
       
    }
    
    
    
}

# pragma mark - Creating the Dicom View

- (void)createView {
    
    _dicom2dView = [[Dicom2DView alloc]init];
    [self.view addSubview:_dicom2dView];

    //slider
    self.slider = [[UISlider alloc]init];
    self.slider.frame = CGRectMake(320, 685, 400, 31);
    
    self.slider.minimumValue = 1;
    self.slider.maximumValue = [[[StudyLibary sharedInstance]getAllStudies:_fullPath] count]-1;
    self.slider.value = (1);
    [self.view addSubview:self.slider];
    
    
    //  Creating The Navigation bar
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _navBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navBar];
    
    // Creating the Navigation Item
    _navItem = [[UINavigationItem alloc] init];
    
    //Creating the navigation bar Button and adding it to the Item
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    _navItem.leftBarButtonItem = leftButton;
    

    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 35.0f)];
    customView.backgroundColor = [UIColor redColor];
    UIButton *viewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [viewButton setFrame:CGRectMake(-20.0f, 0.0f, 60.0f, 40.0f)];
    [viewButton setTitle:@"View" forState:UIControlStateNormal];
    [viewButton addTarget:self action:@selector(popOverView) forControlEvents:UIControlEventTouchUpInside];
    
    [customView addSubview:viewButton];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setFrame:CGRectMake(30.0f, 0.0f, 60.0f, 40.0f)];
    [btn2 setTitle:@"Measure" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(addLines) forControlEvents:UIControlEventTouchUpInside];
    
    [customView addSubview:btn2];
    
    UIView *windowView = [[UIView alloc] initWithFrame:CGRectMake(-80.0f, 0.0f, 175.0f, 35.0f)];
    customView.backgroundColor = [UIColor blackColor];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn3 setFrame:CGRectMake(0.0f, 0.0f, 130.0f, 40.0f)];
    [btn3 setTitle:@"Windowing" forState:UIControlStateNormal];
    [btn3 addTarget:self action:@selector(windowingPopover) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *viewB = [[UIBarButtonItem alloc]initWithCustomView:viewButton];
    UIBarButtonItem *measureB = [[UIBarButtonItem alloc]initWithCustomView:btn2];
    UIBarButtonItem *windowB = [[UIBarButtonItem alloc]initWithCustomView:btn3];
    
    
    [_navItem setRightBarButtonItems:[NSArray arrayWithObjects:viewB,measureB,windowB, nil]];
    _navBar.items = @[ _navItem ];
    

    
    
}


#pragma mark - dicom display method

- (void)decodeAndDisplay:(NSString *)path {
    

    self.dicomDecoder = [[DicomDecoder alloc] init];
    [self.dicomDecoder setDicomFilename:path];
    
    [self displayWith:self.dicomDecoder.windowWidth windowCenter:self.dicomDecoder.windowCenter];
    
}

#pragma mark display method dicom
- (void) displayWith:(NSInteger)windowWidth windowCenter:(NSInteger)windowCenter {
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
        
        [self.dicom2dView setPixels8:pixels8
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
        
        self.dicom2dView.signed16Image = signedImage;
        
        [self.dicom2dView setPixels16:pixels16
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
        
        [self.dicom2dView setPixels8:pixels24
                               width:imageWidth
                              height:imageHeight
                         windowWidth:winWidth
                        windowCenter:winCenter
                     samplesPerPixel:samplesPerPixel
                         resetScroll:YES];
        
        needsDisplay = YES;
    }
    
    if (needsDisplay) {
//        CGFloat x = (self.view.frame.size.width - imageWidth) /2;
//        CGFloat y = (self.view.frame.size.height - imageHeight) /2;
        self.dicom2dView.frame = CGRectMake(260, 145, 512, 512);
        [self.dicom2dView setNeedsDisplay];
        
    }
}


#pragma mark - hand gesture

-(IBAction) handlePanGesture:(UIPanGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.prevTransform = self.dicom2dView.transform;
        self.startPoint = [sender locationInView:self.view];
    }
    else if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
        
        CGPoint location    = [sender locationInView:self.view];
        CGFloat offsetX     = location.x - self.startPoint.x;
        CGFloat offsetY     = location.y - self.startPoint.y;
        self.startPoint          = location;
        
        //adjust window width/level
        
        self.dicom2dView.winWidth  += offsetX * self.dicom2dView.changeValWidth;
        self.dicom2dView.winCenter += offsetY * self.dicom2dView.changeValCentre;
        
        if (self.dicom2dView.winWidth <= 0) {
            self.dicom2dView.winWidth = 1;
        }
        
        if (self.dicom2dView.winCenter == 0) {
            self.dicom2dView.winCenter = 1;
        }
        
        if (self.dicom2dView.signed16Image) {
            self.dicom2dView.winCenter += SHRT_MIN;
        }
        
        [self.dicom2dView setWinWidth:self.dicom2dView.winWidth];
        [self.dicom2dView setWinCenter:self.dicom2dView.winCenter];
        
        [self displayWith:self.dicom2dView.winWidth windowCenter:self.dicom2dView.winCenter];
        
        self.WWNameL.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2dView.winWidth];
        self.WWLLNameL.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2dView.winCenter];

    }
}

#pragma mark - Creating UI

- (void)creatingUI {
    
    self.WWNameL = [[UILabel alloc]init];
    self.WWNameL.frame = CGRectMake(922, 110, 173, 21);
    self.WWNameL.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWNameL];

    self.WWLLNameL = [[UILabel alloc]init];
    self.WWLLNameL.frame = CGRectMake(927,130,80,21);
    self.WWLLNameL.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWLLNameL];
    
    self.ImageNumLabel = [[UILabel alloc]init];
    self.ImageNumLabel.frame = CGRectMake(30, 715,110,21);
    self.ImageNumLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ImageNumLabel];
    
    self.ZoomLabel = [[UILabel alloc]init];
    self.ZoomLabel.frame = CGRectMake(927, 150, 100, 21);
    self.ZoomLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ZoomLabel];
}


#pragma mark delegate methods

- (void) displayW:(NSInteger)windowW windowCenter:(NSInteger)windowC {
    
    if (!self.dicomDecoder.dicomFound || !self.dicomDecoder.dicomFileReadSuccess) {
        self.dicomDecoder = nil;
        return;
    }
    
    NSInteger winWidth        = windowW;
    NSInteger winCenter       = windowC;
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
        
        [self.dicom2dView setPixels8:pixels8
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
        
        self.dicom2dView.signed16Image = signedImage;
        
        [self.dicom2dView setPixels16:pixels16
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
        
        [self.dicom2dView setPixels8:pixels24
                               width:imageWidth
                              height:imageHeight
                         windowWidth:winWidth
                        windowCenter:winCenter
                     samplesPerPixel:samplesPerPixel
                         resetScroll:YES];
        
        needsDisplay = YES;
    }
    
    if (needsDisplay) {
        CGFloat x = (self.view.frame.size.width - imageWidth) /2;
        CGFloat y = (self.view.frame.size.height - imageHeight) /2;
        self.dicom2dView.frame = CGRectMake(x, y, 512, 512);
        [self.dicom2dView setNeedsDisplay];
        NSLog(@"Frame: Width %ld, Height %ld",(long)imageWidth, (long)imageHeight);

    }

    [_windowingPicker dismissViewControllerAnimated:YES completion:nil];    
}

- (void)reset {
    
    [self displayWith:self.dicomDecoder.windowWidth windowCenter:self.dicomDecoder.windowCenter];
     [_windowingPicker dismissViewControllerAnimated:YES completion:nil];
    
}


@end
