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

#import <Foundation/Foundation.h>

@interface NSUserDefaults (ByHost)

// register
- (void)registerByHostDefaults:(NSDictionary *)defaults;

// remove values
- (void)removeByHostObjectForKey:(NSString *)key;

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
