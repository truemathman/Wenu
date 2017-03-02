//
//  CustomView.m
//  OffroadNavigation
//
//  Created by Ruslan Kurmakaev on 29/11/16.
//  Copyright © 2016 navmii. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

- (instancetype)init {
    
    return [CustomView viewWithXibName:NSStringFromClass([self class])];
}

+ (instancetype)viewWithXibName:(NSString *)xibName {
    
    id result = nil;

    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:xibName
                                                      owner:nil
                                                    options:nil];
    
    for (id anObject in elements) {
        
        if ([anObject isKindOfClass:[self class]]) {
            
            result = anObject;
            [result setTranslatesAutoresizingMaskIntoConstraints:NO];
            break;
        }
    }
    
    NSAssert(result != nil, @"Xib with name '%@' not found.", xibName);
    
    return result;
}

@end
