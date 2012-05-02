/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertView.h"

@interface BlockAlertViewDelegate : NSObject <UIAlertViewDelegate> {
@package
    __unsafe_unretained BlockAlertView *_alertView;
}
@end

@implementation BlockAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    BlockAlertViewHandler handler = [_alertView buttonHandlerAtIndex:buttonIndex];
    if (handler) {
        handler();
    } else {
        id userDelegate = [alertView delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate alertView:alertView clickedButtonAtIndex:buttonIndex];
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
    NSMutableArray *_handlers;
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

- (BlockAlertViewHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0 || buttonIndex >= _handlers.count)
        return nil;
    id handler = [_handlers objectAtIndex:buttonIndex];
    return handler == [NSNull null] ? nil : handler;
}

- (void)setHandler:(BlockAlertViewHandler)handler forButtonAtIndex:(NSInteger)buttonIndex {
    NSAssert(buttonIndex >= 0 && buttonIndex < self.numberOfButtons, @"buttonIndex %d is out of range [0,%d)", buttonIndex, self.numberOfButtons);
    NSNull *null = [NSNull null];

    id handlerObject = handler;
    if (handler == nil) {
        handlerObject = null;
    } else {
        // ARC won't copy handler automatically because I'm converting it to an id.
        handlerObject = [handler copy];
    }

    for (int i = buttonIndex - _handlers.count; i >= 0; --i) {
        [_handlers addObject:null];
    }
    [_handlers replaceObjectAtIndex:buttonIndex withObject:handlerObject];
}

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockAlertViewHandler)handler {
    NSInteger i = [self addButtonWithTitle:title];
    [self setHandler:handler forButtonAtIndex:i];
    return i;
}

#pragma mark - Implementation details

- (void)initBlockAlertView {
    _handlers = [[NSMutableArray alloc] initWithCapacity:5];
    _myDelegate = [[BlockAlertViewDelegate alloc] init];
    _myDelegate->_alertView = self;
    super.delegate = _myDelegate;
}

@end
