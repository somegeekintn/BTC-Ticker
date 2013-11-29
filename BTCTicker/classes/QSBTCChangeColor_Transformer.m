//
//  QSBTCChangeColor_Transformer.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCChangeColor_Transformer.h"

@implementation QSBTCChangeColor_Transformer

+ (Class) transformedValueClass
{
	return [NSColor class];
}

+ (BOOL) allowsReverseTransformation
{
	return NO;
}

+ (void) initialize
{
    [NSValueTransformer setValueTransformer: [[QSBTCChangeColor_Transformer alloc] init] forName: @"QSBTCChangeColor"];
}

- (id) transformedValue: (id) inChange
{
	NSColor		*color;
	
	switch ([inChange integerValue]) {
		case NSOrderedAscending:	color = [NSColor greenColor];		break;
		case NSOrderedDescending:	color = [NSColor redColor];			break;
		case NSOrderedSame:
		default:					color = [NSColor whiteColor];		break;
	}

	return color;
}

@end
