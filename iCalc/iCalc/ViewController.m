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
    
    //TODO: load the stack from file
    
    history = [[HistoryStack alloc] init];

}

-(void) encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"save the history");

}

-(void) decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"load the history data");
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
		self.numberTextField.text = [NSString stringWithFormat:@"%f",firstOperand];
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
        self.numberTextField.text = [NSString stringWithFormat:@"%.1f",result];
    }
    //put the result in the history
    [history addValue:[NSNumber numberWithFloat:result]];
    [self updateArrowLabels];
	// Reset the internal state
	currentOperation = OP_NOOP;
	firstOperand = 0.;
    [self enableOperations];
//    sender.enabled = NO;

}

#pragma mark - arrows functions

- (IBAction)backPressed:(id)sender
{
    [history left];
    NSString * result = (NSString*)[history getCurrent];
    self.numberTextField.text = [NSString stringWithFormat:@"%@",result];

    [self updateArrowLabels];
    
}

- (IBAction)forwardPressed:(id)sender {
    
    [history right];
    NSString * result = (NSString*)[history getCurrent];
    self.numberTextField.text = [NSString stringWithFormat:@"%@",result];

    [self updateArrowLabels];
    
}

-(void) updateArrowLabels
{
    [self.back setTitle:[NSString stringWithFormat:@"←%i", [history getCount]] forState:UIControlStateNormal];
    [self.forward setTitle:[NSString stringWithFormat:@"%i→", [history getCount]] forState:UIControlStateNormal];
    
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
