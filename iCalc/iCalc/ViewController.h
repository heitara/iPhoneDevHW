//
//  ViewController.h
//  iCalc
//
//  Created by Florian Heller on 10/5/12.
//  Copyright (c) 2012 Florian Heller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCalculator.h"
#import "ResultManager.h"
@interface ViewController : UIViewController<BasicCalculatorDelegate>

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;

- (IBAction)operationButtonPressed:(UIButton *)sender;
- (IBAction)resultButtonPressed:(UIButton *)sender;
- (IBAction)numberEntered:(UIButton *)sender;
- (IBAction)clearDisplay:(id)sender;
- (IBAction)dotPressed:(id)sender;
- (void)operationDidCompleteWithResult:(NSNumber*)result;



@property (weak, nonatomic) IBOutlet UIButton *back;
@property (weak, nonatomic) IBOutlet UIButton *forward;


@end
