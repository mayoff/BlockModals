/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import "GenericAlertViewDelegate.h"

static NSCountedSet *setWithInteger(NSInteger i) {
    return [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
}

@implementation GenericAlertViewDelegate

@synthesize willPresentAlertView_actual = _willPresentAlertView_actual;
@synthesize willPresentAlertView_expected = _willPresentAlertView_expected;
@synthesize didPresentAlertView_actual = _didPresentAlertView_actual;
@synthesize didPresentAlertView_expected = _didPresentAlertView_expected;
@synthesize clickedButtonIndexes_actual = _clickedButtonIndexes_actual;
@synthesize clickedButtonIndexes_expected = _clickedButtonIndexes_expected;
@synthesize willDismissWithButtonIndexes_actual = _willDismissWithButtonIndexes_actual;
@synthesize willDismissWithButtonIndexes_expected = _willDismissWithButtonIndexes_expected;
@synthesize didDismissWithButtonIndexes_actual = _didDismissWithButtonIndexes_actual;
@synthesize didDismissWithButtonIndexes_expected = _didDismissWithButtonIndexes_expected;

+ (GenericAlertViewDelegate *)delegateExpectingNoButtonAtIndex:(NSInteger)buttonIndex {
    GenericAlertViewDelegate *delegate = [self new];
    delegate.willDismissWithButtonIndexes_expected = setWithInteger(buttonIndex);
    return delegate;
}

+ (GenericAlertViewDelegate *)delegateExpectingClickedButtonAtIndex:(NSInteger)buttonIndex {
    GenericAlertViewDelegate *delegate = [self delegateExpectingNoButtonAtIndex:buttonIndex];
    delegate.clickedButtonIndexes_expected = delegate.willDismissWithButtonIndexes_expected;
    return delegate;
}

+ (GenericAlertViewDelegate *)delegateExpectingDidDismissButtonAtIndex:(NSInteger)buttonIndex {
    GenericAlertViewDelegate *delegate = [self delegateExpectingNoButtonAtIndex:buttonIndex];
    delegate.didDismissWithButtonIndexes_expected = delegate.willDismissWithButtonIndexes_expected;
    return delegate;
}

+  (GenericAlertViewDelegate *)delegateExpectingButtonAtIndex:(NSInteger)buttonIndex {
    GenericAlertViewDelegate *delegate = [self  delegateExpectingClickedButtonAtIndex:buttonIndex];
    delegate.didDismissWithButtonIndexes_expected = delegate.clickedButtonIndexes_expected;
    return delegate;
}

- (id)init {
    if (!(self = [super init]))
        return nil;
        
    _willPresentAlertView_expected = YES;
    _didPresentAlertView_expected = YES;
    _clickedButtonIndexes_expected = [NSCountedSet set];
    _willDismissWithButtonIndexes_expected = [NSCountedSet set];
    _didDismissWithButtonIndexes_expected = [NSCountedSet set];

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
