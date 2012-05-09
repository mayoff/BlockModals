/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "GenericActionSheetDelegate.h"

static NSCountedSet *setWithInteger(NSInteger i) {
    return [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
}

@implementation GenericActionSheetDelegate

@synthesize willPresentActionSheet_actual = _willPresentActionSheet_actual;
@synthesize willPresentActionSheet_expected = _willPresentActionSheet_expected;
@synthesize didPresentActionSheet_actual = _didPresentActionSheet_actual;
@synthesize didPresentActionSheet_expected = _didPresentActionSheet_expected;
@synthesize clickedButtonIndexes_actual = _clickedButtonIndexes_actual;
@synthesize clickedButtonIndexes_expected = _clickedButtonIndexes_expected;
@synthesize willDismissWithButtonIndexes_expected = _willDismissWithButtonIndexes_expected;
@synthesize willDismissWithButtonIndexes_actual = _willDismissWithButtonIndexes_actual;
@synthesize didDismissWithButtonIndexes_actual = _didDismissWithButtonIndexes_actual;
@synthesize didDismissWithButtonIndexes_expected = _didDismissWithButtonIndexes_expected;

+ (GenericActionSheetDelegate *)delegateExpectingNoButtonAtIndex:(NSInteger)buttonIndex {
    GenericActionSheetDelegate *delegate = [self new];
    delegate.willDismissWithButtonIndexes_expected = setWithInteger(buttonIndex);
    return delegate;
}

+ (GenericActionSheetDelegate *)delegateExpectingClickedButtonAtIndex:(NSInteger)buttonIndex {
    GenericActionSheetDelegate *delegate = [self delegateExpectingNoButtonAtIndex:buttonIndex];
    delegate.clickedButtonIndexes_expected = delegate.willDismissWithButtonIndexes_expected;
    return delegate;
}

+ (GenericActionSheetDelegate *)delegateExpectingDidDismissButtonAtIndex:(NSInteger)buttonIndex {
    GenericActionSheetDelegate *delegate = [self delegateExpectingNoButtonAtIndex:buttonIndex];
    delegate.didDismissWithButtonIndexes_expected = delegate.willDismissWithButtonIndexes_expected;
    return delegate;
}

+  (GenericActionSheetDelegate *)delegateExpectingButtonAtIndex:(NSInteger)buttonIndex {
    GenericActionSheetDelegate *delegate = [self  delegateExpectingClickedButtonAtIndex:buttonIndex];
    delegate.didDismissWithButtonIndexes_expected = delegate.clickedButtonIndexes_expected;
    return delegate;
}

- (id)init {
    if (!(self = [super init]))
        return nil;
        
    _willPresentActionSheet_expected = YES;
    _didPresentActionSheet_expected = YES;
    _clickedButtonIndexes_expected = [NSCountedSet set];
    _didDismissWithButtonIndexes_expected = [NSCountedSet set];
    _willDismissWithButtonIndexes_expected = [NSCountedSet set];
    
    _clickedButtonIndexes_actual = [NSCountedSet set];
    _willDismissWithButtonIndexes_actual = [NSCountedSet set];
    _didDismissWithButtonIndexes_actual = [NSCountedSet set];
        
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_clickedButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_willDismissWithButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_didDismissWithButtonIndexes_actual addObject:[NSNumber numberWithInteger:buttonIndex]];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    _willPresentActionSheet_actual = YES;
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet {
    _didPresentActionSheet_actual = YES;
}

@end
