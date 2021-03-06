//
//  ViewController.m
//  iCalc
//
//  Created by Florian Heller on 10/5/12.
//  Copyright (c) 2012 Florian Heller. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
	// The following variables do not need to be exposed in the public interface
	// that's why we define them in this class extension in the implementation file.
	BOOL textFieldShouldBeCleared;
    int digits;
    int decimalPlacesToCalculateWith;
    NSString *screenViewSourcefloatInNSString;
    UIColor * defaultColor;
    BCOperator currentOperation;
    BasicCalculator *calcLogic;
    ResultManager *resultManager;
}

@end

@implementation ViewController



#pragma mark - Object Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    calcLogic =[[BasicCalculator alloc] init];
    calcLogic.delegate = self;
    calcLogic.primeDelegate = self;
    resultManager=[[ResultManager alloc] init];
    currentOperation = BCOperatorNoOperation;
	textFieldShouldBeCleared = NO;
    digits = 0;
    decimalPlacesToCalculateWith=1;
    defaultColor =  [[((UIButton *)[self.view viewWithTag:BCOperatorAddition]) titleLabel] textColor];
    
    
    //[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];//deletes stored values
    //TODO comment the line above
    
    [self handleGestures];
    [self instantiateAllSavedValues];
    [self addDefaultObservers];
    
    
    [self updateArrowLabels];
    
    self.progressLabel.text = @"";
    self.progressIndicator.hidden = YES;
}


- (void)operationDidCompleteWithResult:(NSNumber*)result
{
    screenViewSourcefloatInNSString=[NSString stringWithFormat:@"%@", result];
    [self showValueWithAppropiateDecimalPlaces:[result floatValue]];
    
    
    // Reset the internal state
    currentOperation = BCOperatorNoOperation;
    [self enableOperations];
    [self updateArrowLabels];
    textFieldShouldBeCleared=YES;
}

-(BOOL) operationPressed
{
    if(currentOperation!=BCOperatorNoOperation)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)addDefaultObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(saveAndCleanup)
                                                 name: @"handleCleanup"
                                               object: nil];
    //[calcLogic addObserver:self forKeyPath:@"lastResult" options:NSKeyValueObservingOptionNew context:NULL];
    [calcLogic addObserver:resultManager forKeyPath:@"lastResult" options:NSKeyValueObservingOptionNew context:NULL];
    
}

-(void)handleGestures
{
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipeRecognizer.numberOfTouchesRequired = 1;
    
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] init];
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipeRecognizer.numberOfTouchesRequired = 1;
    [rightSwipeRecognizer addTarget:self action:@selector(handleGesture:)];
    
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
}

-(void) instantiateAllSavedValues
{
    currentOperation =[[resultManager operation] intValue];
    if(currentOperation!=BCOperatorNoOperation)
    {
        UIButton *button= (UIButton *)[self.view viewWithTag:currentOperation];
        [self operationButtonPressed:button];
    }
    
    [calcLogic setFirstOperand:[resultManager firstOperand]]; //TODO check if we need an if =0 here
    self.numberTextField.text = [[resultManager onScreenOperand] stringValue];
    decimalPlacesToCalculateWith = [[resultManager decimalPlaces] intValue];
    textFieldShouldBeCleared=[resultManager textShouldBeCleard];
}

-(void)applicationDidEnterBackground:(UIApplication *) application
{
    [resultManager saveToFile];
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
    [resultManager saveAndCleanup:currentOperation firstOperand:[calcLogic getOperand] numberOnCalculatorScreen:[NSNumber numberWithFloat:[self.numberTextField.text floatValue]] decimalPlaces:decimalPlacesToCalculateWith typingOfSecondOperandHasBegan:textFieldShouldBeCleared];
}

-(void) addDecimalPlace
{
    //TODO maybe rounding
    if(self.numberTextField.text.length>=screenViewSourcefloatInNSString.length)
    {
        if([self dotLocation]!=-1)
        {
            [self.numberTextField setText:[NSString stringWithFormat:@"%@%@",self.numberTextField.text ,@"0"]];
            
        }
        else
        {
            [self.numberTextField setText:[NSString stringWithFormat:@"%@%@",self.numberTextField.text ,@".0"]];
        }
        
        decimalPlacesToCalculateWith=[self decimalPlaces];
        return;
    }
    
    //decimalPlacesToCalculateWith=MAX([self decimalPlaces],decimalPlacesToCalculateWith);
    
    if([self dotLocation]==-1)
    {
        [self.numberTextField setText:[NSString stringWithFormat:@"%@%@",self.numberTextField.text ,@"."]];
    }
    
    [self.numberTextField setText:[screenViewSourcefloatInNSString stringByPaddingToLength:self.numberTextField.text.length+1 withString:@""  startingAtIndex:0]];
    
    decimalPlacesToCalculateWith=[self decimalPlaces];
}

