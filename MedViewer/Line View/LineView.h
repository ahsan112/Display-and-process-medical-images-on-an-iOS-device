//
//  LineView.h
//  MedViewer
//
//  Created by Ahsan Mirza on 21/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineView : UIView

- (void)removeAll;

@property(nonatomic)CGContextRef context;

@end
