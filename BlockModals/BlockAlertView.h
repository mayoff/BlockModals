/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import <UIKit/UIKit.h>

typedef void (^BlockAlertViewHandler)();

/**
## `BlockAlertView`

Use a `BlockAlertView` to display an alert message to the user.  `BlockAlertView` is a subclass of `UIAlertView`, and supports all of the features of `UIAlertView`.  `BlockAlertView` adds support for setting a handler block for each button.

If the user taps one of my buttons, and you have set a handler block for that button, I call the handler block **instead of** sending `alertView:clickedButtonAtIndex:` to my delegate.  If the user taps a button and you have **not** set a handler block for that button, I send `alertView:clickedButtonAtIndex:` to my delegate.

You can set my `delegate` if you want to respond to any of the non-button-related `UIAlertViewDelegate` methods, or if you want to respond to some buttons using `alertView:clickButtonAtIndex:`.
*/

@interface BlockAlertView : UIAlertView

/**
I initialize myself with no delegate and no buttons.  You can set my delegate using `setDelegate:`, and you can add buttons using `addButtonWithTitle:handler:` and `addButtonWithTitle:`.
*/
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

/**
I set the handler for the button at index `buttonIndex` to `handler`.  If I already had a handler for that button, I discard the old block.  If `handler` is nil, I just discard the existing handler for the button, if I had one.
*/
- (void)setHandler:(BlockAlertViewHandler)handler forButtonAtIndex:(NSInteger)buttonIndex;

/**
Convenience method for adding a button and setting its handler.  I add a button titled `title` and set its handler to `handler`.  If `handler` is nil, I just add the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockAlertViewHandler)handler;

/**
I return the handler for the button at index `buttonIndex`, or nil if no handler is set.
*/
- (BlockAlertViewHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex;

@end
