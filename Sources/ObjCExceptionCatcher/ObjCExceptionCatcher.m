#import "include/ObjCExceptionCatcher.h"

@implementation ObjCExceptionCatcher

+ (BOOL)tryExecute:(void (NS_NOESCAPE ^)(void))block error:(NSError * _Nullable * _Nullable)error {
    @try {
        block();
        return YES;
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:exception.name ?: @"com.thinkur.NSException"
                                         code:-1
                                     userInfo:@{
                NSLocalizedDescriptionKey: exception.reason ?: @"Unknown Objective-C exception",
                @"ExceptionName": exception.name ?: @"NSException",
                @"ExceptionReason": exception.reason ?: @""
            }];
        }
        return NO;
    }
}

@end
