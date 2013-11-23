//
//  QSBTCConsts.h
//  BTCTicker
//
//  Created by Casey Fleser on 11/23/13.
//  Copyright (c) 2013 Quiet Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

// Web Socket
extern NSString * const		QSBTC_TickerURL;

extern NSString * const		QSBTCResponseKey_Op;
extern NSString * const		QSBTCResponseKey_MessageType;
extern NSString * const		QSBTCMessageType_Ticker;
extern NSString * const		QSBTCMessageType_Trade;
extern NSString * const		QSBTCMessageType_Depth;
extern NSString * const		QSBTCTickerKey_TimeStamp;
extern NSString * const		QSBTCTickerValueKey_Currency;
extern NSString * const		QSBTCTickerValueKey_ValueInt;
extern NSString * const		QSBTCTickerValueTypeKey_Average;
extern NSString * const		QSBTCTickerValueTypeKey_Buy;
extern NSString * const		QSBTCTickerValueTypeKey_High;
extern NSString * const		QSBTCTickerValueTypeKey_Last;
extern NSString * const		QSBTCTickerValueTypeKey_LastAll;
extern NSString * const		QSBTCTickerValueTypeKey_LastLocal;
extern NSString * const		QSBTCTickerValueTypeKey_LastOrig;
extern NSString * const		QSBTCTickerValueTypeKey_Low;
extern NSString * const		QSBTCTickerValueTypeKey_Sell;
extern NSString * const		QSBTCTickerValueTypeKey_Volume;
extern NSString * const		QSBTCTickerValueTypeKey_VWAP;
extern NSString * const		QSBTCTradeKey_Currency;
extern NSString * const		QSBTCTradeKey_TimeStamp;
extern NSString * const		QSBTCTradeKey_PriceInt;

enum {
	eQSBTCMessageType_Ticker = 0,
	eQSBTCMessageType_Trade,
	eQSBTCMessageType_Depth,
};
