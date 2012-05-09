/*
Created by Rob Mayoff on 5/1/12.
Copyright (c) 2012 Rob Mayoff. All rights reserved.
*/

#import "BlockAlertViewTests.h"
#import "BlockAlertView.h"
#import "UIView+SubviewPassingTest.h"
#import "GenericAlertViewDelegate.h"

@implementation BlockAlertViewTests

+ (void)tearDown {
    // Xcode 4.3.2 and earlier sometimes miss output if the test run exits too quickly.  Grumble.
    usleep(100000);
}

#pragma mark - Initializers

- (void)testInitWithTitleMessage {
    static NSString *const kTitle = @"test title";
    static NSString *const kMessage = @"test message";
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:kTitle message:kMessage];
    STAssertNotNil(alert, @"-[BlockAlertView initWithTitle:message:] returns an object");
    STAssertTrue([alert isKindOfClass:[UIAlertView class]], @"-[BlockAlertView initWithTitle:message:] returns a subclass of UIAlertView");
    STAssertEqualObjects(alert.title, kTitle, @"-[BlockAlertView initWithTitle:message:] sets title correctly");
    STAssertEqualObjects(alert.message, kMessage, @"-[BlockAlertView initWithTitle:message:] sets message correctly");
    STAssertNil(alert.delegate, @"-[BlockAlertView initWithTitle:message:] sets delegate to nil");
    STAssertEquals(alert.numberOfButtons, 0, @"-[BlockAlertView initWithTitle:message:] sets numberOfButtons to zero");
}

#pragma mark - Delegate

- (void)testSetDelegate {
    BlockAlertView *alert = [BlockAlertView new];
    STAssertEquals((id)nil, (id)alert.delegate, @"delegate is initially nil");
    id delegate = [NSObject new];
    alert.delegate = delegate;
    STAssertEquals(delegate, alert.delegate, @"setDelegate: sets delegate");
    alert.delegate = nil;
    STAssertEquals((id)nil, (id)alert.delegate, @"setDelegate: sets delegate to nil");
}

- (void)testDelegateWithNoHandlers {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    NSInteger i = [alert addButtonWithTitle:@"the button"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate delegateExpectingButtonAtIndex:i];
    alert.delegate = delegate;
    [self showAlert:alert thenClickButtonAtIndex:i];
    [self checkDelegate:alert.delegate];
}

