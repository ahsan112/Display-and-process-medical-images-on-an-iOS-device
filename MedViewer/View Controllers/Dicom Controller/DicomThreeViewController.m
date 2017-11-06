//
//  DicomThreeViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "DicomThreeViewController.h"
#import "DicomDecoder.h"
#import "Dicom2DView.h"
#import "StudyLibary.h"

@interface DicomThreeViewController ()

@property (nonatomic) DicomDecoder              *dicomDecoder;
@property (nonatomic) IBOutlet Dicom2DView      *dicomView;
@property (nonatomic) IBOutlet Dicom2DView      *dicom2View;
@property (nonatomic) IBOutlet Dicom2DView      *dicom3View;
@property (nonatomic) UISlider                  *slider;
@property (nonatomic) UISlider                  *slider2;
@property (nonatomic) NSString                  *changingPath;
@property (nonatomic) UIPanGestureRecognizer    *panGesture;
@property (nonatomic) UIPanGestureRecognizer    *panGesture2;
@property (nonatomic) UIPanGestureRecognizer    *panGesture3;
@property (nonatomic) CGAffineTransform          prevTransform;
@property (nonatomic) CGPoint                    startPoint;

@property (nonatomic) UILabel                   *WWLLNameL1;
@property (nonatomic) UILabel                   *WWNameL1;
@property (nonatomic) UILabel                   *ImageNumLabel1;

@property (nonatomic) UILabel                   *WWLLNameL2;
@property (nonatomic) UILabel                   *WWNameL2;
@property (nonatomic) UILabel                   *ImageNumLabel2;


@end

@implementation DicomThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting up the view
    [self createView];
    self.view.backgroundColor = [UIColor blackColor];
    //slider setup
    [self.slider addTarget:self action:@selector(sliderValue) forControlEvents:UIControlEventValueChanged];
    [self.slider2 addTarget:self action:@selector(sliderValue2) forControlEvents:UIControlEventValueChanged];
    
    
    // setting up pan gestures
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForSecondView:)];
    self.panGesture2.maximumNumberOfTouches = 2;
    self.panGesture3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureForthirdView:)];
    self.panGesture3.maximumNumberOfTouches = 2;
    
    [_dicomView  addGestureRecognizer:self.panGesture];
    [_dicom2View addGestureRecognizer:self.panGesture2];
    [_dicom3View addGestureRecognizer:self.panGesture3];
    
    
    self.WWLLNameL1.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom2View.winCenter];
    self.WWNameL1.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom2View.winWidth];
    self.WWLLNameL2.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicomView.winCenter];
    self.WWNameL2.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicomView.winWidth];
    self.ImageNumLabel1.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",0  ,(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];
    self.ImageNumLabel2.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",0 ,(unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] -1 ];
    
    
    //condition to check who sending the path
    if (_view1Path != nil && _view2Path != nil && _view3Path !=nil) {
        [self decodeAndDisplay:_view1Path withView:_dicomView];
        [self decodeAndDisplay:_view2Path withView:_dicom2View];
        [self decodeAndDisplay:_view3Path withView:_dicom3View];
    }
    
    //display images
    NSString *pp =[[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:0];
    [self decodeAndDisplay:pp withView:_dicomView];
    [self decodeAndDisplay:pp withView:_dicom2View];
    [self decodeAndDisplay:pp withView:_dicom3View];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)done {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Slider Methods

- (void)sliderValue {
    
    self.slider.minimumValue = 0;
    self.slider.maximumValue = _imageNum;
    
    _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:_slider.value];
    self.ImageNumLabel2.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider.value,
                                (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count]];

    [self decodeAndDisplay:_changingPath withView:_dicomView];
    
}



- (void)sliderValue2 {
    
    self.slider2.minimumValue = 0;
    self.slider2.maximumValue = _imageNum;
    
    _changingPath = [[StudyLibary sharedInstance]getFullPathOfAllStudies:_path pathIndex:_slider2.value];
    
    self.ImageNumLabel1.text = [NSString stringWithFormat:@"IM: " @"%d" @"/" @"%lu ",(int)self.slider2.value,
                                (unsigned long)[[[StudyLibary sharedInstance]getAllStudies:_path]count] ];

    [self decodeAndDisplay:_changingPath withView:_dicom2View];
    [self decodeAndDisplay:_changingPath withView:_dicom3View];
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
        
        // adjust window width/level
        
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


- (IBAction) handlePanGestureForSecondView:(UIPanGestureRecognizer *)sender {
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
        
        //adjust window width/level
        
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
        self.slider2.hidden  = YES;
    }
    
    if (state == UIGestureRecognizerStateEnded) {
        self.slider2.hidden  = NO;
    }
}


