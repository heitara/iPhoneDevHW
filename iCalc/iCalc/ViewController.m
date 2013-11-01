//
//  ViewController.m
//  iCalc
//
//  Created by Florian Heller on 10/5/12.
//  Copyright (c) 2012 Florian Heller. All rights reserved.
//

// Define operation identifiers
#define OP_NOOP	0
#define OP_ADD	11
#define OP_SUB	12
#define OP_MUL	13
#define OP_DIV	14
#define OP_EQ	100


#import "ViewController.h"
#import "HistoryStack.h"

@interface ViewController ()
{
	// The following variables do not need to be exposed in the public interface
	// that's why we define them in this class extension in the implementation file.
	float firstOperand;
	unsigned char currentOperation;
	BOOL textFieldShouldBeCleared;
    BOOL isDotPressed;
    int digits;
    int decimalPlacesToCalculateWith;
    
    HistoryStack * history;
}

@end

@implementation ViewController

#pragma mark - Object Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
	currentOperation = OP_NOOP;
	textFieldShouldBeCleared = NO;
    isDotPressed = NO;
    digits = 0;
    decimalPlacesToCalculateWith=1;

    
    history = [[HistoryStack alloc] init];
    
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.numberOfTouchesRequired = 1;
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] init];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.numberOfTouchesRequired = 1;
    [rightSwipeRecognizer addTarget:self action:@selector(handleGesture:)];
    
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    
    self.numberTextField.text=[[NSUserDefaults standardUserDefaults] stringForKey:@"CalulatorText"];
    
    if([self dotLocation]!=-1)
    {
        isDotPressed=YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(saveAndCleanup)
                                                 name: @"handleCleanup"
                                               object: nil];
    //TODO use dot places
    //[[NSUserDefaults standardUserDefaults] integerForKey:@"CalulatorDecimal"];
    
    
    UIApplication *app = [UIApplication sharedApplication];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:app];
    
    NSLog(@"load from file");
    [history  loadFromFile];
    [self updateArrowLabels];

}

-(void)applicationDidEnterBackground:(UIApplication *) application
{
    NSLog(@"save to file");
    [history  saveToFile];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer;
{
    // ignore other gesture recognizer
    if (![gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]])
    {
        return;
    }
    
    UISwipeGestureRecognizer *swipeRecognizer = (UISwipeGestureRecognizer *)gestureRecognizer;
    
    switch (swipeRecognizer.direction)
    {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            [self removeDecimalPlace];
            break;
        }
        case  UISwipeGestureRecognizerDirectionRight:
        {
            [self addDecimalPlace];
            break;
        }
        default:
            break;
    }
}

-(NSInteger) dotLocation
{
    if ([self.numberTextField.text rangeOfString:@"."].location == NSNotFound)
    {
        return -1;
    }
    return [self.numberTextField.text rangeOfString:@"."].location;
}

-(void)saveAndCleanup
{
    [[NSUserDefaults standardUserDefaults] setObject:self.numberTextField.text
                                              forKey:@"CalulatorText"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[self decimalPlaces]]
                                              forKey:@"CalulatorDecimal"];
}

-(void) addDecimalPlace
{
    if([self dotLocation]!=-1)
    {
        //TODO implemenet
        
        [self.numberTextField setText:[NSString stringWithFormat:@"%@%@",self.numberTextField.text ,@"0"]];
    }
    else
    {
        [self.numberTextField setText:[NSString stringWithFormat:@"%@%@",self.numberTextField.text ,@".0"]];
        
    }
}
-(void) removeDecimalPlace
{
    if([self dotLocation]!=-1)
    {
        if([self decimalPlaces]==1)
        {
           [self.numberTextField setText:[self.numberTextField.text stringByPaddingToLength:self.numberTextField.text.length-2 withString:@""  startingAtIndex:0]];
        }
        else
        {
            [self.numberTextField setText:[self.numberTextField.text stringByPaddingToLength:self.numberTextField.text.length-1 withString:@""  startingAtIndex:0]];
        }
    }
}