- (void)testDelegateWithUnusedHandlers {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger handlerButtonIndex = [alert addButtonWithTitle:@"button 0" handler:^{
        clickedHandlerCalled = YES;
    }];
    __block BOOL didDismissHandlerCalled = NO;
    [alert setButtonAtIndex:handlerButtonIndex phase:BlockAlertViewDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    NSInteger delegateButtonIndex = [alert addButtonWithTitle:@"button 1"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate delegateExpectingButtonAtIndex:delegateButtonIndex];
    alert.delegate = delegate;
    [self showAlert:alert thenClickButtonAtIndex:delegateButtonIndex];
    STAssertFalse(clickedHandlerCalled, @"BlockAlertView doesn't invoke button 0 handler");
    STAssertFalse(didDismissHandlerCalled, @"BlockAlertView doesn't invoke button 0 handler");
    [self checkDelegate:alert.delegate];
}

- (void)testDelegateWithClickedHandler {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger i = [alert addButtonWithTitle:@"button 0" handler:^{
        clickedHandlerCalled = YES;
    }];
    [alert addButtonWithTitle:@"button 1"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate delegateExpectingDidDismissButtonAtIndex:i];
    alert.delegate = delegate;
    [self showAlert:alert thenClickButtonAtIndex:i];
    STAssertTrue(clickedHandlerCalled, @"BlockAlertView calls clicked handler");
    [self checkDelegate:alert.delegate];
}

- (void)testDelegateWithDidDismissHandler {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    __block BOOL didDismissHandlerCalled = NO;
    NSInteger i = [alert addButtonWithTitle:@"button 0" phase:BlockAlertViewDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    [alert addButtonWithTitle:@"button 1"];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate delegateExpectingClickedButtonAtIndex:i];
    alert.delegate = delegate;
    [self showAlert:alert thenClickButtonAtIndex:i];
    STAssertTrue(didDismissHandlerCalled, @"BlockAlertView calls didDismiss handler");
    [self checkDelegate:alert.delegate];
}

- (void)testDelegateWithBothHandlers {
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    [alert addButtonWithTitle:@"button 0"];
    __block BOOL clickedHandlerCalled = NO;
    NSInteger i = [alert addButtonWithTitle:@"button 1" handler:^{
        clickedHandlerCalled = YES;
    }];
    __block BOOL didDismissHandlerCalled = NO;
    [alert setButtonAtIndex:i phase:BlockAlertViewDidDismissPhase handler:^{
        didDismissHandlerCalled = YES;
    }];
    GenericAlertViewDelegate *delegate = [GenericAlertViewDelegate delegateExpectingNoButtonAtIndex:i];
    alert.delegate = delegate;
    [self showAlert:alert thenClickButtonAtIndex:i];
    STAssertTrue(clickedHandlerCalled, @"BlockAlertView calls clicked handler");
    STAssertTrue(didDismissHandlerCalled, @"BlockAlertView calls didDismiss handler");
    [self checkDelegate:alert.delegate];
}

- (void)testReplacedDelegateIsCalled {
    // At least as of iOS 4.3 - iOS 5.1, UIActionSheet caches the results of `respondsToSelector:` for all of the delegate messages when the delegate is assigned.  Therefore this test changes out the delegate to make sure that BlockAlertView propertly forces UIActionSheet to recache those results.
    
    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"alert title" message:@"alert message"];
    NSObject *delegate0 = [NSObject new];
    alert.delegate = (id)delegate0;
    
    NSInteger i = [alert addButtonWithTitle:@"the button" handler:^{}];
    
    GenericAlertViewDelegate *delegate1 = [GenericAlertViewDelegate delegateExpectingDidDismissButtonAtIndex:i];
    alert.delegate = delegate1;
    
    [self showAlert:alert thenClickButtonAtIndex:i];    
    [self checkDelegate:delegate1];
}

#pragma mark - Handlers

- (void)testHandlersAreNilForAddButtonWithTitle {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"addButtonWithTitle: sets nil handler for clicked phase");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"addButtonWithTitle: sets nil handler for didDismiss phase");
}

- (void)testSetClickedHandlerForButtonAtIndex {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    BlockAlertViewHandler handler = ^{ NSLog(@"handler"); };
    [alert setButtonAtIndex:i phase:BlockAlertViewClickedPhase handler:handler];
    STAssertEquals(handler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler sets clicked handler for button added without handler");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler doesn't set didDismiss handler for button added without handler");
}

- (void)testSetDidDismissHandlerForButtonAtIndex {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    BlockAlertViewHandler handler = ^{ NSLog(@"handler"); };
    [alert setButtonAtIndex:i phase:BlockAlertViewDidDismissPhase handler:handler];
    STAssertEquals(handler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler sets didDismiss handler for button added without handler");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler doesn't set clicked handler for button added without handler");
}

