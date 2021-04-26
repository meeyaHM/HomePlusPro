#include "HomePlus.h"
#include "HomePlusEditor.h"
#define KEY @"HPModifiedIconState"
#pragma mark Dock BG Handling


NSInteger widgetWidth(NSInteger size, NSInteger cols)
{
    CGFloat colf = (CGFloat) cols;
    if (size <= 2)
        return (NSInteger) (floor(0.5f * colf)); // floor when widget resizing logic is implemented.
    if (size == 3)
        return (NSInteger) (floor(0.75f * colf));
    if (size >= 4)
        return cols;
    return size;
}


%hook SBDockView

// This is what we need to hook to hide the dock background cleanly
// This tidbit works across versions, so we can call it in the base group (%init)

- (id)initWithDockListView:(id)arg1 forSnapshot:(BOOL)arg2 
{
    id x = %orig;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutSubviews) name:@"HPLayoutDockView" object:nil];

    return x;
}

- (void)layoutSubviews
{
    %orig;

    UIView *bgView = MSHookIvar<UIView *>(self, "_backgroundView"); 

    // Dont use UserDefaults like this. Use the bool api. I am lazy. 
    if ([[[HPDataManager sharedInstance] currentConfiguration] integerForKey:@"HPDataHideDockBG"])
    {
        bgView.alpha = 0;
        bgView.hidden = YES;
    }
}

%end

#pragma mark Editor Exit Listeners

%hook SBCoverSheetWindow

// This is the lock screen // drag down thing
// Pulling it down will disable the editor view

- (BOOL)becomeFirstResponder 
{
    BOOL x = %orig;

    if ([(SpringBoard*)[UIApplication sharedApplication] isShowingHomescreen] && [HPManager sharedInstance]._rtEditingEnabled)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditingModeDisabledNotificationName object:nil];
        [HPManager sharedInstance]._rtEditingEnabled = NO;
    }

    return x;
}

%end


%hook SBMainSwitcherWindow

// Whenever the user swipes up to enable the switcher, close the editor view. 
// It's optional, since it makes the bottom half hard to use on HomeGesture Phones
//      on really small phones with HomeGesture

- (void)setHidden:(BOOL)arg
{
    %orig(arg);

    if ([HPManager sharedInstance]._rtEditingEnabled && NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kEditingModeDisabledNotificationName object:nil];
    }
}

%end


%hook SBIconListModel 

- (SBIconListModel *)initWithUniqueIdentifier:(id)uid
                                       folder:(SBFolder *)folder
                                     gridSize:(SBHIconGridSize)gridSize
                           gridSizeClassSizes:(SBHIconGridSizeClassSizes)sizes

{
    if (gridSize.height == -1)
    {
            SBHIconGridSizeClassSizes fixedSizes = { .small = { .width = 2, .height = 2 }, .medium = { .width = 4, .height = 2 }, 
                                    .large = { .width = 4, .height = 4 }, .extralarge = { .width = 4, .height = 6 } };
        return %orig(uid, folder, gridSize, fixedSizes);
    }
    return %orig(uid, folder, gridSize, sizes);
}
%end 

%hook SpringBoard

// Honestly this is a bad hack just to get it functional (with not too much overhead).
// This could be done with a notification listener instead.
- (BOOL)isShowingHomescreen
{
    [HPManager updateCacheForLocation:@"SBIconLocationRoot"];
    [HPManager updateCacheForLocation:@"SBIconLocationDock"];
    if (!%orig)
    {
        if ([HPManager sharedInstance]._rtHitboxWindow)
        {
            [HPManager sharedInstance]._rtHitboxWindow.hidden = YES;
        }
    }
    else 
    {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 13.0f && [HPManager sharedInstance]._rtIconViewInitialReloadCount < 2)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
        }
        if ([HPManager sharedInstance]._rtIconViewInitialReloadCount == 2)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
        }
        [HPManager sharedInstance]._rtIconViewInitialReloadCount += 1;
        if ([HPManager sharedInstance]._rtHitboxWindow)
        {
            [HPManager sharedInstance]._rtHitboxWindow.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HPResetIconViews" object:nil];
        }
    }
    return %orig;
}