-(NSInteger) decimalPlaces
{
    return self.numberTextField.text.length - self.dotLocation - 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private functions

- (void) enableOperations
{
    ((UIButton *)[self.view viewWithTag:OP_ADD]).enabled = YES;
    ((UIButton *)[self.view viewWithTag:OP_SUB]).enabled = YES;
    ((UIButton *)[self.view viewWithTag:OP_DIV]).enabled = YES;
    ((UIButton *)[self.view viewWithTag:OP_MUL]).enabled = YES;
    ((UIButton *)[self.view viewWithTag:OP_EQ]).enabled = YES;
}

#pragma mark - UI response operations
/*	This method get's called whenever an operation button is pressed
 *	The sender object is a pointer to the calling button in this case. 
 *	This way, you can easily change the buttons color or other properties
 */
- (IBAction)operationButtonPressed:(UIButton *)sender {
	// Have a look at the tag-property of the buttons calling this method
	
	// Once a button is pressed, we check if the first operand is zero
	// If so, we can start a new calculation, otherwise, we replace the first operand with the result of the operation
	if (firstOperand == 0.)
	{
		firstOperand = [self.numberTextField.text floatValue];
        [self enableOperations];
		currentOperation = sender.tag;
        sender.enabled = NO;
        
        if(isDotPressed)
        {
            digits = self.numberTextField.text.length - 2;
        }

	}
	else
	{
		firstOperand = [self executeOperation:currentOperation withArgument:firstOperand andSecondArgument:[self.numberTextField.text floatValue]];
        [self enableOperations];
		currentOperation = sender.tag;
        sender.enabled = NO;
        //self.numberTextField.text = [NSString stringWithFormat:@"%%@f",decimalPlacesToCalculateWith]; not working yet
		self.numberTextField.text = [NSString stringWithFormat:@"%2f",firstOperand];
		// The previous line does exactly the same as
		// [self.numberTextField setText:[NSString stringWithFormat:@"%.1f",firstOperand]];
        
        

	}
	textFieldShouldBeCleared = YES;
    isDotPressed = NO;
}

- (IBAction)resultButtonPressed:(UIButton *)sender {
	
	// Just calculate the result
    
	float result = [self.numberTextField.text floatValue];
    if(currentOperation != OP_NOOP)
    {
        result = [self executeOperation:currentOperation withArgument:firstOperand andSecondArgument:[self.numberTextField.text floatValue]];
        self.numberTextField.text = [NSString stringWithFormat:@"%.2f",result];
    }
    //put the result in the history
    [history addValue:[NSNumber numberWithFloat:result]];

	// Reset the internal state
	currentOperation = OP_NOOP;
	firstOperand = 0.;
    [self enableOperations];
    
    [self updateArrowLabels];
//    sender.enabled = NO;

}

#pragma mark - arrows functions

- (IBAction)backPressed:(id)sender
{
    if([history getCount])
    {
        [history left];
        NSString * result = (NSString*)[history getCurrent];
        self.numberTextField.text = [NSString stringWithFormat:@"%@",result];
        [self updateArrowLabels];
    }
}

- (IBAction)forwardPressed:(id)sender {
    if([history getCount])
    {
        [history right];
        NSString * result = (NSString*)[history getCurrent];
        self.numberTextField.text = [NSString stringWithFormat:@"%@",result];

        [self updateArrowLabels];
    }
}

-(void) updateArrowLabels
{
    int left = [history getLeftSize];
    int right = [history getRightSize];
    if(left)
    {
        [self.back setTitle:[NSString stringWithFormat:@"←%i", left] forState:UIControlStateNormal];
    } else
    {
        [self.back setTitle:[NSString stringWithFormat:@"←"] forState:UIControlStateNormal];
    }
    
    if(right)
    {
        [self.forward setTitle:[NSString stringWithFormat:@"%i→", right] forState:UIControlStateNormal];
    } else
    {
       [self.forward setTitle:[NSString stringWithFormat:@"→"] forState:UIControlStateNormal];
    }
    
    
    
}

- (IBAction)numberEntered:(UIButton *)sender {
	// If the textField is to be cleared, just replace it with the pressed number
	if (textFieldShouldBeCleared)
	{
		self.numberTextField.text = [NSString stringWithFormat:@"%i",sender.tag];
		textFieldShouldBeCleared = NO;
	}
	// otherwise, append the pressed number to what is already in the textField
	else {
        
        BOOL isStringEqualToZero = [@"0" isEqualToString:self.numberTextField.text];
        
        if(isStringEqualToZero && !isDotPressed)
        {
            //do nothing
            if(sender.tag != 0)
            {
                 self.numberTextField.text = [NSString stringWithFormat:@"%i", sender.tag];
            }
//            else
//            {
//                //zero, do nothing
//            }
            
        }
        else
        {
            self.numberTextField.text = [self.numberTextField.text stringByAppendingFormat:@"%i", sender.tag];
        }
	}
}

// The parameter type id says that any object can be sender of this method.
// As we do not need the pointer to the clear button here, it is not really important.
- (IBAction)clearDisplay:(id)sender {
	firstOperand = 0;
	currentOperation = OP_NOOP;
	self.numberTextField.text = @"0";
    [self enableOperations];
    isDotPressed = NO;
    digits = 0;
}

- (IBAction)dotPressed:(id)sender
{
    if(!isDotPressed)
    {
        isDotPressed = YES;
        self.numberTextField.text = [self.numberTextField.text stringByAppendingString:@"."];
    }
}

#pragma mark - General Methods
// This method returns the result of the specified operation
// It is placed here since it is needed in two other methods
- (float)executeOperation:(char)operation withArgument:(float)firstArgument andSecondArgument:(float)secondArgument;
{
	switch (operation) {
		case OP_ADD:
			return firstArgument + secondArgument;
			break;
		case OP_SUB:
			return firstArgument - secondArgument;
            
        case OP_DIV:
            if(secondArgument == 0) return 0;
			return firstArgument / secondArgument;
            
        case OP_MUL:
            return firstArgument * secondArgument;
		default:
			return NAN;
			break;
	}
}

- (BOOL)prefersStatusBarHidden;
{
    return YES;
}
@end
