/*
Created by Rob Mayoff on 5/1/12.
Author: Rob Mayoff.  All rights renounced.  This file is in the public domain..
*/

#import "BlockAlertView.h"
#import <objc/message.h>

@interface BlockAlertView ()

- (void)BlockAlertView_delegateWasCalledWithButtonIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase message:(SEL)selector;

@end


@interface BlockAlertViewDelegate : NSObject <UIAlertViewDelegate> {
@package
    __unsafe_unretained BlockAlertView *_alertView;
}
@end

@implementation BlockAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [_alertView BlockAlertView_delegateWasCalledWithButtonIndex:buttonIndex phase:BlockAlertViewClickedPhase message:_cmd];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [_alertView BlockAlertView_delegateWasCalledWithButtonIndex:buttonIndex phase:BlockAlertViewDidDismissPhase message:_cmd];
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
    [self BlockAlertView_init];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self BlockAlertView_init];
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    return [self initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
}

- (void)setDelegate:(id)delegate {
    _userDelegate = delegate;
    // This forces my superclass to recache the results of respondsToSelector:.
    super.delegate = nil;
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

static void padArrayWithNullThroughIndex(NSMutableArray *array, NSInteger index) {
    NSNull *null = [NSNull null];
    for (int i = array.count; i < index + 1; ++i) {
        [array addObject:null];
    }
}

static id storableObjectForHandler(BlockAlertViewHandler handler) {
    return handler ? [handler copy] : [NSNull null];
}

- (void)setButtonAtIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase handler:(BlockAlertViewHandler)handler {
    [self validateButtonIndex:buttonIndex];
    NSMutableArray *handlers = [self BlockAlertView_handlersForPhase:phase];
    padArrayWithNullThroughIndex(handlers, buttonIndex);
    [handlers replaceObjectAtIndex:buttonIndex withObject:storableObjectForHandler(handler)];
}

- (void)validateButtonIndex:(NSInteger)buttonIndex {
    NSAssert(buttonIndex >= 0 && buttonIndex < self.numberOfButtons, @"buttonIndex %d is out of range [0,%d)", buttonIndex, self.numberOfButtons);
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

- (void)BlockAlertView_init {
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

- (void)BlockAlertView_delegateWasCalledWithButtonIndex:(NSInteger)buttonIndex phase:(BlockAlertViewPhase)phase message:(SEL)selector {
    BlockAlertViewHandler handler = [self buttonHandlerAtIndex:buttonIndex phase:phase];
    if (handler) {
        handler();
    } else if (_userDelegate && [_userDelegate respondsToSelector:selector]) {
        typedef void DelegateMethod(id, SEL, id, NSInteger);
        ((DelegateMethod *)objc_msgSend)(_userDelegate, selector, self, buttonIndex);
    }
}

@end
