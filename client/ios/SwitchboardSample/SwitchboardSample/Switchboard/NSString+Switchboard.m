//
//  NSString+Switchboard.m
//  SwitchboardSample
//
//  Created by Chris Beauchamp on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Switchboard.h"

@implementation NSString (Switchboard)

-(NSString *)urlEncode {
	return (NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                (CFStringRef)self,
                                                                NULL,
                                                                (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
