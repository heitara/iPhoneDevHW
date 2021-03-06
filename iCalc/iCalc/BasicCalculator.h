//
//  BasicCalculator.h
//  iCalc
//
//  Created by Florian Heller on 10/22/10.
//  Modified by Chat Wacharamanotham on 11.11.13.
//  Copyright 2010 RWTH Aachen University. All rights reserved.
//

#import <Foundation/Foundation.h>

//This is the set of operations we support
typedef enum BCOperator : NSUInteger {
	BCOperatorNoOperation = 201,
	BCOperatorAddition = 202,
	BCOperatorSubtraction = 203,
	BCOperatorMultiplication = 204,
	BCOperatorDivision = 205
} BCOperator;
//BCOperatorNoOperation is set as the default value for the Operator stored in NSUserDefault
//The rest of the operations number corresponds to their tag in the Xib

@protocol BasicCalculatorDelegate <NSObject>    // Task 1.2 make ViewController comply with this delegate

- (void)operationDidCompleteWithResult:(NSNumber*)result;

@end



@protocol PrimeCalculatorDelegate <NSObject>    // Task 2.1 use these two methods to inform the ViewController of the prime calculation.

@optional
- (void)willPrimeCheckNumber:(NSNumber *)theNumber;

@required
- (void)didPrimeCheckNumber:(NSNumber *)theNumber result:(BOOL)theIsPrime;

@end


// Task 1.1: Implement the model class
@interface BasicCalculator : NSObject 

@property (assign) BOOL rememberLastResult;
@property (strong) id<BasicCalculatorDelegate> delegate;
@property (strong) id<PrimeCalculatorDelegate> primeDelegate;
@property (strong) NSNumber *lastOperand;
@property (strong) NSNumber *lastResult;        // Task 1.3: Use this property for KVO


- (void)setFirstOperand:(NSNumber*)anOperand;
- (NSNumber *)getOperand;
- (void)performOperation:(BCOperator)operation withOperand:(NSNumber*)operand;
- (void)reset;



//public interface
- (BOOL)checkPrime:(NSInteger)theInteger;
- (void)checkByGCDifAnumberIsPrime:(NSInteger *)theInteger;
- (void)checkPrimeAllowCancel:(NSInteger)theInteger;
- (void) cancelAllOperations;

@end
