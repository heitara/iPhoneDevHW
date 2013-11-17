//
//  BasicCalculator.m
//  iCalc
//
//  Created by Florian Heller on 10/22/10.
//  Modified by Chat Wacharamanotham on 11.11.13.
//  Copyright 2010 RWTH Aachen University. All rights reserved.
//


#import "BasicCalculator.h"
#define MAX_NUMBER_OF_QUEUES 3

@interface BasicCalculator ()
{
	// The following variables do not need to be exposed in the public interface
	// that's why we define them in this class extension in the implementation file.
    NSOperationQueue* _queue;
    NSMutableArray * _arrayOfQueues;
    int _qIndex;
	NSOperation * _lastOp;
}

@end

#pragma mark Object Lifecycle
@implementation BasicCalculator


- (id)init
{
	self = [super init];
	if (self != nil) {
		self.lastOperand = [NSNumber numberWithInt:0];
		self.delegate = nil;
		self.rememberLastResult = YES;
        
	}
	return self;
}

- (void)dealloc
{
	//With synthesized setters, you set the object to nil to release it
	//If delegate would be just a simple ivar, we would call [delegate release];
	self.delegate = nil;
	self.lastOperand = nil;
}


#pragma mark Method implementation
//Set our lastOperand cache to be another operand
- (void)setFirstOperand:(NSNumber*)anOperand;
{
	self.lastOperand = anOperand;
}

- (NSNumber *)getOperand
{
	return self.lastOperand;
}

// This method performs an operation with the given operation and the second operand. 
// After the operation is performed, the result is written to lastOperand 
- (void)performOperation:(BCOperator)operation withOperand:(NSNumber*)operand;
{
	NSNumber *result;
	if (operation == BCOperatorAddition)
	{
		result = [NSNumber numberWithFloat:([self.lastOperand floatValue] + [operand floatValue])]; //this is autoreleased
	}
    else if (operation == BCOperatorDivision)
	{
		result = [NSNumber numberWithFloat:([self.lastOperand floatValue] / [operand floatValue])]; //this is autoreleased
	}
    else if (operation == BCOperatorMultiplication)
	{
		result = [NSNumber numberWithFloat:([self.lastOperand floatValue] * [operand floatValue])]; //this is autoreleased
	}
    else if (operation == BCOperatorSubtraction)
	{
		result = [NSNumber numberWithFloat:([self.lastOperand floatValue] - [operand floatValue])]; //this is autoreleased
	}
    else if (operation == BCOperatorNoOperation)
	{
		return;
	}
	
    self.lastOperand = result; //Since NSNumber is immutable, no side-effects. Memory management is done in the setter
    self.lastResult=result; //to make using KVO PAttern possible. So that Result manager can observe this property
    
	// Now call the delegate method with the result. If the delegate is nil, this will just do nothing.
	if (_delegate != nil) {
		if ([_delegate respondsToSelector:@selector(operationDidCompleteWithResult:)])
		{
			[_delegate operationDidCompleteWithResult:result];
		}
		else {
			NSLog(@"WARNING: the BasicCalculator delegate does not implement operationDidCompleteWithResult:");
		}
	}
	else {
		NSLog(@"WARNING: the BasicCalculator delegate is nil");
	}
}

// This method clears everything (for the moment 
- (void)reset;
{
	self.lastOperand = [NSNumber numberWithInt:0];
}

// The following method is shamelessly modified from http://www.programmingsimplified.com/c/source-code/c-program-for-prime-number
- (BOOL)checkPrime:(NSInteger)theInteger
{
    NSInteger checkValue;
    BOOL result;
        
    for (checkValue = 2 ; checkValue <= theInteger - 1 ; checkValue++)
    {
        if (theInteger % checkValue == 0)
        {
            result = NO;
            break;
        }
        
         sleep(1);    // uncomment this line to make the execution significantly longer for a more dramatic effect :D
    }
    if (checkValue == theInteger)
    {
        result = YES;
    }
    
    return result;
}


// -----------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark part 2
 // NOTE: you may change the signature of the following methods. Just keep the given name as a substring.
// -----------------------------------------------------------------------------------------------------------------

- (void)checkByGCDifAnumberIsPrime:(NSInteger *)theInteger;
{
    // Task 2.2
    
    //pass the task to the GCD
    NSNumber *number = [NSNumber numberWithInt:theInteger];
    dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(aQueue, ^{
        
        BOOL isPrime = [self checkPrime:theInteger];
        

        
        if(self.primeDelegate)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                
                //dispatch the result to the main thread
                [self.primeDelegate didPrimeCheckNumber:number  result:isPrime];
                
            });
                           
    
        }
        
    });
    
}

