//
//  DicomDictionary.h
//  MedViewer
//
//  Created by Ahsan Mirza on 31/01/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prefix.h"

@interface DicomDictionary : NSObject

@property(nonatomic) NSDictionary *dictionary;

+ (id)sharedInstance;

- (NSString *)valueForKey:(NSString *)key;

@end
