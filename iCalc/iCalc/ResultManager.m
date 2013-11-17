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
	}
	return self;
}


-(void) saveToFile
{
    NSLog(@"save to file");
    [history  saveToFile];
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

@end
