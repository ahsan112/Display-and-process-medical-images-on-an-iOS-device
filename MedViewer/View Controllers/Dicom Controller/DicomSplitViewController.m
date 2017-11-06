//
//  DicomSplitViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "DicomSplitViewController.h"
#import "DicomDecoder.h"
#import "Dicom2DView.h"
#import "StudyLibary.h"

@interface DicomSplitViewController ()

@property (nonatomic) DicomDecoder            *dicomDecoder;
@property (nonatomic) IBOutlet Dicom2DView    *dicomView;
@property (nonatomic) IBOutlet Dicom2DView    *dicom2View;
@property (nonatomic) UISlider                *slider;
@property (nonatomic) UISlider                *slider2;
@property (nonatomic) NSString                *changingPath;
@property (nonatomic) UIPanGestureRecognizer  *panGesture;
@property (nonatomic) UIPanGestureRecognizer  *panGesture2;
@property (nonatomic) CGAffineTransform        prevTransform;
@property (nonatomic) CGPoint                  startPoint;

@property (nonatomic) UILabel                 *WWLLNameL1;
@property (nonatomic) UILabel                 *WWNameL1;
@property (nonatomic) UILabel                 *ImageNumLabel1;

@property (nonatomic) UILabel                 *WWLLNameL2;
@property (nonatomic) UILabel                 *WWNameL2;
@property (nonatomic) UILabel                 *ImageNumLabel2;


@end

@implementation DicomSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setting up views and sliders
    [self createView];
    self.view.backgroundColor = [UIColor blackColor];
    [self.slider addTarget:self action:@selector(sliderValue) forControlEvents:UIControlEventValueChanged];
    [self.slider2 addTarget:self action:@selector(sliderValue2) forControlEvents:UIControlEventValueChanged];
    
    // setting up pan gestures
    _tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(showHideNavbar:)];
    [self.view addGestureRecognizer:_tapGesture];
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForSecondView:)];
    self.panGesture2.maximumNumberOfTouches = 2;
    [_dicomView  addGestureRecognizer:self.panGesture];
    [_dicom2View addGestureRecognizer:self.panGesture2];
    
    self.WWLLNameL1.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2View.winCenter];
    self.WWNameL1.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2View.winWidth];
    self.WWLLNameL2.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicomView.winCenter];
    self.WWNameL2.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicomView.winWidth];
    self.ImageNumLabel1.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",0  ,(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];
    self.ImageNumLabel2.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",0  ,(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];
    
    //condition to check whoe is sending the path to view
    if (_view1Path != nil && _view2Path != nil) {
        [self decodeAndDisplay:_view1Path withView:_dicomView];
        [self decodeAndDisplay:_view2Path withView:_dicom2View];
    }
    
    NSString *pp =[[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:0];
    [self decodeAndDisplay:pp withView:_dicomView];
    [self decodeAndDisplay:pp withView:_dicom2View];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - SLIDER METHODS

- (void)sliderValue {
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = _imageNum;
    
    
    if (_view1Path != nil && _view2Path != nil) {
        _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_fullView1Path pathIndex:_slider.value];
        self.ImageNumLabel2.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider.value,
                                    (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_fullView1Path]count] -1 ];
    }
    else{
        _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:_slider.value];
        NSLog(@"Fuuul %@", _changingPath);
        
        self.ImageNumLabel2.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider.value,
                                    (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];

        }
    
    [self decodeAndDisplay:_changingPath withView:_dicomView];
        
    
}

- (void)sliderValue2 {
    
    
    self.slider2.minimumValue = 0;
    self.slider2.maximumValue = _imageNum2;
    
    
    if (_view1Path != nil && _view2Path != nil) {
        _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_fullView2Path pathIndex:_slider2.value];
        self.ImageNumLabel1.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider2.value,
                                    (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_fullView2Path]count] -1 ];
        
    }
    else {
    
        _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:_slider2.value];
        self.ImageNumLabel1.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider2.value,
                                    (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];
    }

    [self decodeAndDisplay:_changingPath withView:_dicom2View];
}


#pragma mark - DICOM DISPLAY METHODS

- (void)decodeAndDisplay:(NSString *)path withView:(Dicom2DView *)dv {

    self.dicomDecoder = [[DicomDecoder alloc] init];
    [self.dicomDecoder setDicomFilename:path];

    [self displayWith:self.dicomDecoder.windowWidth windowCenter:self.dicomDecoder.windowCenter withView:dv];
    
}


#pragma mark - DICOM PAN GESTURE METHODS

-(IBAction) handlePanGesture:(UIPanGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.prevTransform = self.dicomView.transform;
        self.startPoint = [sender locationInView:self.view];
    }
    else if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
        
        CGPoint location    = [sender locationInView:self.view];
        CGFloat offsetX     = location.x - self.startPoint.x;
        CGFloat offsetY     = location.y - self.startPoint.y;
        self.startPoint          = location;
        
        //adjust window width/level
        
        self.dicomView.winWidth  += offsetX * self.dicomView.changeValWidth;
        self.dicomView.winCenter += offsetY * self.dicomView.changeValCentre;
        
        if (self.dicomView.winWidth <= 0) {
            self.dicomView.winWidth = 1;
        }
        
        if (self.dicomView.winCenter == 0) {
            self.dicomView.winCenter = 1;
        }
        
        if (self.dicomView.signed16Image) {
            self.dicomView.winCenter += SHRT_MIN;
        }
        
        [self.dicomView setWinWidth:self.dicomView.winWidth];
        [self.dicomView setWinCenter:self.dicomView.winCenter];
        
        [self displayWith:self.dicomView.winWidth windowCenter:self.dicomView.winCenter withView:_dicomView];
        


        self.WWLLNameL1.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicomView.winCenter];
        self.WWNameL1.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicomView.winWidth];
        
    }
}

