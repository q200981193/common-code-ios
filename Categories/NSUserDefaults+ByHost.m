//
//  NSUserDefaults+ByHost.m
//  QuickShot
//
//  Created by Caleb Davenport on 4/11/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NSUserDefaults+ByHost.h"

@implementation NSUserDefaults (ByHost)

#pragma mark - remove values
- (void)removeByHostObjectForKey:(NSString *)key {
    NSString *identifier = [[UIDevice currentDevice] uniqueIdentifier];
    NSMutableDictionary *dictionary = [[self dictionaryForKey:identifier] mutableCopy];
    [dictionary removeObjectForKey:key];
    [dictionary release];
}

#pragma mark - set values
- (void)setByHostBool:(BOOL)value forKey:(NSString *)key {
    [self setByHostObject:[NSNumber numberWithBool:value] forKey:key];
}
- (void)setByHostFloat:(float)value forKey:(NSString *)key {
    [self setByHostObject:[NSNumber numberWithFloat:value] forKey:key];
}
- (void)setByHostInteger:(NSInteger)value forKey:(NSString *)key {
    [self setByHostObject:[NSNumber numberWithInteger:value] forKey:key];
}
- (void)setByHostObject:(id)value forKey:(NSString *)key {
    NSString *identifier = [[UIDevice currentDevice] uniqueIdentifier];
    NSMutableDictionary *dictionary = [[self dictionaryForKey:identifier] mutableCopy];
    [dictionary setObject:value forKey:key];
    [dictionary release];
}
- (void)setByHostDouble:(double)value forKey:(NSString *)key {
    [self setByHostObject:[NSNumber numberWithDouble:value] forKey:key];
}
- (void)setByHostURL:(NSURL *)value forKey:(NSString *)key {
    [self setByHostObject:value forKey:key];
}

#pragma mark - get values
- (NSArray *)byHostArrayForKey:(NSString *)key {
    return [self byHostObjectForKey:key];
}
- (BOOL)byHostBoolForKey:(NSString *)key {
    return [[self byHostObjectForKey:key] boolValue];
}
- (NSData *)byHostDataForKey:(NSString *)key {
    return [self byHostObjectForKey:key];
}
- (NSDictionary *)byHostDictionaryForKey:(NSString *)key {
    return [self byHostObjectForKey:key];
}
- (float)byHostFloatForKey:(NSString *)key {
    return [[self byHostObjectForKey:key] floatValue];
}
- (NSInteger)byHostIntegerForKey:(NSString *)key {
    return [[self byHostObjectForKey:key] integerValue];
}
- (id)byHostObjectForKey:(NSString *)key {
    NSString *identifier = [[UIDevice currentDevice] uniqueIdentifier];
    NSDictionary *dictionary = [self dictionaryForKey:identifier];
    return [dictionary objectForKey:key];
}
- (NSString *)byHostStringForKey:(NSString *)key {
    return [self byHostObjectForKey:key];
}
- (double)byHostDoubleForKey:(NSString *)key {
    return [[self byHostObjectForKey:key] doubleValue];
}
- (NSURL *)byHostURLForKey:(NSString *)key {
    return [self byHostObjectForKey:key];
}

@end
