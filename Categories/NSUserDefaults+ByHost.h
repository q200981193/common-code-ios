//
//  NSUserDefaults+ByHost.h
//  QuickShot
//
//  Created by Caleb Davenport on 4/11/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (ByHost)

// set values
- (void)setByHostBool:(BOOL)value forKey:(NSString *)key;
- (void)setByHostFloat:(float)value forKey:(NSString *)key;
- (void)setByHostInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setByHostObject:(id)value forKey:(NSString *)key;
- (void)setByHostDouble:(double)value forKey:(NSString *)key;
- (void)setByHostURL:(NSURL *)value forKey:(NSString *)key;

// get values
- (NSArray *)byHostArrayForKey:(NSString *)key;
- (BOOL)byHostBoolForKey:(NSString *)key;
- (NSData *)byHostDataForKey:(NSString *)key;
- (NSDictionary *)byHostDictionaryForKey:(NSString *)key;
- (float)byHostFloatForKey:(NSString *)key;
- (NSInteger)byHostIntegerForKey:(NSString *)key;
- (id)byHostObjectForKey:(NSString *)key;
//- (NSString *)byHostStringArrayForKey:(NSString *)key;
- (NSString *)byHostStringForKey:(NSString *)key;
- (double)byHostDoubleForKey:(NSString *)key;
- (NSURL *)byHostURLForKey:(NSString *)key;

@end
