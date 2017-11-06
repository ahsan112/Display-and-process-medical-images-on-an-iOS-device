//
//  StudyLibary.m
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "StudyLibary.h"

@interface StudyLibary()

@property (nonatomic)NSString *rootPath;
@property (nonatomic)NSMutableArray *privateStudies;
@end

@implementation StudyLibary


#pragma mark initilise singlton
- (id)init {

    @throw [NSException exceptionWithName:@"Singleton" reason:@"use + [StudyLibary sharedLibary]" userInfo:nil];
    return nil;
}



+ (instancetype)sharedInstance {
    
    static StudyLibary *sharedLibary = nil;
    
    if (!sharedLibary) {
        sharedLibary = [[StudyLibary alloc]initWithPrivate];
    }
    
    return sharedLibary;
}



- (instancetype)initWithPrivate {
    
    self = [super init];
    
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _rootPath = [paths objectAtIndex:0];
    }
    
    return self;
}


#pragma mark get the full path of directory which contains studies
- (NSString *)getStudyPath: (NSInteger)index {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    
    NSArray *filePathsArray = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:documentDirectory error:nil];
    
    NSMutableArray * dirContents = [[NSMutableArray alloc] initWithArray:filePathsArray];
    if([filePathsArray containsObject:@".DS_Store"])
    {
        [dirContents removeObject:@".DS_Store"];
    }
    
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:[dirContents objectAtIndex:index]];
    
    return filePath;
    
}



- (NSString *)getStudy: (NSInteger)index {
    
    return [self getStudyPath:index];
}


#pragma mark get the countof studies in directory or files
- (int)getStudyCount {
    int count = 0;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];

    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:NULL];
    
    NSMutableArray * dirContents = [[NSMutableArray alloc] initWithArray:directoryContent];
    if([directoryContent containsObject:@".DS_Store"])
    {
        [dirContents removeObject:@".DS_Store"];
    }
    
    
    while (count < (int)[dirContents count]) {
        count++;
    }
    
    return count;
}


#pragma mark get the all studies within directory
- (NSArray *)getAllStudies:(NSString *)path {
    
    NSFileManager * filemgr = [NSFileManager defaultManager];
    NSArray * filelist = [filemgr contentsOfDirectoryAtPath:path error:nil];
    
    NSMutableArray * dirContents = [[NSMutableArray alloc] initWithArray:filelist];
    if([filelist containsObject:@".DS_Store"])
    {
        [dirContents removeObject:@".DS_Store"];
    }
    
    
      //return filelist;
    return dirContents;
}

#pragma mark get the full path of studies at a path
- (NSString *)getFullPathOfAllStudies:(NSString *)path pathIndex:(NSUInteger)index {

    
    NSFileManager * filemgr = [NSFileManager defaultManager];
    BOOL isDir;
    if([filemgr fileExistsAtPath:path isDirectory:&isDir] &&isDir) {
        
        NSArray * filelist = [filemgr contentsOfDirectoryAtPath:path error:nil];
        NSMutableArray * dirContents = [[NSMutableArray alloc] initWithArray:filelist];
        
        if([filelist containsObject:@".DS_Store"])
            {
                [dirContents removeObject:@".DS_Store"];
            }
        return [path stringByAppendingPathComponent:[dirContents objectAtIndex:index]];
    }
    else {
        return path;
    }
    
    
}


- (NSString *)getFullPathOfAllStudiesWithFullPath:(NSString *)path pathIndex:(NSUInteger)index {

    
    NSFileManager * filemgr = [NSFileManager defaultManager];
    BOOL isDir;
    if([filemgr fileExistsAtPath:path isDirectory:&isDir] &&isDir) {
        
        NSArray * filelist = [filemgr contentsOfDirectoryAtPath:path error:nil];
        NSMutableArray * dirContents = [[NSMutableArray alloc] initWithArray:filelist];
        
        if([filelist containsObject:@".DS_Store"])
        {
            [dirContents removeObject:@".DS_Store"];
        }
        return [path stringByAppendingPathComponent:[dirContents objectAtIndex:index]];
    }
    else {
        return path;
    }
    
    
}


- (NSString *)getFullPathOfAllStudies:(NSString *)path {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
    
    return fullPath;
    
}


#pragma mark delete study for a given path
- (void)deleteStudyAtPath:(NSString *)path {
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:&error];
}



#pragma mark getAll files of a directory
- (NSArray *)getAllFiles:(NSString *)path {
    
    
     NSMutableArray *mutableFileURLs = [NSMutableArray array];
     NSFileManager *fileManager = [NSFileManager defaultManager];

     NSURL *fPath = [NSURL fileURLWithPath:path];
    
     NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:fPath
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error) {


        
        if (error) {

            NSLog(@"[Error] %@ (%@)", error, url);
            [mutableFileURLs addObject:path];
            return NO;
        }
        
        return YES;
    }];
    
   
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            [mutableFileURLs addObject:[fileURL path]];
        }
    }
    
    NSArray *files = [NSArray arrayWithArray:mutableFileURLs];
    return files;
}



@end
