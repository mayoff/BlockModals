/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockActionSheet.h"

@interface BlockActionSheetDelegate : NSObject <UIActionSheetDelegate> {
@package
    __unsafe_unretained BlockActionSheet *_actionSheet;
}
@end

@implementation BlockActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BlockActionSheetHandler handler = [_actionSheet buttonHandlerAtIndex:buttonIndex];
    if (handler) {
        handler();
    } else {
        id userDelegate = [actionSheet delegate];
        if (userDelegate && [userDelegate respondsToSelector:_cmd]) {
            [userDelegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
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
    NSMutableArray *_handlers;
    BlockActionSheetDelegate *_myDelegate;
    __unsafe_unretained id<UIActionSheetDelegate> _userDelegate;
}

#pragma mark - Public API

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (!(self = [super initWithCoder:aDecoder]))
        return nil;
    [self initBlockActionSheet];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (!(self = [super initWithFrame:frame]))
        return nil;
    [self initBlockActionSheet];
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

- (BlockActionSheetHandler)buttonHandlerAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0 || buttonIndex >= _handlers.count)
        return nil;
    id handler = [_handlers objectAtIndex:buttonIndex];
    return handler == [NSNull null] ? nil : handler;
}

- (void)setHandler:(BlockActionSheetHandler)handler forButtonAtIndex:(NSInteger)buttonIndex {
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

- (NSInteger)addButtonWithTitle:(NSString *)title handler:(BlockActionSheetHandler)handler {
    NSInteger i = [self addButtonWithTitle:title];
    [self setHandler:handler forButtonAtIndex:i];
    return i;
}

#pragma mark - Implementation details

- (void)initBlockActionSheet {
    _handlers = [[NSMutableArray alloc] initWithCapacity:5];
    _myDelegate = [[BlockActionSheetDelegate alloc] init];
    _myDelegate->_actionSheet = self;
    super.delegate = _myDelegate;
}

@end
