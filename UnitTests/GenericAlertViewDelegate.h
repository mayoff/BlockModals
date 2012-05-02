/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <Foundation/Foundation.h>

@interface GenericAlertViewDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy) NSCountedSet *clickedButtonIndexes_expected;
@property (nonatomic) BOOL willPresentAlertView_expected;
@property (nonatomic) BOOL didPresentAlertView_expected;
@property (nonatomic, copy) NSCountedSet *dismissWithButtonIndexes_expected;

@property (nonatomic, readonly) NSCountedSet *clickedButtonIndexes_actual;
@property (nonatomic, readonly) BOOL willPresentAlertView_actual;
@property (nonatomic, readonly) BOOL didPresentAlertView_actual;
@property (nonatomic, readonly) NSCountedSet *willDismissWithButtonIndexes_actual;
@property (nonatomic, readonly) NSCountedSet *didDismissWithButtonIndexes_actual;

@end
