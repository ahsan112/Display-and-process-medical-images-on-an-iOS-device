//
//  StudyLibary.h
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StudyLibary : NSObject

@property(nonatomic)NSArray *allStudies;


// shared instance yo be used to create a singleton
+ (instancetype)sharedInstance;

// return the path of a study
- (NSString *)getStudy: (NSInteger)index;

// get the count of the studies in the document directory
- (int)getStudyCount;

// return all studies within a directory
- (NSArray *)getAllStudies:(NSString *)path;

//return full path of studies
- (NSString *)getFullPathOfAllStudies:(NSString *)path pathIndex:(NSUInteger)index;

- (NSString *)getFullPathOfAllStudies:(NSString *)path;

- (NSArray *)getAllFiles: (NSString *)path;

//delete study

- (void)deleteStudyAtPath: (NSString *)path;

@end
