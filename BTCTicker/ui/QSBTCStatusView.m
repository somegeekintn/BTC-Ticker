//
//  QSBTCStatusView.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCStatusView.h"

@implementation QSBTCStatusView

- (void) drawRect: (NSRect) inRect
{
	NSBezierPath	*statusPath = [NSBezierPath bezierPathWithOvalInRect: CGRectInset(self.bounds, 2.0, 2.0)];
	NSColor			*statusColor = nil;
	
	switch (self.status) {
		case eBTCStatus_Bad:	statusColor = [NSColor redColor];		break;
		case eBTCStatus_Okay:	statusColor = [NSColor yellowColor];	break;
		case eBTCStatus_Good:	statusColor = [NSColor greenColor];		break;
	}
	
	[statusColor set];
	statusPath.lineWidth = 2.0;
	[statusPath stroke];
}

#pragma mark - Getters / Setters

- (void) setStatus: (NSInteger) inStatus
{
	if (_status != inStatus) {
		_status = inStatus;
		[self setNeedsDisplay: YES];
	}
}

@end
