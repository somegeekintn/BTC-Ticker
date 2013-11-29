//
//  QSBTCStatusCell.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/29/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCStatusCell.h"

enum {
	eBTCStatus_Bad = 0,
	eBTCStatus_Okay,
	eBTCStatus_Good
};

@implementation QSBTCStatusCell

- (void) drawInteriorWithFrame: (NSRect) inCellFrame
	inView: (NSView *) inControlView
{
	NSBezierPath	*statusPath;
	NSRect			statusFrame = NSMakeRect(CGRectGetMidX(inCellFrame), CGRectGetMidY(inCellFrame), 8.0, 8.0);
	NSColor			*statusColor = nil;
	
	statusFrame = CGRectOffset(statusFrame, -4.0, -4.0);
	statusPath = [NSBezierPath bezierPathWithOvalInRect: statusFrame];
	
	switch ([self.objectValue integerValue]) {
		case eBTCStatus_Bad:	statusColor = [NSColor redColor];		break;
		case eBTCStatus_Okay:	statusColor = [NSColor yellowColor];	break;
		case eBTCStatus_Good:	statusColor = [NSColor greenColor];		break;
	}
	
	[statusColor set];
	[statusPath fill];
}

@end
