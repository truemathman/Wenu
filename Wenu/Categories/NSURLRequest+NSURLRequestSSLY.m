//
//  NSURLRequest+NSURLRequestSSLY.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "NSURLRequest+NSURLRequestSSLY.h"

@implementation NSURLRequest (NSURLRequestSSLY)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {
    
    return YES;
}

@end
