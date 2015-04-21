//
//  QConfigration.m
//  DSSClient
//
//  Created by panyj on 14-9-15.
//  Copyright (c) 2014年 panyj. All rights reserved.
//

#import "QConfigration.h"
#import "QTools.h"

static QConfigration * __shareConfigration = nil;

@interface QConfigration()
@property (nonatomic,strong)NSDictionary          * staticRef;
@property (nonatomic,strong)NSMutableDictionary   * runtimeRef;
@property (nonatomic,strong)NSMutableDictionary   * fileRef;
@end

@implementation QConfigration


- (id)init{
    if (self = [super init])
    {
        //self.staticRef =
        self.runtimeRef = [[NSMutableDictionary alloc] initWithCapacity:16];
        [self loadFile];
    }
    return self;
}


+ (QConfigration *) sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareConfigration = [[self alloc] init];
    });    
    return __shareConfigration;
}


+ (NSString*)configFilePath
{
    NSArray  *paths    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [paths objectAtIndex: 0];
    return [document stringByAppendingPathComponent:@"config.plist"];
}

+ (id)readConfigForKey:(NSString*)key
{
    if (key.length == 0) {
        return nil;
    }
    
    id ret = nil;
    ret = [__shareConfigration.runtimeRef objectForKey:key];
    if (ret) {
        return ret;
    }
    
    ret = [__shareConfigration.fileRef objectForKey:key];
    if (ret) {
        return ret;
    }
    
    ret = [__shareConfigration.staticRef objectForKey:key];
    if (ret) {
        return ret;
    }
    
    return nil;
}

+ (id)readConfigForKeyAndRemove:(NSString*)key
{
    if (key.length == 0) {
        return nil;
    }
    
    id ret = nil;
    ret = [__shareConfigration.runtimeRef objectForKey:key];
    if (ret) {
        [__shareConfigration.runtimeRef removeObjectForKey:key];
        return ret;
    }
    
    ret = [__shareConfigration.fileRef objectForKey:key];
    if (ret) {
        [__shareConfigration.fileRef removeObjectForKey:key];
        return ret;
    }
    
    ret = [__shareConfigration.staticRef objectForKey:key];
    if (ret) {//固定配置，不支持删除
        return ret;
    }
    return nil;
}

+ (void)writeFileConfig:(id)value forKey:(NSString*)key
{
    if (value == nil) {
        [__shareConfigration.fileRef removeObjectForKey:key];
    }
    else
    {
        [__shareConfigration.fileRef setObject:value forKey:key];
    }
    __shareConfigration.fileConfigModified = YES;
}

+ (void)writeRuntimeConfig:(id)value forKey:(NSString*)key
{
    if (value == nil) {
        [__shareConfigration.runtimeRef removeObjectForKey:key];
        return;
    }
    [__shareConfigration.runtimeRef setObject:value forKey:key];
}


+ (void)saveFile
{
    if (__shareConfigration.fileConfigModified) {
        NSString  *filePath = [self configFilePath];
        [__shareConfigration.fileRef writeToFile:filePath atomically:NO];
        __shareConfigration.fileConfigModified = NO;
    }
}

- (void)loadFile
{
    //file config
    NSString  *filePath = [QConfigration configFilePath];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ( [fileManager fileExistsAtPath:filePath] )
    {
        self.fileRef = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else
    {
        self.fileRef = [[NSMutableDictionary alloc] initWithCapacity:16];
    }
    //static config
    filePath = [[NSBundle mainBundle] pathForResource:@"manifest" ofType:@"plist"];

    self.staticRef = [NSDictionary dictionaryWithContentsOfFile:filePath];
}


+ (UIColor*)baseColor
{
    static UIColor * color = nil;
    if (color == nil) {
        NSString * rgb = [__shareConfigration.staticRef objectForKey:@"Base_Color"];
        color = [QTools colorOfString10:rgb];
    }
    return color;
}
@end


@implementation NSObject (ARCHelp)

- (NSString*)retainLog
{
    SEL selector = NSSelectorFromString(@"retainCount");
    NSMethodSignature * ms = [NSMethodSignature signatureWithObjCTypes:"i@:"];
    NSInvocation * inv = [NSInvocation invocationWithMethodSignature:ms];
    [inv setSelector:selector];
    [inv invokeWithTarget:self];
    
    NSInteger rtCount = 0;
    [inv getReturnValue:&rtCount];
    
    NSString * sDesp = [NSString stringWithFormat:@"Class=%@,retainCount=%ld",NSStringFromClass([self class]),(long)rtCount];
    return sDesp;
}

@end