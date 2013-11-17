//
//  ResultManager.m
//  iCalc
//
//  Created by M on 11/16/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import "ResultManager.h"


@interface ResultManager ()
{
	// The following variables do not need to be exposed in the public interface
	// that's why we define them in this class extension in the implementation file.
	
    HistoryStack *history;
}

@end
@implementation ResultManager


-(NSString *)decrementCounterAndReturnStoredValue
{
    if([history getCount])
    {
        [history left];
        return (NSString*)[history getCurrent];
    }
    return nil;
}


-(NSString *)incrementCounterAndReturnStoredValue
{
    if([history getCount])
    {
        [history right];
        return (NSString*)[history getCurrent];
    }
    return nil;
}

-(int) getLeftSize
{
    return [history getLeftSize];
}
-(int) getRightSize
{
    return [history getRightSize];
}

- (id)init
{
	self = [super init];
	if (self != nil)
    {
        history = [[HistoryStack alloc] init];
        NSLog(@"load from file");
        [history  loadFromFile];
        [self instantiateAllSavedValues];
	}
	return self;
}


-(void) saveToFile
{
    NSLog(@"save to file");
    [history  saveToFile];
}

-(void) instantiateAllSavedValues
{
    _firstOperand =[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"FirstOperandValue"]] ;
    _decimalPlaces=[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"CalulatorDecimal"]] ;
    _textShouldBeCleard = [[NSUserDefaults standardUserDefaults] boolForKey:@"textShouldBeCleared"];
    _operation = [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"Operator"]] ;
    _onScreenOperand =[NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] integerForKey:@"SecondOperandValue"]] ;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *) context
{
    float result =[[change objectForKey:@"new"] floatValue];
    if([keyPath isEqual:@"lastResult"])
    {
        //put the result in the history
        [history addValue:[NSString stringWithFormat:@"%f", result]];
    }
}


-(void)saveAndCleanup:(BCOperator)currentOperation firstOperand:(NSNumber *)theFirstOperand numberOnCalculatorScreen:(NSNumber *) calculatorScreen decimalPlaces:(int) decimalPlaces typingOfSecondOperandHasBegan:(BOOL) textShouldbeCleared
{
    //[[NSUserDefaults standardUserDefaults] setObject:self.numberTextField.text
    //                                         forKey:@"CalulatorText"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:decimalPlaces]
                                              forKey:@"CalulatorDecimal"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedChar:currentOperation]
                                              forKey:@"Operator"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:textShouldbeCleared]
                                              forKey:@"textShouldBeCleared"];

    
    
    if(currentOperation != BCOperatorNoOperation)
    {//if currentOperation is not empty we know that there first Operand is stored in getOperand
        [[NSUserDefaults standardUserDefaults] setObject:theFirstOperand
                                                  forKey:@"FirstOperandValue"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[calculatorScreen floatValue]]forKey:@"FirstOperandValue"];
    }
    
    if(currentOperation != BCOperatorNoOperation && !textShouldbeCleared) //&&!textShouldbeCleared
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[calculatorScreen floatValue]]
                                                  forKey:@"SecondOperandValue"];
        //this is done with 2 values to show the difference between two states: having 0 as the second button pressed and right after pressing the first operand
    }
}


@end