-(IBAction) handlePanGestureForthirdView:(UIPanGestureRecognizer *)sender {
    UIGestureRecognizerState state = [sender state];
    
    if (state == UIGestureRecognizerStateBegan) {
        self.prevTransform = self.dicom3View.transform;
        self.startPoint = [sender locationInView:self.view];
    }
    else if (state == UIGestureRecognizerStateChanged || state == UIGestureRecognizerStateEnded) {
        
        CGPoint location    = [sender locationInView:self.view];
        CGFloat offsetX     = location.x - self.startPoint.x;
        CGFloat offsetY     = location.y - self.startPoint.y;
        self.startPoint          = location;
        
        //adjust window width/level
        
        self.dicom3View.winWidth  += offsetX * self.dicom3View.changeValWidth;
        self.dicom3View.winCenter += offsetY * self.dicom3View.changeValCentre;
        
        if (self.dicom3View.winWidth <= 0) {
            self.dicom3View.winWidth = 1;
        }
        
        if (self.dicom3View.winCenter == 0) {
            self.dicom3View.winCenter = 1;
        }
        
        if (self.dicom3View.signed16Image) {
            self.dicom3View.winCenter += SHRT_MIN;
        }
        
        [self.dicom3View setWinWidth:self.dicom3View.winWidth];
        [self.dicom3View setWinCenter:self.dicom3View.winCenter];
        
        [self displayWith:self.dicom3View.winWidth windowCenter:self.dicom3View.winCenter withView:_dicom3View];
        
        
        self.WWLLNameL2.text = [NSString stringWithFormat:@"WL: %ld ", (long)self.dicom3View.winCenter];
        self.WWNameL2.text = [NSString stringWithFormat:@"WW: %ld ", (long)self.dicom3View.winWidth];
        self.slider2.hidden  = YES;
    }
    
    if (state == UIGestureRecognizerStateEnded) {
        self.slider2.hidden  = NO;
    }
}



#pragma mark - Dicom Display Methods

- (void)decodeAndDisplay:(NSString *)path withView:(Dicom2DView *)dv {
    
    
    self.dicomDecoder = [[DicomDecoder alloc] init];
    [self.dicomDecoder setDicomFilename:path];
    
    [self displayWith:self.dicomDecoder.windowWidth windowCenter:self.dicomDecoder.windowCenter withView:dv];
    
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
        //CGFloat x = (self.view.frame.size.width - imageWidth) /2;
        //CGFloat y = (self.view.frame.size.height - imageHeight) /2;
        
        //self.dicom2View.frame = CGRectMake(x - 250, 7, imageWidth - 100, imageHeight - 150);
        self.dicom2View.frame = CGRectMake(10, 3, 400, 352);
        [self.dicom2View setNeedsDisplay];
        
        //        self.dicomView.frame = CGRectMake(570, 100 , imageWidth - 60, imageHeight- 60);
        self.dicomView.frame = CGRectMake(530, 70 , 480, 480);
        [self.dicomView setNeedsDisplay];
        
        //        self.dicom3View.frame = CGRectMake(x - 250, 348 , 400, 352);
        self.dicom3View.frame = CGRectMake(10, 348 , 400, 352);
        [self.dicom3View setNeedsDisplay];
        //[self.view addSubview: self.dicom3View ];
        
        NSString * info = [NSString stringWithFormat:@"WW/WL: %ld / %ld", (long)self.dicom2View.winWidth, (long)self.dicom2View.winCenter];
        NSLog(@"%@", info);
    }
}


#pragma mark - Creating The UI

- (void)createView {
    
    _dicom2View = [[Dicom2DView alloc]init];
    _dicom2View.frame = CGRectMake(67, 213, 200, 200);
    _dicom2View.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dicom2View];
    
    
    _dicomView = [[Dicom2DView alloc]init];
    _dicomView.frame = CGRectMake(300, 200, 200, 200);
    _dicomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_dicomView];
    
    _dicom3View = [[Dicom2DView alloc]init];
    _dicom3View.frame = CGRectMake(300, 200, 200, 200);
    _dicom3View.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_dicom3View];
    
    
    
    self.slider = [[UISlider alloc]init];
    self.slider.frame = CGRectMake(620, 585, 275, 31);
    
    self.slider.minimumValue = 1;
    self.slider.maximumValue = [[[StudyLibary sharedInstance]getAllStudies:_fullPath] count]-1;
    self.slider.value = (1);
    [self.view addSubview:self.slider];
    
    self.slider2 = [[UISlider alloc]init];
    self.slider2.frame = CGRectMake(90, 660, 275, 35);
    
    self.slider2.minimumValue = 1;
    self.slider2.maximumValue = [[[StudyLibary sharedInstance]getAllStudies:_fullPath] count]-1;
    self.slider2.value = (1);
    [self.view addSubview:self.slider2];
    
    
    
    self.WWNameL1 = [[UILabel alloc]init];
    self.WWNameL1.frame = CGRectMake(927, 40, 173, 21);
    self.WWNameL1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWNameL1];
    
    self.WWLLNameL1 = [[UILabel alloc]init];
    self.WWLLNameL1.frame = CGRectMake(927,60,80,21);
    self.WWLLNameL1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWLLNameL1];
    
    self.ImageNumLabel1 = [[UILabel alloc]init];
    self.ImageNumLabel1.frame = CGRectMake(30, 450,110,21);
    self.ImageNumLabel1.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ImageNumLabel1];
    
    self.WWNameL2 = [[UILabel alloc]init];
    self.WWNameL2.frame = CGRectMake(30, 40, 173, 21);
    self.WWNameL2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWNameL2];
    
    self.WWLLNameL2 = [[UILabel alloc]init];
    self.WWLLNameL2.frame = CGRectMake(30,60,80,21);
    self.WWLLNameL2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.WWLLNameL2];
    
    self.ImageNumLabel2 = [[UILabel alloc]init];
    self.ImageNumLabel2.frame = CGRectMake(927, 650,110,21);
    self.ImageNumLabel2.textColor = [UIColor whiteColor];
    [self.view addSubview:self.ImageNumLabel2];

    
    
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    _navBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_navBar];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    navItem.leftBarButtonItem = leftButton;
    
    
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 75.0f, 30.0f)];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn1 setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
    [btn1 setTitle:@"M" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setFrame:CGRectMake(35.0f, 0.0f, 30.0f, 30.0f)];
    [btn2 setTitle:@"2" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn2];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    
    navItem.rightBarButtonItem = rightBtn;
    _navBar.items = @[ navItem ];
    
    
}


@end
