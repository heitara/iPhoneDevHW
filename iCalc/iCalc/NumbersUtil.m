//
//  NumbersUtil.m
//  iCalc
//
//  Created by Emil Atanasov on 11/17/13.
//  Copyright (c) 2013 Lancelotmobile Ltd. All rights reserved.
//

#import "NumbersUtil.h"

@implementation NumbersUtil

+ (BOOL) isPrime: (int) number
{
    BOOL isPrime = YES;
    //dummy code which we used so far, to be slow.
    //we can replace this later with faster implementation
    if (number % 2 != 0)
    {
        if(number < 0)
        {
            number = -1 * number;
        }
        
        int sqr = sqrt(number);
        
        for(int i = 3;i < sqr;i += 2)
        {
            if(number % i == 0)
            {
                isPrime = NO;
                break;
            }
        }
    }
    else
    {
        isPrime = NO;
    }
    
    return isPrime;
}

@end