- (void)checkByOpQueue: (NSInteger *) theInteger
{
    // Task 2.3
    if (!_queue) {
        //lasy initialization
        [self createQueue];
    }
    
    //cancel all previous opperations
    [_queue cancelAllOperations];
    
    //create new op and add it in to the queue
    NSOperation * op = [self primeOperationWithNumber:theInteger];
    [_queue addOperation:op];
}

- (NSOperation*)primeOperationWithNumber:(NSInteger *)theInteger {
    
    NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock: ^{
        
        [self notifyPrimeDelegateThatCheckOfANumberBegins:theInteger];
        
        NSNumber *number = [NSNumber numberWithInt:theInteger];
        BOOL isPrime = [self checkPrime:number];
        
        if(self.primeDelegate)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                
                //dispatch the result to the main thread
                [self.primeDelegate didPrimeCheckNumber:number  result:isPrime];
                
            });
            
            
        }
        
        
    }];
    
    return op;
    
}
//checkPrimeAllowCancel:

- (NSOperation*)primeCancellabeOperationWithNumber:(NSInteger *)theInteger {
    
    NSBlockOperation *op = [[NSBlockOperation alloc] init];
    //be carefull with our memory menegment
    __weak NSBlockOperation *weakOperation = op;
    
    [op addExecutionBlock: ^{
        
        NSNumber *number = [NSNumber numberWithInt:theInteger];
        BOOL isPrime = NO;
        
        [self notifyPrimeDelegateThatCheckOfANumberBegins:theInteger];
        
        //prime
        int integerValue = theInteger;
        NSInteger checkValue;
        
        for (checkValue = 2 ; checkValue <= integerValue - 1 ; checkValue++)
        {
            if([weakOperation isCancelled])
            {
                //operation was cannceled and we should break the loop
                break;
            }
            if (integerValue % checkValue == 0)
            {
                isPrime = NO;
                break;
            }
            
            sleep(1);    // uncomment this line to make the execution significantly longer for a more dramatic effect :D
        }
        
        if (checkValue == integerValue)
        {
            isPrime = YES;
        }
        
        // we will report that the integer is not prime if the operation was canceled.
        if(isPrime)
        {
            NSLog(@"The number %@ is prime.", number);
        }
        else
        {
            NSLog(@"The number %@ is NOT prime.", number);
        }
        
        
        if(self.primeDelegate)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                
                //dispatch the result to the main thread
                [self.primeDelegate didPrimeCheckNumber:number  result:isPrime];
                
            });
            
            
        }
        
        
    }];
    
    return op;
    
}

-(void) notifyPrimeDelegateThatCheckOfANumberBegins:(NSInteger *)theInteger
{
    if(self.primeDelegate)
    {
        if([self.primeDelegate respondsToSelector:@selector(willPrimeCheckNumber:)])
        {
            NSNumber *number = [NSNumber numberWithInt:theInteger];
            //the delegate can respond to this selector, so notify it
            [self.primeDelegate willPrimeCheckNumber: number];
        }
    }
}


- (void) createQueue
{
    _queue = [[NSOperationQueue alloc] init];
}

- (void)checkPrimeAllowCancel:(NSInteger)theInteger;
{
    // Task 2.4
    //we use a operation which could be cannceled and the process of checking if a number is prime is canncelable
    // chech this method - (NSOperation*)primeCancellabeOperationWithNumber:(NSInteger *)theInteger
    if (!_queue) {
        //lasy initialization
        [self createQueue];
    }
    
    //cancel all previous opperations
    [_queue cancelAllOperations];
    
    //create new op and add it in to the queue
    NSOperation * op = [self primeCancellabeOperationWithNumber:theInteger];
    [_queue addOperation:op];
}

- (void) cancelAllOperations
{
    [_queue cancelAllOperations];
}

-(void) lazyInitSeveralQueues
{
    if(!_arrayOfQueues)
    {
        //get it's size
        int size = MAX_NUMBER_OF_QUEUES;
        _qIndex = 0;
        _arrayOfQueues = [[NSMutableArray alloc] init];
        for(int i = 0; i < size; i++)
        {
            [_arrayOfQueues insertObject:[[NSOperationQueue alloc] init] atIndex:i];
        }
    }
}

- (void)checkPerserveOrder:(NSInteger *) theInteger
{
    // Task 2.5 (extra credit)
    //allocate array of queues
    [self lazyInitSeveralQueues];
    
    //get a queue
    NSOperationQueue * q = _arrayOfQueues[_qIndex];
    

    
    NSOperation * op = [self primeCancellabeOperationWithNumber:theInteger];
    //chain only those operation which are not finished and are not cancelled
    if(_lastOp && ![_lastOp isFinished] && ![_lastOp isCancelled])
    {
        [op addDependency:_lastOp];
    }
    
    [q addOperation:op];
    
    _lastOp = op;
    
    // move to the next queue
    _qIndex = (_qIndex + 1) % MAX_NUMBER_OF_QUEUES;
}

@end
