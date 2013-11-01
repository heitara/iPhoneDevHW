//
//  HistoryStack.m
//  iCalc
//
//  Created by Emil Atanasov on 11/1/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import "HistoryStack.h"
#define DEFAULT_CAPACITY 10

@interface HistoryStack()
{
    int _capacity;
    int _currentIndex;
    NSMutableArray * stack;
}

@end

@implementation HistoryStack

-(id) init
{
    if(self = [super init])
    {
        _capacity = DEFAULT_CAPACITY;
        _currentIndex = 0;
        stack = [[NSMutableArray alloc] init];
    }
    
    return self;
    
}

-(id) initWithCapacity:(int) capacity
{
    if(self = [super init])
    {
        _capacity = capacity;
        _currentIndex = 0;
        stack = [[NSMutableArray alloc] init];
    }

    return self;
    
}

-(void) addValue: (NSObject *) value
{
    if (stack.count == _capacity)
    {
        [stack removeObjectAtIndex:0];
    }
    
    [stack addObject:value];
    [self last];
    
}

-(NSObject *) getLast
{
    if(stack.count)
    {
        NSNumber * v = [stack objectAtIndex:stack.count - 1];
        return v;
    }
    
    return nil;
}

-(NSObject *) getCurrent
{
    if(stack.count && _currentIndex >= 0)
    {
        NSNumber * v = [stack objectAtIndex:_currentIndex];
        return v;
    }
    
    return nil;
}

-(void) last
{
    _currentIndex = stack.count - 1;

}

-(void) left
{
    _currentIndex = _currentIndex - 1;
    if(_currentIndex < 0)
    {
        _currentIndex = 0;
    }
}

-(void) right
{
    _currentIndex = _currentIndex + 1;
    if(_currentIndex >= stack.count)
    {
        _currentIndex = stack.count - 1;
    }
}


-(int) getCount
{
    return stack.count;
}

@end
