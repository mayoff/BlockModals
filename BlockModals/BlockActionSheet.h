/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import <UIKit/UIKit.h>

typedef void (^BlockActionSheetHandler)(void);

typedef enum {
    BlockActionSheetClickedPhase,
    BlockActionSheetDidDismissPhase
} BlockActionSheetPhase;

/**
## `BlockActionSheet`

Use me to offer the user a small selection of actions.  I am a subclass of `UIActionSheet`, and I support all of the features of `UIActionSheet`.  I add support for setting handler blocks for each button.  You can set a block for each button, for each phase of button handling.

The first phase is `BlockActionSheetClickedPhase`, which is when I send `actionSheet:clickedButtonAtIndex:` to my delegate.  If you set a block for a button for this phase, and the user taps the button, then I invoke the block **instead of** sending `actionSheet:clickedButtonAtIndex:` to my delegate.

The second phase is `BlockActionSheetDidDismissPhase`, which is when I send `actionSheet:didDismissWithButtonIndex:` to my delegate.  If you set a block for a button for this phase, and the user taps the button, then I invoke the block **instead of** sending `actionSheet:didDismissWithButtonIndex:` to my delegate.

If the user taps a button, and I don't have a block set for that button for some phase, then during that phase, I send the appropriate message to my delegate.

You can set my `delegate` if you want to respond to any other `UIActionSheetDelegate` messages, or if you want to respond to some buttons using the normal delegate methods.
*/

@interface BlockActionSheet : UIActionSheet

/**
I initialize myself with no delegate and no buttons.  You can set my delegate using `setDelegate:`, and you can add buttons using `addButtonWithTitle:phase:handler:`, `addButtonWithTitle:handler:`, and `addButtonWithTitle:`.  You can assign button indexes to my `cancelButtonIndex` and `destructiveButtonIndex` properties to give me cancel and destructive buttons, if you need them.
*/
- (id)initWithTitle:(NSString *)title;

/**
I set the handler for the button at index `buttonIndex` for phase `phase` to `handler`.  If `handler` is nil, I discard any existing handler for the button for that phase.
*/
- (void)setButtonAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase handler:(BlockActionSheetHandler)handler;

/**
Convenience method for adding a button and setting its clicked-phase handler.  I add a button titled `title` and set its handler for `BlockActionSheetClickedPhase` to `handler`.  If `handler` is nil, I just add the button.  I return the index of the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockActionSheetHandler)handler;

/**
Convenience method for adding a button and setting one of its handlers.  I add a button titled `title` and set its handler for phase `phase` to `handler`.  If `handler` is nil, I just add the button.  I return the index of the button.
*/
- (NSInteger)addButtonWithTitle:(NSString *)title phase:(BlockActionSheetPhase)phase handler:(BlockActionSheetHandler)handler;

/**
I return the handler for the button at index `buttonIndex` for phase `phase`, or nil if no handler is set.
*/
- (BlockActionSheetHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase;

@end
