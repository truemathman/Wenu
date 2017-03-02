//
//  NSURLRequest+NSURLRequestSSLY.h
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

@interface NSURLRequest (NSURLRequestSSLY)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;

@end
