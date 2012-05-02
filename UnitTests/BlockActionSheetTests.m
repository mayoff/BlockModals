/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockActionSheetTests.h"
#import "BlockActionSheet.h"
#import "UIView+SubviewPassingTest.h"
#import "GenericActionSheetDelegate.h"

@implementation BlockActionSheetTests

+ (void)tearDown {
    // Xcode 4.3.2 and earlier sometimes miss output if the test run exits too quickly.  Grumble.
    usleep(100000);
}

- (void)testInitWithTitle {
    static NSString *const kTitle = @"test title";
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:kTitle];
    STAssertNotNil(sheet, @"-[BlockActionSheet initWithTitle:] returns an object");
    STAssertTrue([sheet isKindOfClass:[UIActionSheet class]], @"-[BlockActionSheet initWithTitle:] returns a subclass of UIActionSheet");
    STAssertEqualObjects(sheet.title, kTitle, @"-[BlockActionSheet initWithTitle:] sets title correctly");
    STAssertNil(sheet.delegate, @"-[BlockActionSheet initWithTitle:] sets delegate to nil");
    STAssertEquals(sheet.numberOfButtons, 0, @"-[BlockActionSheet initWithTitle:] sets numberOfButtons to zero");
}

- (void)testSetDelegate {
    BlockActionSheet *sheet = [BlockActionSheet new];
    id delegate = [NSObject new];
    sheet.delegate = delegate;
    STAssertEquals(delegate, sheet.delegate, @"setDelegate: sets delegate");
}

- (void)testSetDelegateToNil {
    BlockActionSheet *sheet = [BlockActionSheet new];
    id delegate = [NSObject new];
    sheet.delegate = delegate;
    sheet.delegate = nil;
    STAssertEquals((id)nil, (id)sheet.delegate, @"setDelegate: sets delegate to nil");
}

- (void)testHandlerIsNilForAddButtonWithTitle {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    STAssertNil([sheet buttonHandlerAtIndex:i], @"addButtonWithTitle: sets nil handler");
}

- (void)testSetHandlerForButtonAtIndex {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button"];
    BlockActionSheetHandler handler = ^{ NSLog(@"handler"); };
    [sheet setHandler:handler forButtonAtIndex:i];
    STAssertEquals(handler, [sheet buttonHandlerAtIndex:i], @"setHandler:forButtonAtIndex: sets handler for button added without handler");
}

- (void)testSetHandlerToNilForButtonAtIndex {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSInteger i = [sheet addButtonWithTitle:@"a button" handler:^{}];
    [sheet setHandler:nil forButtonAtIndex:i];
    STAssertNil([sheet buttonHandlerAtIndex:i], @"setHandler:forButtonAtIndex: sets handler to nil");
}

- (void)testReplaceHandler {
    BlockActionSheet *sheet = [BlockActionSheet new];
    BlockActionSheetHandler handler0 = ^{ NSLog(@"handler0"); };
    BlockActionSheetHandler handler1 = ^{ NSLog(@"handler1"); };
    NSInteger i = [sheet addButtonWithTitle:@"a button" handler:handler0];
    [sheet setHandler:handler1 forButtonAtIndex:i];
    STAssertEquals([sheet buttonHandlerAtIndex:i], handler1, @"setHandler:forButtonAtIndex: replaces handler");
}

