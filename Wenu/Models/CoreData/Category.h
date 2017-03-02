//
//  Category.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 28/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import <CoreData/CoreData.h>

extern NSString * const CategoryNameDatabaseKey;

NS_ASSUME_NONNULL_BEGIN

@interface Category : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Category+CoreDataProperties.h"
