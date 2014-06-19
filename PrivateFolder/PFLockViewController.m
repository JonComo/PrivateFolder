//
//  PFLockViewController.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFLockViewController.h"

typedef enum
{
    LockStateCreate,
    LockStateConfirm,
    LockStateAttempt
} LockState;

@interface PFLockViewController () <UITextFieldDelegate>
{
    LockState state;
    
    __weak IBOutlet UILabel *labelPrompt;
    __weak IBOutlet UITextField *textFieldPassword;
    
    NSString *passcodeEntered;
}

@end

@implementation PFLockViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[PFLock shared] passcode]){
        [self setState:LockStateCreate];
    }else{
        [self setState:LockStateAttempt];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [textFieldPassword becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)passcodeEntered:(NSString *)code
{
    if (state == LockStateCreate)
    {
        passcodeEntered = code;
        [self setState:LockStateConfirm];
    }else if (state == LockStateConfirm)
    {
        if ([code isEqualToString:passcodeEntered])
        {
            //save it and unlock
            [self savePasscode:code];
        }else{
            [self incorrect];
            [self setState:LockStateCreate];
        }
    }else if (state == LockStateAttempt)
    {
        if ([code isEqualToString:[PFLock shared].passcode]){
            [self unlock];
        }else{
            [self incorrect];
        }
    }
}

-(void)setState:(LockState)newState
{
    state = newState;
    
    textFieldPassword.text = @"";
    
    if (newState == LockStateCreate)
    {
        labelPrompt.text = @"Create Passcode";
        passcodeEntered = @"";
    }else if (newState == LockStateConfirm)
    {
        labelPrompt.text = @"Reenter Passcode to Confirm";
        
    }else if (newState == LockStateAttempt)
    {
        labelPrompt.text = @"Enter Passcode";
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= 3)
    {
        NSString *completeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self passcodeEntered:completeString];
        
        textField.text = @"";
        
        return NO;
    }
    
    return YES;
}

-(void)savePasscode:(NSString *)code
{
    //Save and unlock
    
    [[NSUserDefaults standardUserDefaults] setObject:passcodeEntered forKey:PASSCODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self unlock];
}

-(void)testCode
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PASSCODE] isEqualToString:textFieldPassword.text]){
        //correct
        [self unlock];
    }else{
        [self incorrect];
    }
}

-(void)unlock
{
    [PFLock shared].isLocked = NO;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)incorrect
{
    [UIView animateWithDuration:0.05 animations:^{
        textFieldPassword.layer.transform = CATransform3DTranslate(textFieldPassword.layer.transform, -8, 0, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08 animations:^{
            textFieldPassword.layer.transform = CATransform3DTranslate(textFieldPassword.layer.transform, 16, 0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12 animations:^{
                textFieldPassword.layer.transform = CATransform3DTranslate(textFieldPassword.layer.transform, -8, 0, 0);
            } completion:^(BOOL finished) {
                textFieldPassword.text = @"";
            }];
        }];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
