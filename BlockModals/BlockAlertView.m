/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertView.h"

@interface BlockAlertView ()

- (BOOL)BlockAlertView_invokeBlockForButtonAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase;

@end


@interface BlockAlertViewDelegate : NSObject <UIAlertViewDelegate> {
@package
    __unsafe_unretained BlockAlertView *_alertView;
}
@end

@implementation BlockAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (![_alertView BlockAlertView_invokeBlockForButtonAtIndex:buttonIndex phase:BlockAlertViewClickedPhase]) {
        id userDelegate = [alertView delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (![_alertView BlockAlertView_invokeBlockForButtonAtIndex:buttonIndex phase:BlockAlertViewDidDismissPhase]) {
        id userDelegate = [alertView delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [_alertView.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _alertView.delegate;
}

@end

@implementation BlockAlertView {
    NSMutableArray *_clickedHandlers;
    NSMutableArray *_didDismissHandlers;
    BlockAlertViewDelegate *_myDelegate;
    __unsafe_unretained id<UIAlertViewDelegate> _userDelegate;
}

#pragma mark - Public API

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    [self initBlockAlertView];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self initBlockAlertView];
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)setDelegate:(id)delegate {
    _userDelegate = delegate;
    super.delegate = _myDelegate;
}

- (id<UIAlertViewDelegate>)delegate {
    return _userDelegate;
}

- (BlockAlertViewHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase {
    NSMutableArray *handlers = [self BlockAlertView_handlersForPhase:phase];
    if (buttonIndex < 0 || buttonIndex >= handlers.count)
        return nil;
    id handler = [handlers objectAtIndex:buttonIndex];
    return handler == [NSNull null] ? nil : handler;
}

- (void)setButtonAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase handler:(BlockAlertViewHandler)handler {
    NSAssert(buttonIndex >= 0 && buttonIndex < self.numberOfButtons, @"buttonIndex %d is out of range [0,%d)", buttonIndex, self.numberOfButtons);
    NSNull *null = [NSNull null];

    id handlerObject = handler;
    if (handler == nil) {
        handlerObject = null;
    } else {
        handlerObject = [handler copy];
    }

    NSMutableArray *handlers = [self BlockAlertView_handlersForPhase:phase];
    for (int i = buttonIndex - handlers.count; i >= 0; --i) {
        [handlers addObject:null];
    }
    [handlers replaceObjectAtIndex:buttonIndex withObject:handlerObject];
}

- (NSInteger)addButtonWithTitle:(NSString *)title phase:(BlockAlertViewPhase)phase handler:(BlockAlertViewHandler)handler {
    NSInteger i = [self addButtonWithTitle:title];
    [self setButtonAtIndex:i phase:phase handler:handler];
    return i;
}

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockAlertViewHandler)handler {
    return [self addButtonWithTitle:title phase:BlockAlertViewClickedPhase handler:handler];
}

#pragma mark - Implementation details

- (void)initBlockAlertView {
    _myDelegate = [[BlockAlertViewDelegate alloc] init];
    _myDelegate->_alertView = self;
    super.delegate = _myDelegate;
}

- (NSMutableArray *)BlockAlertView_handlersForPhase:(BlockAlertViewPhase)phase {
    __strong NSMutableArray **handlersPointer;
    switch (phase) {
        case BlockAlertViewClickedPhase: handlersPointer = &_clickedHandlers; break;
        case BlockAlertViewDidDismissPhase: handlersPointer = &_didDismissHandlers; break;
        default: NSAssert(YES, @"BlockAlertView invalid phase %d", (int)phase); break;
    }
    
    if (!*handlersPointer) {
        *handlersPointer = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return *handlersPointer;
}

- (BOOL)BlockAlertView_invokeBlockForButtonAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase {
    BlockAlertViewHandler handler = [self buttonHandlerAtIndex:buttonIndex phase:phase];
    if (handler) {
        handler();
        return YES;
    } else {
        return NO;
    }
}

@end
