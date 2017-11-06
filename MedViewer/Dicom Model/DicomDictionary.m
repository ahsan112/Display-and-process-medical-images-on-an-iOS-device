//
//  DicomDictionary.m
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "DicomDictionary.h"
static DicomDictionary *instance;

@implementation DicomDictionary

+ (id)sharedInstance {
    if (!instance) {
        instance = [[DicomDictionary alloc] init];
    }
    
    return instance;
}

- (id) init {
    self = [super init];
    
    if (self) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"DicomDictionary" ofType:@"plist"];
        self.dictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    return self;
}

- (id)valueForKey:(NSString *)key {
    if (!key || [key isEqualToString:@""]) {
        return nil;
    }
    
    id retValue = nil;
    if (self.dictionary) {
        retValue = [self.dictionary valueForKey:key];
    }
    
    return retValue;
}

@end
