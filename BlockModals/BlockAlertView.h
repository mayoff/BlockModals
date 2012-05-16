/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import <UIKit/UIKit.h>

typedef void (^BlockAlertViewHandler)(void);

typedef enum {
    BlockAlertViewClickedPhase,
    BlockAlertViewDidDismissPhase
} BlockAlertViewPhase;

/**
## `BlockAlertView`

Use me to display an alert message to the user.  I am a subclass of `UIAlertView`, and I support all of the features of `UIAlertView`.  I add support for setting a handler block for each button.  You can set a block for each button, for each phase of button handling.

The first phase is `BlockAlertViewClickedPhase`, which is when I send `alertView:clickedButtonAtIndex:` to my delegate.  If you set a block for a button for this phase, and the user taps the button, then I invoke the block **instead of** sending `alertView:clickedButtonAtIndex:` to my delegate.

The second phase is `BlockAlertViewDidDismissPhase`, which is when I send `alertView:didDismissWithButtonIndex:` to my delegate.  if you set a block for a button for this phase, and the user taps the button, then I invoke the block **instead of ** sending `alertView:didDismissWithButtonIndex:` to my delegate.

If the user taps a button, and I don't have a block set for that button for some phase, then during that phase, I send the appropriate message to my delegate.

You can set my `delegate` if you want to respond to any other `UIAlertViewDelegate` messages, or if you want to respond to some buttons using the normal delegate methods.
*/

@interface BlockAlertView : UIAlertView

/**
I initialize myself with no delegate and no buttons.  You can set my delegate using `setDelegate:`, and you can add buttons using `addButtonWithTitle:phase:handler:`, `addButtonWithTitle:handler:` and `addButtonWithTitle:`.  You can assign a button index to my `cancelButtonIndex` property to give me a cancel button, if you need one.
*/
- (id)initWithTitle:(NSString *)title message:(NSString *)message;

/**
I set the handler for the button at index `buttonIndex` for phase `phase` to `handler`.  If `handler` is nil, I discard any existing handler for the button for that phase.
*/
- (void)setButtonAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase handler:(BlockAlertViewHandler)handler;

/**
Convenience method for adding a button and setting its handler.  I add a button titled `title` and set its handler for `BlockAlertViewClickedPhase` to `handler`.  If `handler` is nil, I just add the button.  I return the index of the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockAlertViewHandler)handler;

/**
Convenience method for adding a button and setting one of its handlers.  I add a button titled `titl` and set its handler for phase `phase` to `handler`.  If `handler` is nil, I just add the button.  I return the index of the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title phase:(BlockAlertViewPhase)phase handler:(BlockAlertViewHandler)handler;

/**
I return the handler for the button at index `buttonIndex` for phase `phase`, or nil if no handler is set.
*/
- (BlockAlertViewHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase;

@end
