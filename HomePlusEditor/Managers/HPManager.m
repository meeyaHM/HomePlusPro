//
// HPManager.m
// HomePlus
//
// Generic Manager
//
// Created Oct 2019
// Author: Kritanta
//

#include "HPManager.h"


NSInteger widgetWidth(NSInteger size, NSInteger cols)
{
    CGFloat colf = (CGFloat) cols;
    if (size <= 2)
        return (NSInteger) (ceil(0.5f * colf)); // floor when widget resizing logic is implemented.
    if (size == 3)
        return (NSInteger) (floor(0.75f * colf));
    if (size >= 4)
        return cols;
    return size;
}

@implementation HPManager

+ (instancetype)sharedInstance
{
    static HPManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = (HPManager *)[[[self class] alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];

    if (self) {

        // Preference globals
        self._pfTweakEnabled = YES;
        // self._pfBatterySaver = NO; // Planned LPM Reduced Animation State
        self._pfGestureDisabled = YES;
        self._pfActivationGesture = 1;
        //static CGFloat _pfEditingScale = 0.7;

        // Values we use everywhere during runtime. 
        // These should be *avoided* wherever possible
        // We can likely interface managers to handle these without too much overhead
        self._rtEditingEnabled = NO;
        self._rtConfigured = NO;
        self._rtKickedUp = NO;
        self._rtIconSupportInjected = NO;
        // On <iOS 13 we need to reload the icon view initially several times to update our changes :)
        self._rtIconViewInitialReloadCount = 0;

        // Tweak compatability stuff. 
        // See the %ctor at the bottom of the file for more info
        self._tcDockyInstalled = NO;

        // Views to shrink with pan gesture
        self.wallpaperView = nil;
        self.homeWindow = nil;
        self.floatingDockWindow = nil;
        self.mockBackgroundView = nil;

        // Gesture recognizer to enable whenever kDisableEditingMode is hit.
        self._rtGestureRecognizer = nil;
        self._rtHitboxWindow = nil;
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCacheFor) name:@"HPUpdateLayoutCache" object:nil];
    }

    return self;
}

+(void)updateCacheForLocation:(NSString *)iconLocation
{
    if ([iconLocation isEqualToString:@"SBIconLocationTodayView"])
    return;
    NSString *loc = [iconLocation substringFromIndex:14];
    SBIconListGridLayoutConfiguration *config = [[[[[objc_getClass("SBIconController") sharedInstance] iconManager] listLayoutProvider] layoutForIconLocation:iconLocation] layoutConfiguration];
    static NSMutableDictionary *originalConfigs = nil;
    if (!originalConfigs)
        originalConfigs = [NSMutableDictionary new];

    if (!originalConfigs[iconLocation]) 
        originalConfigs[iconLocation] = [config copy];
    
    [config setNumberOfPortraitColumns:GetLoadoutValue(loc, @"Columns")];
    [config setNumberOfPortraitRows:GetLoadoutValue(loc, @"Rows")];
    if (@available(iOS 14, *))
    {
        SBHIconGridSizeClassSizes sizes = { .small = { .width = widgetWidth(2, GetLoadoutValue(loc, @"Columns")), .height = 2 }, 
                                    .medium = { .width = widgetWidth(4, GetLoadoutValue(loc, @"Columns")), .height = 2 }, 
                                    .large = { .width = widgetWidth(4,  GetLoadoutValue(loc, @"Columns")), .height = 6 }, 
                                    .extralarge = { .width = widgetWidth(4,  GetLoadoutValue(loc, @"Columns")), .height = 6 } };
        [config setIconGridSizeClassSizes:sizes]; 
    }
    UIEdgeInsets x = [originalConfigs[iconLocation] portraitLayoutInsets];
    UIEdgeInsets y;
    CGFloat leftinset = GetLoadoutValue(loc, @"LeftInset")?:0;
    if (!((!leftinset) == 0))
        leftinset = (x.left) + (GetLoadoutValue(loc, @"SideInset")?:0)*-2;
    
    y = UIEdgeInsetsMake(
        x.top + (GetLoadoutValue(loc, @"TopInset")?:0),
        leftinset,
        x.bottom - (GetLoadoutValue(loc, @"TopInset")?:0) + (GetLoadoutValue(loc, @"VerticalSpacing")?:0) *-2, // * 2 because regularly it was too slow
        x.right - (GetLoadoutValue(loc, @"LeftInset")?:0) + (GetLoadoutValue(loc, @"SideInset")?:0) *-2
    );

    config.portraitLayoutInsets = y;
}

@end