- (void)testAddButtonWithTitleHandler {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    BlockActionSheetHandler handler = ^{ NSLog(@"handler"); };
    NSInteger i = [sheet addButtonWithTitle:title handler:handler];
    STAssertEquals([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertEquals([sheet buttonHandlerAtIndex:i], handler, @"addButtonWithTitle:handler: sets handler");
}

- (void)testAddButtonWithTitleHandlerNil {
    BlockActionSheet *sheet = [BlockActionSheet new];
    NSString *title = @"a button";
    NSInteger i = [sheet addButtonWithTitle:title handler:nil];
    STAssertEquals([sheet buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertNil([sheet buttonHandlerAtIndex:i], @"addButtonWithTitle:handler: sets handler to nil");
}

- (void)testHandlerCalledForButton0 {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    NSInteger i = [sheet addButtonWithTitle:@"button 0" handler:^{
        handler0Called = YES;
    }];
    [sheet addButtonWithTitle:@"button 1" handler:^{
        handler1Called = YES;
    }];
    // -[UIActionSheet dismissWithClickedButtonIndex:animated:] doesn't send actionSheet:clickedButtonAtIndex: to the delegate.
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertTrue(handler0Called, @"BlockActionSheet invokes handler for button 0");
    STAssertFalse(handler1Called, @"BlockActionSheet doesn't invoke handler for button 1");
}

- (void)testHandlerCalledForButton1 {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    [sheet addButtonWithTitle:@"button 0" handler:^{
        handler0Called = YES;
    }];
    NSInteger i = [sheet addButtonWithTitle:@"button 1" handler:^{
        handler1Called = YES;
    }];
    // -[UIActionSheet dismissWithClickedButtonIndex:animated:] doesn't send actionSheet:clickedButtonAtIndex: to the delegate.
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handler0Called, @"BlockActionSheet doesn't invoke handler for button 0");
    STAssertTrue(handler1Called, @"BlockActionSheet invokes handler for button 1");
}

- (void)testReplacedHandlerNotCalledForButton {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL handler0Called = NO;
    __block BOOL handler1Called = NO;
    NSInteger i = [sheet addButtonWithTitle:@"the button" handler:^{
        handler0Called = YES;
    }];
    [sheet setHandler:^{
        handler1Called = YES;
    } forButtonAtIndex:i];
    // -[UIActionSheet dismissWithClickedButtonIndex:animated:] doesn't send actionSheet:clickedButtonAtIndex: to the delegate.
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handler0Called, @"BlockActionSheet doesn't invoke replaced handler");
    STAssertTrue(handler1Called, @"BlockActionSheet invokes replacement handler");
}

- (void)testRemovedHandlerNotCalledForButton {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    __block BOOL handlerCalled = NO;
    NSInteger i = [sheet addButtonWithTitle:@"the button" handler:^{
        handlerCalled = YES;
    }];
    [sheet setHandler:nil forButtonAtIndex:i];
    // -[UIActionSheet dismissWithClickedButtonIndex:animated:] doesn't send actionSheet:clickedButtonAtIndex: to the delegate.
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handlerCalled, @"BlockActionSheet doesn't invoke removed handler");
}

- (void)testDelegateCalledForButtonWithoutHandler {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate new];
    sheet.delegate = delegate;
    __block BOOL handlerCalled = NO;
    [sheet addButtonWithTitle:@"button 0" handler:^{
        handlerCalled = YES;
    }];
    NSInteger i = [sheet addButtonWithTitle:@"button 1"];
    delegate.clickedButtonIndexes_expected = [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertFalse(handlerCalled, @"BlockActionSheet doesn't invoke button 0 handler");
    [self checkDelegate:delegate];
}

- (void)testDelegateNotCalledForButtonWithHandler {
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    GenericActionSheetDelegate *delegate = [GenericActionSheetDelegate new];
    sheet.delegate = delegate;
    __block BOOL handlerCalled = NO;
    [sheet addButtonWithTitle:@"button 0"];
    NSInteger i = [sheet addButtonWithTitle:@"button 1" handler:^{
        handlerCalled = YES;
    }];
    [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    STAssertTrue(handlerCalled, @"BlockActionSheet invokes button 1 handler");
    [self checkDelegate:delegate];
}

- (void)testDelegateCalledForNonButtonMessages {
    // At least as of iOS 4.3 - iOS 5.1, UIActionSheet caches the results of `respondsToSelector:` for all of the delegate messages when the delegate is assigned.  Therefore this test changes out the delegate to make sure that BlockActionSheet propertly forces UIActionSheet to recache those results.
    
    BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"sheet title"];
    NSObject *delegate0 = [[NSObject alloc] init];
    sheet.delegate = (id)delegate0;
    
    NSInteger i = [sheet addButtonWithTitle:@"the button" handler:^{}];
    
    GenericActionSheetDelegate *delegate1 = [GenericActionSheetDelegate new];
    sheet.delegate = delegate1;
    delegate1.willPresentActionSheet_expected = YES;
    delegate1.didPresentActionSheet_expected = YES;
    delegate1.dismissWithButtonIndexes_expected = [NSCountedSet setWithObject:[NSNumber numberWithInteger:i]];
    
    [sheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[sheet descendantControlWithTitle:[sheet buttonTitleAtIndex:i]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
    
    [self checkDelegate:delegate1];
}

#pragma mark - Helpers

- (void)checkDelegate:(GenericActionSheetDelegate *)delegate {
    STAssertEqualObjects(delegate.clickedButtonIndexes_expected, delegate.clickedButtonIndexes_actual, @"clickedButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.dismissWithButtonIndexes_expected, delegate.willDismissWithButtonIndexes_actual, @"willDismissWithButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.dismissWithButtonIndexes_expected, delegate.didDismissWithButtonIndexes_actual, @"didDismissWithButtonIndexes expected equals actual");
    STAssertEquals(delegate.willPresentActionSheet_expected, delegate.willPresentActionSheet_actual, @"willPresentActionSheet expected equals actual");
    STAssertEquals(delegate.didPresentActionSheet_expected, delegate.didPresentActionSheet_actual, @"didPresentActionSheet expected equals actual");
}

@end
