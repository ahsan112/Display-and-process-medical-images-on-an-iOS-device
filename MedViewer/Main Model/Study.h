//
//  Study.h
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Study : NSObject

@property(nonatomic)NSString *studyPath;

- (NSString *)getStudy: (int)index;

@end
