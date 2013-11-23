//
//  QSBTCConsts.m
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import "QSBTCConsts.h"

// Web Socket
NSString * const		QSBTC_TickerURL						= @"http://websocket.mtgox.com:80/mtgox?Currency=USD";

NSString * const		QSBTCResponseKey_Op					= @"op";
NSString * const		QSBTCResponseKey_MessageType		= @"private";
NSString * const		QSBTCMessageType_Ticker			= @"ticker";
NSString * const		QSBTCMessageType_Trade			= @"trade";
NSString * const		QSBTCMessageType_Depth			= @"depth";
NSString * const		QSBTCTickerKey_TimeStamp			= @"now";
NSString * const		QSBTCTickerValueKey_Currency		= @"currency";
NSString * const		QSBTCTickerValueKey_ValueInt		= @"value_int";		// note: value deprecated, use value_int
NSString * const		QSBTCTickerValueTypeKey_Average		= @"avg";
NSString * const		QSBTCTickerValueTypeKey_Buy			= @"buy";
NSString * const		QSBTCTickerValueTypeKey_High		= @"high";
NSString * const		QSBTCTickerValueTypeKey_Last		= @"last";
NSString * const		QSBTCTickerValueTypeKey_LastAll		= @"last_all";
NSString * const		QSBTCTickerValueTypeKey_LastLocal	= @"last_local";
NSString * const		QSBTCTickerValueTypeKey_LastOrig	= @"last_orig";
NSString * const		QSBTCTickerValueTypeKey_Low			= @"low";
NSString * const		QSBTCTickerValueTypeKey_Sell		= @"sell";
NSString * const		QSBTCTickerValueTypeKey_Volume		= @"vol";
NSString * const		QSBTCTickerValueTypeKey_VWAP		= @"vwap";
NSString * const		QSBTCTradeKey_Currency				= @"price_currency";
NSString * const		QSBTCTradeKey_TimeStamp				= @"tid";
NSString * const		QSBTCTradeKey_PriceInt				= @"price_int";
