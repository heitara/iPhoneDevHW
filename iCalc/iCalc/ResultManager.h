//
//  ResultManager.h
//  iCalc
//
//  Created by M on 11/16/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryStack.h"

@interface ResultManager : NSObject


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *) context;
-(NSString *)decrementCounterAndReturnStoredValue;
-(NSString *)incrementCounterAndReturnStoredValue;
-(void) saveToFile;
-(int) getLeftSize;
-(int) getRightSize;
@end
