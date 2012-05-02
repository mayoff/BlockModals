/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "GenericActionSheetDelegate.h"

@implementation GenericActionSheetDelegate

@synthesize clickedButtonIndexes_actual = _clickedButtonIndexes_actual;
@synthesize clickedButtonIndexes_expected = _clickedButtonIndexes_expected;
@synthesize didDismissWithButtonIndexes_actual = _didDismissWithButtonIndexes_actual;
@synthesize didPresentActionSheet_actual = _didPresentActionSheet_actual;
@synthesize didPresentActionSheet_expected = _didPresentActionSheet_expected;
@synthesize dismissWithButtonIndexes_expected = _dismissWithButtonIndexes_expected;
@synthesize willDismissWithButtonIndexes_actual = _willDismissWithButtonIndexes_actual;
@synthesize willPresentActionSheet_actual = _willPresentActionSheet_actual;
@synthesize willPresentActionSheet_expected = _willPresentActionSheet_expected;

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
