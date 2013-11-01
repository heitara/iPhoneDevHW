//
//  HistoryStack.h
//  iCalc
//
//  Created by Emil Atanasov on 11/1/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistoryStack : NSObject

-(id) initWithCapacity:(int) capacity;
-(void) addValue: (NSObject *) value;
-(NSObject *) getLast;
-(NSObject *) getCurrent;
-(void) last;
-(void) left;
-(void) right;
-(int) getCount;
-(int) getLeftSize;
-(int) getRightSize;


-(void) saveToFile;
-(void) loadFromFile;

@end
