/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <UIKit/UIKit.h>

@interface GenericActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, copy) NSCountedSet *clickedButtonIndexes_expected; // defaults to empty set
@property (nonatomic) BOOL willPresentActionSheet_expected; // defaults to YES
@property (nonatomic) BOOL didPresentActionSheet_expected; // defaults to YES
@property (nonatomic, copy) NSCountedSet *willDismissWithButtonIndexes_expected; // defaults to empty set
@property (nonatomic, copy) NSCountedSet *didDismissWithButtonIndexes_expected; // defaults to empty set

@property (nonatomic, readonly) NSCountedSet *clickedButtonIndexes_actual;
@property (nonatomic, readonly) BOOL willPresentActionSheet_actual;
@property (nonatomic, readonly) BOOL didPresentActionSheet_actual;
@property (nonatomic, readonly) NSCountedSet *willDismissWithButtonIndexes_actual;
@property (nonatomic, readonly) NSCountedSet *didDismissWithButtonIndexes_actual;

+ (GenericActionSheetDelegate *)delegateExpectingNoButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in willDismiss
+ (GenericActionSheetDelegate *)delegateExpectingButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in clicked, willDismiss, didDismiss
+ (GenericActionSheetDelegate *)delegateExpectingClickedButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in clicked, willDismiss
+ (GenericActionSheetDelegate *)delegateExpectingDidDismissButtonAtIndex:(NSInteger)buttonIndex; // puts buttonIndex in didDismiss, willDismiss

@end