-(void) removeDecimalPlace
{
    if([self dotLocation]!=-1)
    {
        if([self decimalPlaces]==1) // so remove last number and .
        {
            [self.numberTextField setText:[self.numberTextField.text stringByPaddingToLength:self.numberTextField.text.length-2 withString:@""  startingAtIndex:0]];
            decimalPlacesToCalculateWith=0;
        }
        else  //remove only last number
        {
            [self.numberTextField setText:[self.numberTextField.text stringByPaddingToLength:self.numberTextField.text.length-1 withString:@""  startingAtIndex:0]];
            if(decimalPlacesToCalculateWith!=0)
            {
                //decimalPlacesToCalculateWith=MAX([self decimalPlaces]-1,decimalPlacesToCalculateWith);
            }
        }
    }
    decimalPlacesToCalculateWith=[self decimalPlaces];
}

-(int) decimalPlaces
{
    if([self dotLocation]==-1)
    {
        return 0;
    }
    else
    {
        return self.numberTextField.text.length - self.dotLocation - 1;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private functions

- (void) enableOperations
{
    [((UIButton *)[self.view viewWithTag:BCOperatorAddition]) setTitleColor:defaultColor forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:BCOperatorSubtraction]) setTitleColor:defaultColor forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:BCOperatorDivision]) setTitleColor:defaultColor forState:UIControlStateNormal];
    [((UIButton *)[self.view viewWithTag:BCOperatorMultiplication]) setTitleColor:defaultColor forState:UIControlStateNormal];
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
    if(!(textFieldShouldBeCleared && currentOperation != BCOperatorNoOperation))
    {
        
        
        if (currentOperation==BCOperatorNoOperation )
        {
            [calcLogic setFirstOperand:[NSNumber numberWithFloat:[self.numberTextField.text floatValue]]];
            
            if([self dotLocation]==-1)
            {
                digits = self.numberTextField.text.length - 2; //TODO understand
            }
        }
        else
        {
            [self executeOperation:sender.tag withArgument:[self.numberTextField.text floatValue]];
        }
        
        textFieldShouldBeCleared = YES;
    }
    [self enableOperations];
    [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    currentOperation = sender.tag;
    
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *) context
{
    //not used here
}

- (IBAction)resultButtonPressed:(UIButton *)sender
{
    if(currentOperation != BCOperatorNoOperation && !textFieldShouldBeCleared)//second Operand is Fully Entered
    {
        [self executeOperation:currentOperation withArgument:[self.numberTextField.text floatValue]];
        
        //check if the integer part of the number is prime
        NSString * integerPart = self.numberTextField.text;
        int dotIndex = [self dotLocation];
        if(dotIndex != -1)
        {
            integerPart = [integerPart substringToIndex:dotIndex];
        }
        

        int number = [integerPart intValue];
        NSLog(@"integer part is : %d", number);
        
        //task 2.1
        //update the UI
        
        self.progressIndicator.hidden = NO;
        // task 2.1
//        if([calcLogic checkPrime:number])
//        {
//            self.progressLabel.text = [NSString stringWithFormat:@"Checking #%d is a prime.", number];
//        }
//        else
//        {
//            self.progressLabel.text = [NSString stringWithFormat:@"Checking #%d is NOT a prime.", number];
//        }
        
        
        //task 2.2 invoke async check
        //update the UI
        self.progressLabel.text = [NSString stringWithFormat:@"Checking #%d is ...", number];
        //async call, the result will be deliverd to us in
        //- (void)didPrimeCheckNumber:(NSNumber *)theNumber result:(BOOL)theIsPrime;
        [calcLogic checkByGCDifAnumberIsPrime:number];
    }
}

- (void)willPrimeCheckNumber:(NSNumber *)theNumber
{
    
}

