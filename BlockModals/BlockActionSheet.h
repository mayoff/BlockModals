/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <UIKit/UIKit.h>

typedef void (^BlockActionSheetHandler)(void);

/**
## `BlockActionSheet`

Use a `BlockActionSheet` to offer the user a small selection of actions.  `BlockActionSheet` is a subclass of `UIActionSheet`, and supports all of the features of `UIActionSheet`.  `BlockActionSheet` adds support for setting a handler block for each button.

If the user taps one of my buttons, and you have set a handler block for that button, I call the handler block **instead of** sending `actionSheet:clickedButtonAtIndex:` to my delegate.  If the user taps a button and you have **not** set a handler block for that button, I send `actionSheet:clickedButtonAtIndex:` to my delegate.

You can set my `delegate` if you want to respond to any other `UIActionSheetDelegate` messages, or if you want to respond to some buttons using `actionSheet:clickedButtonAtIndex:`.
*/

@interface BlockActionSheet : UIActionSheet

/**
I initialize myself with no delegate and no buttons.  You can set my delegate using `setDelegate:`, and you can add buttons using `addButtonWithTitle:handler:` and `addButtonWithTitle:`.  You can assign button indexes to my `cancelButtonIndex` and `destructiveButtonIndex` properties to give me cancel and destructive buttons, if you need them.
*/
- (id)initWithTitle:(NSString *)title;

/**
I set the handler for the button at index `buttonIndex` to `handler`.  If I already had a handler for that button, I discard the old handler.  If `handler` is nil, I just discard the existing handler for the button, if I have one.
*/
- (void)setHandler:(BlockActionSheetHandler)handler forButtonAtIndex:(NSInteger)buttonIndex;

/**
Convenience method for adding a button and setting its handler.  I add a button titled `title` and set its handler to `handler`.  If `handler` is nil, I just add the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockActionSheetHandler)handler;

/**
I return the handler for the button at index `buttonIndex`, or nil if no handler is set.
*/
- (BlockActionSheetHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex;

@end
