//
//  SRMTask.h
//  SRM Trash
//
//  Created by ANTHONY CRUZ on 1/21/17.
//  Copyright © 2017 Writes for All Inc. All rights reserved.
//Permission is hereby granted, free of charge, to any person obtaining a copy  of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

#import <Foundation/Foundation.h>

@interface SRMTask : NSObject

/*
 By default srm uses the simple mode to overwrite the file's contents.  You
 can  choose  a  different  overwrite mode with --dod, --doe, --openbsd,
 --rcmp, --gutmann.
 */
typedef NS_ENUM(NSInteger, SRMOverwriteMode)
{
    //Overwrite the file with a single pass of 0x00  bytes. This  is the default mode.
    SRMOverwriteModeSimple = 1,
    //US Dod compliant 7-pass overwrite.
    SRMOverwriteModeDod = 2,
    //US DoE compliant 3-pass overwrite.  Twice with a random pattern, finally with the bytes "DoE". See http://cio.energy.gov/CS-11_Clearing_and_Media_Sanitiza-tion_Guidance.pdf for details.
    SRMOverWriteModeDoe = 3,
    //OpenBSD compatible rm.  Files are overwritten three times, first with the byte 0xFF, then 0x00, and then 0xFF again, before they are deleted.
    SRMOverWriteModeOpenBSD = 4,
    //Royal Canadian Mounted Police compliant 3-pass overwrite. First pass writes 0x00 bytes. Second pass writes 0xFF  bytes. Third pass writes "RCMP". See https://www.cse-cst.gc.ca/en/node/270/html/10572 for details.
    SRMOverwriteModeRCMP = 5,
    //Use the 35-pass Gutmann method. See http://en.wikipedia.org/wiki/Gutmann_method for details.
    SRMOverwriteModeGutmann = 6
};

/**
 The designated initializer.
 Init a SRMTask object with the given overwrite mode.
 */
-(nonnull instancetype)initWithOverwriteMode:(SRMOverwriteMode)overwriteMode NS_DESIGNATED_INITIALIZER;

/**
 Call to delete the file at the given URL using srm.
 @param fileURL The fileURL to delete.
 @param error On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object containing the error information. You may specify nil for this parameter if you do not want the error information.
 @return If the operation was successful this method returns YES, otherwise NO.
 */
-(BOOL)srmDeleteFileAtURL:(nonnull NSURL*)fileURL
                    error:(NSError* _Nullable*_Nullable)error;

/**
 The overwrite mode to use. By default this is SRMOverwriteModeSimple.
 */
@property SRMOverwriteMode overwriteMode;

/**
 Set to YES to enable verbose logging, otherwise NO.
 */
@property BOOL enableVerboseLogging;

/**
@return The version of srm we have embedded.
 */
@property (nullable,nonatomic,readonly,class) NSString *version;

/**
 Possible error codes returned from this class.
 */
typedef NS_ENUM(NSInteger, SRMTaskError)
{
    //srm is not on the main bundle and the command therefore could not be be run. This should only happen if someone tampered with the main bundle.
    SRMTaskErrorSRMMissingFromMainBundle = 12,
    //Could not determine if the url passed in was a directory or a file. You should check the NSUnderlyingError key in the userInfo dictionary to find out the reason why.
    SRMTaskErrorFailedToDetermineIfURLIsDirectoryOrFile = 13,
    //path for the passed in fileURL returned nil.
    SRMTaskErrorFilePathCouldNotBeDeterminedFromFileURL = 14,
    //srm command line tool spit out output on the standard error, see the error's description.
    SRMTaskErrorGenericReadDescription = 15
};

extern NSString * _Nonnull  const SRMTaskErrorDomain;

@end
