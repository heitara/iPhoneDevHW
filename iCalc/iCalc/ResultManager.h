//
//  ResultManager.h
//  iCalc
//
//  Created by M on 11/16/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HistoryStack.h"
#import "BasicCalculator.h"

@interface ResultManager : NSObject


-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *) context;
-(void)saveAndCleanup:(BCOperator)currentOperation firstOperand:(NSNumber *)theFirstOperand numberOnCalculatorScreen:(NSNumber *) calculatorScreen decimalPlaces:(int) decimalPlaces typingOfSecondOperandHasBegan:(BOOL) secondOperandHasBeganTypingIfNotNoOp;
//@property (strong) NSNumber *lastOperand;
//@property (strong) NSNumber *lastResult;
@property NSNumber *operation;
@property NSNumber *firstOperand;
@property NSNumber *onScreenOperand;
@property NSNumber *decimalPlaces;
@property BOOL textShouldBeCleard;

-(NSString *)decrementCounterAndReturnStoredValue;
-(NSString *)incrementCounterAndReturnStoredValue;
-(void) saveToFile;
-(int) getLeftSize;
-(int) getRightSize;
@end
