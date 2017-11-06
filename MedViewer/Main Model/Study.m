//
//  Study.m
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "Study.h"

@implementation Study


- (NSString *)getStudy: (int)index {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager]subpathsOfDirectoryAtPath:documentDirectory error:nil];
    
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[filePathsArray objectAtIndex:index]];
    
    return filePath;
    
}


@end
