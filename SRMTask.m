//
//  SRMTask.m
//  SRM Trash
//
//  Created by ANTHONY CRUZ on 1/21/17.
//  Copyright © 2017 Writes for All Inc. All rights reserved.
//Permission is hereby granted, free of charge, to any person obtaining a copy  of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SRMTask.h"

NSString * const SRMTaskErrorDomain = @"com.srmerror.domain";

@interface SRMTask()

@property (nonatomic,readonly,class) NSURL *urlToSRMToolOnBundle;

@end

@implementation SRMTask

-(instancetype)initWithOverwriteMode:(SRMOverwriteMode)overwriteMode
{
    self = [super init];
    if (self)
    {
        _overwriteMode = overwriteMode;
        //_enableVerboseLogging = YES;
    }
    return self;
}

-(instancetype)init
{
    return [self initWithOverwriteMode:SRMOverwriteModeSimple];
}

-(BOOL)srmDeleteFileAtURL:(NSURL*)fileURL error:(NSError**)error
{
    NSAssert(fileURL != nil, @"fileURL cannot be nil.");
    NSString *srmPath = SRMTask.urlToSRMToolOnBundle.path;
    
    if (srmPath == nil)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SRMTaskErrorDomain
                                         code:SRMTaskErrorSRMMissingFromMainBundle
                                     userInfo:nil];
        }
        return NO;
    }
    
    NSString *filePath = fileURL.path;
    
    if (filePath == nil)
    {
        if (error != nil)
        {
            *error = [NSError errorWithDomain:SRMTaskErrorDomain
                                         code:SRMTaskErrorFilePathCouldNotBeDeterminedFromFileURL
                                     userInfo:nil];
        }
        return NO;
    }
    
    NSNumber *isFileDirectoryNumber = nil;
    NSError *isDirError = nil;
    
    if ([fileURL getResourceValue:&isFileDirectoryNumber
                       forKey:NSURLIsDirectoryKey
                        error:&isDirError])
    {
        BOOL isDirectory = isFileDirectoryNumber.boolValue;
        NSTask *task = [[NSTask alloc]init];
        task.launchPath = srmPath;
        
        NSMutableArray *taskArguments = [NSMutableArray array];
        
        //Add the -r option if the file is a directory.
        if (isDirectory)
        {
            [taskArguments addObject:@"-r"];
        }
        
        //Add --verbose if enableVerboseLogging is YES.
        if (self.enableVerboseLogging)
        {
            [taskArguments addObject:@"--verbose"];
        }
        
        //Add the overwrite mode argument.
        [taskArguments addObject:[SRMTask overwriteModeToArgumentString:self.overwriteMode]];
        //Add the file path.
        [taskArguments addObject:filePath];
        task.arguments = taskArguments;
        if (self.enableVerboseLogging){ NSLog(@"Arguments: %@",taskArguments);}
        
        NSPipe *outputPipe = [NSPipe pipe];
        NSPipe *errorPipe = [NSPipe pipe];
        task.standardOutput = outputPipe;
        task.standardError = errorPipe;
        [task launch];
        [task waitUntilExit];
        
        NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
        if (errorData.length > 0)
        {
            NSString *errorString = [[NSString alloc]initWithData:errorData encoding:NSUTF8StringEncoding];
            //NSLog(@"Error: %@",errorString);
            if (errorString != nil)
            {
                if (self.enableVerboseLogging) { NSLog(@"%@",errorString); }
                
                if (error != nil)
                {
                    *error = [NSError errorWithDomain:SRMTaskErrorDomain
                                                 code:SRMTaskErrorGenericReadDescription
                                             userInfo:@{NSLocalizedDescriptionKey:errorString}];
                }
            }
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        if (error != nil)
        {
            NSDictionary *underlyingErrorDict = (isDirError != nil) ? @{NSUnderlyingErrorKey:isDirError} : nil;
            *error = [NSError errorWithDomain:SRMTaskErrorDomain
                                         code:SRMTaskErrorFailedToDetermineIfURLIsDirectoryOrFile
                                     userInfo:underlyingErrorDict];
        }
        return NO;
    }

    return NO;
}

#pragma mark - Setters/Getters
+(NSURL*)urlToSRMToolOnBundle
{
    return [[NSBundle mainBundle]URLForResource:@"srm" withExtension:nil];
}

+(NSString*)version
{
    static NSString *theVersion = nil;
    if (theVersion == nil)
    {
        NSString *srmPath = SRMTask.urlToSRMToolOnBundle.path;
        if (srmPath != nil)
        {
            NSTask *versionTask = [[NSTask alloc]init];
            versionTask.launchPath = srmPath;
            versionTask.arguments = @[@"--version"];
            NSPipe *outputPipe = [NSPipe pipe];
            versionTask.standardOutput = outputPipe;
            [versionTask launch];
            [versionTask waitUntilExit];
            NSData *versionData = [outputPipe.fileHandleForReading readDataToEndOfFile];
            if (versionData.length > 0)
            {
                NSString *versionString = [[NSString alloc]initWithData:versionData
                                                               encoding:NSUTF8StringEncoding];
                theVersion = versionString;
            }
        }
    }
    return theVersion;
}

+(NSString*)overwriteModeToArgumentString:(SRMOverwriteMode)overwriteMode
{
    switch (overwriteMode)
    {
        case SRMOverwriteModeSimple:
            return @"--simple";
            break;
            
        case SRMOverwriteModeDod:
            return @"--dod";
            break;
            
        case SRMOverWriteModeDoe:
            return @"--doe";
            break;
            
        case SRMOverWriteModeOpenBSD:
            return @"--openbsd";
            break;
            
        case SRMOverwriteModeRCMP:
            return @"--rcmp";
            break;
            
        case SRMOverwriteModeGutmann:
            return @"--gutmann";
            break;
            
        default:
            NSLog(@"Debug this!");
            break;
    }
}

#pragma mark - Dealloc
-(void)dealloc
{
    //NSLog(@"Dealloc called.");
}

@end