-(IBAction) handlePanGestureForSecondView:(UIPanGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.prevTransform = self.dicom2View.transform;
        self.startPoint = [sender locationInView:self.view];
    }
    else if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
        
        CGPoint location    = [sender locationInView:self.view];
        CGFloat offsetX     = location.x - self.startPoint.x;
        CGFloat offsetY     = location.y - self.startPoint.y;
        self.startPoint          = location;
        
        // adjust window width/level
        
        self.dicom2View.winWidth  += offsetX * self.dicom2View.changeValWidth;
        self.dicom2View.winCenter += offsetY * self.dicom2View.changeValCentre;
        
        if (self.dicom2View.winWidth <= 0) {
            self.dicom2View.winWidth = 1;
        }
        
        if (self.dicom2View.winCenter == 0) {
            self.dicom2View.winCenter = 1;
        }
        
        if (self.dicom2View.signed16Image) {
            self.dicom2View.winCenter += SHRT_MIN;
        }
        
        [self.dicom2View setWinWidth:self.dicom2View.winWidth];
        [self.dicom2View setWinCenter:self.dicom2View.winCenter];
        
        [self displayWith:self.dicom2View.winWidth windowCenter:self.dicom2View.winCenter withView:_dicom2View];
        

        self.WWLLNameL2.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2View.winCenter];
        self.WWNameL2.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2View.winWidth];
        
    }
}



- (void) displayWith:(NSInteger)windowWidth windowCenter:(NSInteger)windowCenter withView:(Dicom2DView *)dv {
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
        

        
        [dv setPixels8:pixels8
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
        

        dv.signed16Image = signedImage;
        

        
        [dv setPixels16:pixels16
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
        
        
        [dv setPixels8:pixels24
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
        
        self.dicom2View.frame = CGRectMake(x - 250, y, imageWidth -60, imageHeight- 60);
        [self.dicom2View setNeedsDisplay];
        
        self.dicomView.frame = CGRectMake(570, y , imageWidth - 60, imageHeight- 60);
        NSLog(@" Width %ld", imageWidth - 60);
        NSLog(@" Height %ld", imageHeight - 60);
        [self.dicomView setNeedsDisplay];
        
        NSString * info = [NSString stringWithFormat:@"WW/WL: %ld / %ld", (long)self.dicom2View.winWidth, (long)self.dicom2View.winCenter];
        NSLog(@"%@", info);
    }
}



#pragma mark - CREATING UI 

- (void)createView {
    
    _dicom2View = [[Dicom2DView alloc]init];
    _dicom2View.frame = CGRectMake(67, 213, 200, 200);
    //[_dicom2dView setNeedsDisplay];
    _dicom2View.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dicom2View];
    
    
    _dicomView = [[Dicom2DView alloc]init];
    _dicomView.frame = CGRectMake(300, 200, 200, 200);
    _dicomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dicomView];
    
    self.slider = [[UISlider alloc]init];
    self.slider.frame = CGRectMake(620, 585, 275, 31);
    
    self.slider.minimumValue = 1;
    self.slider.maximumValue = [[[StudyLibary sharedInstance]getAllStudies:_fullPath] count]-1;
    self.slider.value = (1);
    //    self.slider.continuous = YES;
    [self.view addSubview:self.slider];
    
    self.slider2 = [[UISlider alloc]init];
    self.slider2.frame = CGRectMake(120, 585, 275, 31);
    
    self.slider2.minimumValue = 1;
    self.slider2.maximumValue = [[[StudyLibary sharedInstance]getAllStudies:_fullPath] count]-1;
    self.slider2.value = (1);
    [self.view addSubview:self.slider2];
    
    
    self.WWNameL1 = [[UILabel alloc]init];
    self.WWNameL1.frame = CGRectMake(922, 40, 173, 21);
    self.WWNameL1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWNameL1];
    
    self.WWLLNameL1 = [[UILabel alloc]init];
    self.WWLLNameL1.frame = CGRectMake(927,60,80,21);
    self.WWLLNameL1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWLLNameL1];
    
    self.ImageNumLabel1 = [[UILabel alloc]init];
    self.ImageNumLabel1.frame = CGRectMake(30, 650,110,21);
    self.ImageNumLabel1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ImageNumLabel1];

    self.WWNameL2 = [[UILabel alloc]init];
    self.WWNameL2.frame = CGRectMake(50, 40, 173, 21);
    self.WWNameL2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWNameL2];
    
    self.WWLLNameL2 = [[UILabel alloc]init];
    self.WWLLNameL2.frame = CGRectMake(50,60,80,21);
    self.WWLLNameL2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWLLNameL2];
    
    self.ImageNumLabel2 = [[UILabel alloc]init];
    self.ImageNumLabel2.frame = CGRectMake(890, 650,110,21);
    self.ImageNumLabel2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ImageNumLabel2];
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _navBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    navItem.leftBarButtonItem = leftButton;

    _navBar.items = @[ navItem ];
    
}

- (void)done {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) showHideNavbar:(id) sender {

    if (_navBar.isHidden == NO)
    {
        // hide the Navigation Bar
        [_navBar setHidden:YES];

        self.WWNameL1.frame = CGRectMake(922, 30, 173, 21);
        self.WWLLNameL1.frame = CGRectMake(927,50,80,21);
        
    }
    // if Navigation Bar is already hidden
    else if (_navBar.isHidden == YES)
    {
        // Show the Navigation Bar
        [_navBar setHidden:NO];
        
        self.WWNameL1.frame = CGRectMake(922, 110, 173, 21);
        self.WWLLNameL1.frame = CGRectMake(927,130,80,21);
    }
 
}

@end
