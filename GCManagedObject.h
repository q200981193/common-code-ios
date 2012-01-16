/*
 
 Copyright (C) 2011 GUI Cocoa, LLC.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <CoreData/CoreData.h>

@interface GCManagedObject : NSManagedObject

@property (nonatomic, retain) NSDate *createdAt;

// default context
+ (void)setDefaultContext:(NSManagedObjectContext *)context;
+ (NSManagedObjectContext *)defaultContext;

// override this method to provide a model name other than the class name
+ (NSString *)modelName;

// create object in default context
+ (id)instance;

// create object in specified context
+ (id)instanceInContext:(NSManagedObjectContext *)context;

// create a fecth request based on the class
+ (NSFetchRequest *)fetchRequest;
+ (NSFetchRequest *)fetchRequestInContext:(NSManagedObjectContext *)context;

// find objects in default context
+ (NSArray *)all;
+ (NSArray *)allWithSortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allWithSortDescriptors:(NSArray *)descriptors;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors;

// find objects in specified context
+ (NSArray *)allInContext:(NSManagedObjectContext *)context;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context sortDescriptors:(NSArray *)descriptors;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptor:(NSSortDescriptor *)descriptor;
+ (NSArray *)allInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)descriptors;

// count objects in default context
+ (NSUInteger)count;
+ (NSUInteger)countWithPredicate:(NSPredicate *)predicate;

// count objects in specified context
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context;
+ (NSUInteger)countInContext:(NSManagedObjectContext *)context withPredicate:(NSPredicate *)predicate;

@end
