/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockActionSheet.h"

@interface BlockActionSheet ()

- (BOOL)BlockActionSheet_invokeBlockForButtonAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase;

@end


@interface BlockActionSheetDelegate : NSObject <UIActionSheetDelegate> {
@package
    __unsafe_unretained BlockActionSheet *_actionSheet;
}
@end

@implementation BlockActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![_actionSheet BlockActionSheet_invokeBlockForButtonAtIndex:buttonIndex phase:BlockActionSheetClickedPhase]) {
        id userDelegate = [actionSheet delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (![_actionSheet BlockActionSheet_invokeBlockForButtonAtIndex:buttonIndex phase:BlockActionSheetDidDismissPhase]) {
        id userDelegate = [actionSheet delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [_actionSheet.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _actionSheet.delegate;
}

@end


@implementation BlockActionSheet {
    NSMutableArray *_clickedHandlers;
    NSMutableArray *_didDismissHandlers;
    BlockActionSheetDelegate *_myDelegate;
    __unsafe_unretained id<UIActionSheetDelegate> _userDelegate;
}

#pragma mark - Public API

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    [self BlockActionSheet_init];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self BlockActionSheet_init];
    return self;
}

- (id)initWithTitle:(NSString *)title {
    return [self initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
}

- (void)setDelegate:(id<UIActionSheetDelegate>)delegate {
    _userDelegate = delegate;
    super.delegate = _myDelegate;
}

- (id<UIActionSheetDelegate>)delegate {
    return _userDelegate;
}

- (BlockActionSheetHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase {
    NSMutableArray *handlers = [self BlockActionSheet_handlersForPhase:phase];
    if (buttonIndex < 0 || buttonIndex >= handlers.count)
        return nil;
    id handler = [handlers objectAtIndex:buttonIndex];
    return handler == [NSNull null] ? nil : handler;
}

- (void)setButtonAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase handler:(BlockActionSheetHandler)handler {
    NSAssert(buttonIndex >= 0 && buttonIndex < self.numberOfButtons, @"buttonIndex %d is out of range [0,%d)", buttonIndex, self.numberOfButtons);
    NSNull *null = [NSNull null];

    id handlerObject = handler;
    if (handler == nil) {
        handlerObject = null;
    } else {
        // ARC won't copy handler automatically because I'm converting it to an id.
        handlerObject = [handler copy];
    }

    NSMutableArray *handlers = [self BlockActionSheet_handlersForPhase:phase];
    for (int i = buttonIndex - handlers.count; i >= 0; --i) {
        [handlers addObject:null];
    }
    [handlers replaceObjectAtIndex:buttonIndex withObject:handlerObject];
}

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockActionSheetHandler)handler {
    return [self addButtonWithTitle:title phase:BlockActionSheetClickedPhase handler:handler];
}

- (NSInteger)addButtonWithTitle:(NSString *)title phase:(BlockActionSheetPhase)phase handler:(BlockActionSheetHandler)handler {
    NSInteger i = [self addButtonWithTitle:title];
    [self setButtonAtIndex:i phase:phase handler:handler];
    return i;
}

#pragma mark - Implementation details

- (void)BlockActionSheet_init {
    _myDelegate = [[BlockActionSheetDelegate alloc] init];
    _myDelegate->_actionSheet = self;
    super.delegate = _myDelegate;
}

- (NSMutableArray *)BlockActionSheet_handlersForPhase:(BlockActionSheetPhase)phase {
    __strong NSMutableArray **handlersPointer;
    switch (phase) {
        case BlockActionSheetClickedPhase: handlersPointer = &_clickedHandlers; break;
        case BlockActionSheetDidDismissPhase: handlersPointer = &_didDismissHandlers; break;
        default: NSAssert(YES, @"BlockActionSheet invalid phase %d", (int)phase); break;
    }
    
    if (!*handlersPointer) {
        *handlersPointer = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return *handlersPointer;
}

- (BOOL)BlockActionSheet_invokeBlockForButtonAtIndex:(NSInteger)buttonIndex phase:(BlockActionSheetPhase)phase {
    BlockActionSheetHandler handler = [self buttonHandlerAtIndex:buttonIndex phase:phase];
    if (handler) {
        handler();
        return YES;
    } else {
        return NO;
    }
}

@end
