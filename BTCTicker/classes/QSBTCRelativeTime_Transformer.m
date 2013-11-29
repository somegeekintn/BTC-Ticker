//
//  QSBTCRelativeTime.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCRelativeTime_Transformer.h"

@implementation QSBTCRelativeTime_Transformer

+ (Class) transformedValueClass
{
	return [NSString class];
}

+ (BOOL) allowsReverseTransformation
{
	return NO;
}

+ (void) initialize
{
    [NSValueTransformer setValueTransformer: [[QSBTCRelativeTime_Transformer alloc] init] forName: @"QSBTCRelativeTime"];
}

- (id) transformedValue: (id) inDateValue
{
	NSString		*relativeDate = @"";
	
	if (inDateValue != nil) {
		NSTimeInterval	secondsSinceUpdate = -[inDateValue timeIntervalSinceNow];
		
		relativeDate = [NSString stringWithFormat: @"%2.1fs", secondsSinceUpdate];
	}
	
	return relativeDate;
}

@end
