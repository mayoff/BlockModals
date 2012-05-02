/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <UIKit/UIKit.h>

@interface GenericActionSheetDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, copy) NSCountedSet *clickedButtonIndexes_expected;
@property (nonatomic) BOOL willPresentActionSheet_expected;
@property (nonatomic) BOOL didPresentActionSheet_expected;
@property (nonatomic, copy) NSCountedSet *dismissWithButtonIndexes_expected;

@property (nonatomic, readonly) NSCountedSet *clickedButtonIndexes_actual;
@property (nonatomic, readonly) BOOL willPresentActionSheet_actual;
@property (nonatomic, readonly) BOOL didPresentActionSheet_actual;
@property (nonatomic, readonly) NSCountedSet *willDismissWithButtonIndexes_actual;
@property (nonatomic, readonly) NSCountedSet *didDismissWithButtonIndexes_actual;

@end
