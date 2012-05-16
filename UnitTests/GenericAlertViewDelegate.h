/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import <Foundation/Foundation.h>

@interface GenericAlertViewDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) NSCountedSet *clickedButtonIndexes_expected; // defaults to empty
@property (nonatomic) BOOL willPresentAlertView_expected;  // defaults to YES
@property (nonatomic) BOOL didPresentAlertView_expected; // defaults to YES
@property (nonatomic, copy) NSCountedSet *willDismissWithButtonIndexes_expected; // defaults to empty
@property (nonatomic, copy) NSCountedSet *didDismissWithButtonIndexes_expected; // defaults to empty

@property (nonatomic, readonly) NSCountedSet *clickedButtonIndexes_actual;
@property (nonatomic, readonly) BOOL willPresentAlertView_actual;
@property (nonatomic, readonly) BOOL didPresentAlertView_actual;
@property (nonatomic, readonly) NSCountedSet *willDismissWithButtonIndexes_actual;
@property (nonatomic, readonly) NSCountedSet *didDismissWithButtonIndexes_actual;

+ (GenericAlertViewDelegate *)delegateExpectingNoButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in willDismiss
+ (GenericAlertViewDelegate *)delegateExpectingButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in clicked, willDismiss, didDismiss
+ (GenericAlertViewDelegate *)delegateExpectingClickedButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in clicked, willDismiss
+ (GenericAlertViewDelegate *)delegateExpectingDidDismissButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in didDismiss, willDismiss

@end
