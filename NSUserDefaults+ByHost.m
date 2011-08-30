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

#import <UIKit/UIKit.h>

#import "NSUserDefaults+ByHost.h"

@interface NSUserDefaults (ByHost_Private)
- (NSString *)byHostIdentifierForKey:(NSString *)key;
@end

@implementation NSUserDefaults (ByHost_Private)
- (NSString *)byHostIdentifierForKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@-%@",
            [[UIDevice currentDevice] uniqueIdentifier],
            key];
}
@end

@implementation NSUserDefaults (ByHost)

#pragma mark - register
- (void)registerByHostDefaults:(NSDictionary *)defaults {
    NSMutableDictionary *toRegister = [NSMutableDictionary dictionaryWithCapacity:[defaults count]];
    for (NSString *key in [defaults allKeys]) {
        [toRegister setObject:[defaults objectForKey:key]
                       forKey:[self byHostIdentifierForKey:key]];
    }
    [self registerDefaults:toRegister];
}

#pragma mark - remove values
- (void)removeByHostObjectForKey:(NSString *)key {
    NSString *identifier = [self byHostIdentifierForKey:key];
    [self removeObjectForKey:identifier];
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
    NSString *identifier = [self byHostIdentifierForKey:key];
    [self setObject:value forKey:identifier];
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
    NSString *identifier = [self byHostIdentifierForKey:key];
    return [self objectForKey:identifier];
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