- (void)testSetBothHandlersForButtonAtIndex {
    BlockAlertView *alert = [BlockAlertView new];
    NSInteger i = [alert addButtonWithTitle:@"a button"];
    BlockAlertViewHandler clickedHandler = ^{ NSLog(@"clicked"); };
    BlockAlertViewHandler didDismissHandler = ^{ NSLog(@"didDismiss"); };
    [alert setButtonAtIndex:i phase:BlockAlertViewClickedPhase handler:clickedHandler];
    [alert setButtonAtIndex:i phase:BlockAlertViewDidDismissPhase handler:didDismissHandler];
    STAssertEquals(clickedHandler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler: sets clicked handler");
    STAssertEquals(didDismissHandler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler: sets didDismiss handler");
    
    BlockAlertViewHandler clickedHandler2 = ^{ NSLog(@"clicked 2"); };
    BlockAlertViewHandler didDismissHandler2 = ^{ NSLog(@"didDismiss 2"); };
    
    [alert setButtonAtIndex:i phase:BlockAlertViewClickedPhase handler:clickedHandler2];
    STAssertEquals(clickedHandler2, [alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler: replaces clicked handler");
    STAssertEquals(didDismissHandler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler: doesn't modify didDismiss handler");
    
    [alert setButtonAtIndex:i phase:BlockAlertViewDidDismissPhase handler:didDismissHandler2];
    STAssertEquals(clickedHandler2, [alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler: doesn't modify clicked handler");
    STAssertEquals(didDismissHandler2, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler: replaces didDismiss handler");
    
    [alert setButtonAtIndex:i phase:BlockAlertViewClickedPhase handler:nil];
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler: sets clicked handler to nil");
    STAssertEquals(didDismissHandler2, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler: doesn't modify didDismiss handler");
    
    [alert setButtonAtIndex:i phase:BlockAlertViewDidDismissPhase handler:nil];
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"setButtonAtIndex:phase:handler: doesn't modify clicked handler to nil");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"setButtonAtIndex:phase:handler: sets didDismiss handler to nil");
}

- (void)testAddButtonWithTitleHandler {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    BlockAlertViewHandler handler = ^{ NSLog(@"handler"); };
    NSInteger i = [alert addButtonWithTitle:title handler:handler];
    STAssertEqualObjects([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertEquals([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], handler, @"addButtonWithTitle:handler: sets clicked handler");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"addButtonWithTitle:handler: doesn't set didDismiss handler");
}

- (void)testAddButtonWithTitleHandlerNil {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    NSInteger i = [alert addButtonWithTitle:title handler:nil];
    STAssertEquals([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:handler: sets title");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"addButtonWithTitle:handler: sets clicked handler to nil");
}

- (void)testAddButtonWithTitleClickedPhaseHandler {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    BlockAlertViewHandler handler = ^{ NSLog(@"didDismiss handler"); };
    NSInteger i = [alert addButtonWithTitle:title phase:BlockAlertViewClickedPhase handler:handler];
    STAssertEqualObjects([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:phase:handler: sets title");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"addButtonWithTitle:phase:handler: sets didDismiss handler to nil");
    STAssertEquals(handler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"addButtonWithTitle:phase:handler: sets clicked handler");
}

- (void)testAddButtonWithTitleDidDismissPhaseHandler {
    BlockAlertView *alert = [BlockAlertView new];
    NSString *title = @"a button";
    BlockAlertViewHandler handler = ^{ NSLog(@"didDismiss handler"); };
    NSInteger i = [alert addButtonWithTitle:title phase:BlockAlertViewDidDismissPhase handler:handler];
    STAssertEqualObjects([alert buttonTitleAtIndex:i], title, @"addButtonWithTitle:phase:handler: sets title");
    STAssertNil([alert buttonHandlerAtIndex:i phase:BlockAlertViewClickedPhase], @"addButtonWithTitle:phase:handler: sets clicked handler to nil");
    STAssertEquals(handler, [alert buttonHandlerAtIndex:i phase:BlockAlertViewDidDismissPhase], @"addButtonWithTitle:phase:handler: sets didDismiss handler");
}

#pragma mark - Helpers

- (void)checkDelegate:(GenericAlertViewDelegate *)delegate {
    STAssertEqualObjects(delegate.clickedButtonIndexes_expected, delegate.clickedButtonIndexes_actual, @"clickedButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.willDismissWithButtonIndexes_expected, delegate.willDismissWithButtonIndexes_actual, @"willDismissWithButtonIndexes expected equals actual");
    STAssertEqualObjects(delegate.didDismissWithButtonIndexes_expected, delegate.didDismissWithButtonIndexes_actual, @"didDismissWithButtonIndexes expected equals actual");
    STAssertEquals(delegate.willPresentAlertView_expected, delegate.willPresentAlertView_actual, @"willPresentAlertView expected equals actual");
    STAssertEquals(delegate.didPresentAlertView_expected, delegate.didPresentAlertView_actual, @"didPresentAlertView expected equals actual");
}

- (void)showAlert:(UIAlertView *)alert thenClickButtonAtIndex:(NSInteger)buttonIndex {
    [alert show];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[alert descendantControlWithTitle:[alert buttonTitleAtIndex:buttonIndex]] sendActionsForControlEvents:UIControlEventTouchUpInside];
    });
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
}

@end

