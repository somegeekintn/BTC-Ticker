//
//  QSBTCBkgView.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCBkgView.h"

@implementation QSBTCBkgView

- (void) drawRect: (NSRect) inRect
{
	[[NSColor blackColor] set];
	NSRectFill(self.bounds);
}

@end
