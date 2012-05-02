/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "GenericAlertViewDelegate.h"

@implementation GenericAlertViewDelegate
@synthesize clickedButtonIndexes_expected = _clickedButtonIndexes_expected;
@synthesize dismissWithButtonIndexes_expected = _dismissWithButtonIndexes_expected;
@synthesize willPresentAlertView_expected = _willPresentAlertView_expected;
@synthesize didPresentAlertView_expected = _didPresentAlertView_expected;
@synthesize clickedButtonIndexes_actual = _clickedButtonIndexes_actual;
@synthesize didDismissWithButtonIndexes_actual = _didDismissWithButtonIndexes_actual;
@synthesize didPresentAlertView_actual = _didPresentAlertView_actual;
@synthesize willDismissWithButtonIndexes_actual = _willDismissWithButtonIndexes_actual;
@synthesize willPresentAlertView_actual = _willPresentAlertView_actual;

- (id)init {
    if (!(self = [super init]))
        return nil;

    _clickedButtonIndexes_expected = [NSCountedSet set];
    _dismissWithButtonIndexes_expected = [NSCountedSet set];

    _clickedButtonIndexes_actual = [NSCountedSet set];
    _willDismissWithButtonIndexes_actual = [NSCountedSet set];
    _didDismissWithButtonIndexes_actual = [NSCountedSet set];

    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_clickedButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    _willPresentAlertView_actual = YES;
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    _didPresentAlertView_actual = YES;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_willDismissWithButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_didDismissWithButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

@end