%end

// idk why we're forced to do this
%hook SBHLibraryCategoriesRootFolder

-(SBHLibraryCategoriesRootFolder *)initWithUniqueIdentifier:(id)arg1 
                                                displayName:(id)arg2 
                                               maxListCount:(NSUInteger)arg3 
                                               listGridSize:(SBHIconGridSize)arg4 
                                     iconGridSizeClassSizes:(SBHIconGridSizeClassSizes)arg5
{

    SBHIconGridSizeClassSizes sizes = { .small = { .width = 2, .height = 2 }, .medium = { .width = 4, .height = 2 }, 
                                    .large = { .width = 4, .height = 4 }, .extralarge = { .width = 4, .height = 6 } };

    return %orig(arg1, arg2, arg3, arg4, sizes);
}

%end

%hook _SBHLibraryPodIconListView 
-(CGSize)iconSpacing 
{
    return CGSizeMake(27, 35);
}
%end

#pragma mark Reload Icon Model

%hook SBIconModel

// The "Magic Method"
// This'll essentially reconstruct the layout of icons,
//      allowing us to update rows/columns without a respring

- (id)initWithStore:(id)arg applicationDataSource:(id)arg2
{
    id x = %orig(arg, arg2);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveIconStateIfNeeded) name:@"HPSaveIconState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveNotification:) name:@"HPResetIconViews" object:nil];

    return x;
}

%new 
- (void)recieveNotification:(NSNotification *)notification
{
    @try 
    {
        [self layout];
    } 
    @catch (NSException *exception) 
    {
        // Cant remember the details, but this method had a tendency to crash at times
        //      Make sure we dont cause a safe mode and instead just dont update layout

        // Lets make this an alert view in the future. 
        NSLog(@"SBICONMODEL CRASH: %@", exception);
    }
}

%end

#pragma mark Force Modern Dock

%hook UITraitCollection

// Force Modern Dock on non-A11+ Phones. 

- (CGFloat)displayCornerRadius 
{
    return ((![HPUtility isCurrentDeviceNotched]                                                                 // Dont do this on notched devices, no need
                && (([[[HPDataManager sharedInstance] currentConfiguration] integerForKey:@"HPDataModernDock"]?:0) == 1))  // If we're supposed to force modern dock
                        ? 6.0f                                                                                      // Setting this to a non-0 value forced modern dock
                        : %orig );                                                                               // else just orig it. 
}

%end

# pragma mark Floating Dock Background

%hook SBFloatingDockView

-(void)layoutSubviews
{
    %orig;

    if ([[[HPDataManager sharedInstance] currentConfiguration] integerForKey:@"HPDataHideDockBG"])
    {
        self.backgroundView.alpha = 0;
        self.backgroundView.hidden = YES;
    }
}

%end



%hook SBFStaticWallpaperImageView

// Whenever a wallpaper image is created for the homescreen, pass it to the manager
// We then use this FB/UIRootWindow in the tweak to give the awesome blurred bg UI feel

- (void)setImage:(UIImage *)img 
{
    %orig(img);
    [[HPEditorManager sharedInstance] loadUpImagesFromWallpaper:img];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateBackgroundObject" object:nil];
}

%end


%hook SpringBoard

- (NSUInteger)homeScreenRotationStyle
{
    BOOL x = [[[HPDataManager sharedInstance] currentConfiguration] objectForKey:@"HPDataForceRotation"]
                ? [[[HPDataManager sharedInstance] currentConfiguration] boolForKey:@"HPDataForceRotation"]
                : NO;
    return x ? 2 : %orig;
}

- (BOOL)homeScreenSupportsRotation
{
    return [[[HPDataManager sharedInstance] currentConfiguration] objectForKey:@"HPDataForceRotation"]
                ? [[[HPDataManager sharedInstance] currentConfiguration] boolForKey:@"HPDataForceRotation"]
                : NO;
}

%end

%hook SBWallpaperController

-(BOOL)_isAcceptingOrientationChangesFromSource:(NSInteger)arg
{
    return NO;
}

%end