- (void)didPrimeCheckNumber:(NSNumber *)theNumber result:(BOOL)theIsPrime
{
    self.progressIndicator.hidden = YES;
    
    if(theIsPrime)
    {
        self.progressLabel.text = [NSString stringWithFormat:@"Checking #%@ is a prime.", theNumber];
    }
    else
    {
        self.progressLabel.text = [NSString stringWithFormat:@"Checking #%@ is NOT a prime.", theNumber];
    }
}

-(void)showValueWithAppropiateDecimalPlaces:(float) value
{
    NSString *dynFmt = [NSString stringWithFormat:@"%%.%if", decimalPlacesToCalculateWith];
    self.numberTextField.text = [NSString stringWithFormat:dynFmt,value];
}


#pragma mark - arrows functions

- (IBAction)backPressed:(id)sender
{
    [self clearDisplay:(nil)];
    textFieldShouldBeCleared=YES;
    if([self.back.titleLabel.text isEqual:@"←1"])
    {
        return; // handles some weird rounding behaviour that occurs when changing the decimal places and pressing the back button
    }
    
    screenViewSourcefloatInNSString = [resultManager decrementCounterAndReturnStoredValue];
    [self showValueWithAppropiateDecimalPlaces:[screenViewSourcefloatInNSString floatValue]];
    [self updateArrowLabels];
    
}

- (IBAction)forwardPressed:(id)sender
{
    [self clearDisplay:(nil)];
    textFieldShouldBeCleared=YES;
    screenViewSourcefloatInNSString = [resultManager incrementCounterAndReturnStoredValue];
    [self showValueWithAppropiateDecimalPlaces:[screenViewSourcefloatInNSString floatValue]];
    [self updateArrowLabels];
    
}

-(void) updateArrowLabels
{
    int left = [resultManager getLeftSize];
    int right = [resultManager getRightSize];
    
    if(left)
    {
        [self.back setTitle:[NSString stringWithFormat:@"←%i", left] forState:UIControlStateNormal];
    }
    else
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

- (IBAction)numberEntered:(UIButton *)sender
{
	// If the textField is to be cleared, just replace it with the pressed number
	if (textFieldShouldBeCleared)
	{
		self.numberTextField.text = [NSString stringWithFormat:@"%i",sender.tag];
		textFieldShouldBeCleared = NO;
	}
    
	// otherwise, append the pressed number to what is already in the textField
	else {
        
        BOOL isStringEqualToZero = [@"0" isEqualToString:self.numberTextField.text];
        
        if(isStringEqualToZero && [self dotLocation]==-1)
        {
            if(sender.tag != 0)
            {
                self.numberTextField.text = [NSString stringWithFormat:@"%i", sender.tag];
            }
        }
        else
        {
            self.numberTextField.text = [self.numberTextField.text stringByAppendingFormat:@"%i", sender.tag];
        }
	}
    decimalPlacesToCalculateWith=MAX([self decimalPlaces],decimalPlacesToCalculateWith);
    screenViewSourcefloatInNSString=self.numberTextField.text;
}

// The parameter type id says that any object can be sender of this method.
// As we do not need the pointer to the clear button here, it is not really important.
- (IBAction)clearDisplay:(id)sender {
    [calcLogic reset];
	currentOperation = BCOperatorNoOperation;
	self.numberTextField.text = @"0";
    [self enableOperations];
    digits = 0;
}

- (IBAction)dotPressed:(id)sender
{
    if (textFieldShouldBeCleared)
    {
        self.numberTextField.text = @"";
        textFieldShouldBeCleared = NO;
    }
    if([self dotLocation]==-1)
    {
        if ([self.numberTextField.text  isEqual: @""])
        {
            self.numberTextField.text = @"0.";
        }
        else
        {
            self.numberTextField.text = [self.numberTextField.text stringByAppendingString:@"."];
        }
    }
}

#pragma mark - General Methods
// This method computes the result of the specified operation
// It is placed here since it is needed in two other methods
- (void)executeOperation:(int)operation withArgument:(float)secondArgument
{
    [calcLogic performOperation:operation withOperand:[NSNumber numberWithFloat:secondArgument]];
}

- (BOOL)prefersStatusBarHidden;
{
    return YES;
}

#pragma mark - shake the device methods

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        [self clearDisplay:nil];
    }
}

@end
