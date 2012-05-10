# BlockModals

This project lets you set a block as the handler for a button in a `UIActionSheet` or `UIAlertView`.

## BlockAlertView

The project defines a subclass of `UIAlertView` named `BlockAlertView`.  You can use the `BlockAlertView` anywhere you use a `UIAlertView`.  It supports everything `UIAlertView` supports; it is a drop-in replacement.

What `BlockAlertView` adds is a method named `addButtonWithTitle:handler:` that lets you set a block to be called when the user taps the button.  You use it like this:

    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"Intruder Alert!"
        message:@"Your vessel has been boarded by hostile aliens."];
    alert.cancelButtonIndex = [alert addButtonWithTitle:@"Ignore Them"];
    
    [alert addButtonWithTitle:@"Beg For Mercy" handler:^{
        [self begForMercy];
    }];
    
    [alert addButtonWithTitle:@"Blast Them" handler:^{
        [self.phaser setMode:PhaserModeKill];
        [self fireWeapon:self.phaser];
    }];
    
    [alert show];
    
To use `BlockAlertView` in your own project, just copy the files `BlockAlertView.h` and `BlockAlertView.m` to your project, and add `BlockAlertView.m` to the “Compile Sources” phase of your target.

## BlockActionSheet

The `BlockActionSheet` class is a subclass of `UIActionSheet` and adds the same methods as `BlockAlertView`.  To use it in your own project, copy `BlockActionSheet.h` and `BlockActionSheet.m` to your project, and add `BlockActionSheet.m` to the “Compile Sources” phase of your target.
