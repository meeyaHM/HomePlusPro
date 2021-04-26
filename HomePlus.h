// this is pretty horrible, dont use this.
// in my defense, most of this is from October 2019. 

// TODO: CLEAN THIS UP
// TODO: PLEASE ITS SO BAD


#include "Prefix.h"

// Define some globals for use across the tweak.
// TODO: WHY ARE THESE NOT IN PREFIX.H
#define kMaxColumnAmount 14
#define kMaxRowAmount 14

// TODO: SEE ABOVE TODO
#define kUniqueLogIdentifier @"HPD"

// TODO: COULD THIS NOT BE DONE IN A BETTER WAY
#define kEditingModeChangedNotificationName @"HomePlusEditingModeChanged"
#define kEditingModeEnabledNotificationName @"HomePlusEditingModeEnabled"
#define kEditingModeDisabledNotificationName @"HomePlusEditingModeDisabled"
#define kEditorKickViewsUp @"HomePlusKickWindowsUp"
#define kEditorKickViewsBack @"HomePlusKickWindowsBack"
#define kDeviceIsLocked @"HomePlusDeviceIsLocked"
#define kDeviceIsUnlocked @"HomePlusDeviceIsUnlocked"
#define kWiggleActive @"HomePlusWiggleActive"
#define kWiggleInactive @"HomePlusWiggleInactive"
#define kDisableWiggleTrigger @"HomePlusDisableWiggle"
#define kHighlightViewNotificationName @"HomePlusHighlightRelevantView"
#define kFadeFloatingDockNotificationName @"HomePlusFadeFloatingDock"
#define kShowFloatingDockNotificationName @"HomePlusShowFloatingDock"
#define kReloadIconScaleNotificationName @"HomePlusReloadIconScale"
#define kGetUpdatedValues @"HomePlusUpdateValues"

// TODO: SEE TODO #3
#define kIdentifier @"me.kritanta.homeplusprefs"
#define kSettingsChangedNotification (CFStringRef)@"me.kritanta.homeplusprefs/settingschanged"
#define kSettingsPath @"/var/mobile/Library/Preferences/me.kritanta.homeplusprefs.plist"

#ifndef HPPH
#define HPPH

#include <SpringBoardHome/SBIconListModel.h>
typedef struct SBIconCoordinate {
    NSInteger row;
    NSInteger col;
} SBIconCoordinate;

struct SBIconListLayoutMetrics {
    unsigned long long _field1;
    unsigned long long _field2;
    struct CGSize _field3;
    struct CGSize _field4;
    double _field5;
    struct UIEdgeInsets _field6;
    BOOL _field7;
    BOOL _field8;
};


typedef struct SBHIconGridSize {
    short width;
    short height;
} SBHIconGridSize;

typedef struct SBHIconGridSizeClassSizes {
    SBHIconGridSize small;
    SBHIconGridSize medium;
    SBHIconGridSize large;
    SBHIconGridSize extralarge;
} SBHIconGridSizeClassSizes;

@interface SBFloatyFolderScrollView : UIView 
@end 


@interface SBIconModel : NSObject 

- (void)layout;

@end

@interface SBIconListModel (HomePlus)

@property (nonatomic, assign) NSUInteger homeplus_pageIndex;
@property (nonatomic, retain) NSString *homeplus_iconLocation;

@end


@interface SBIconViewMap : NSObject

@property (nonatomic, retain) SBIconModel *iconModel;

@end


@interface SBIconListGridLayoutConfiguration : NSObject

@property (nonatomic, assign) NSString *iconLocation;
@property (nonatomic, retain) NSDictionary *managerValues;
@property (nonatomic, assign) UIEdgeInsets customInsets;
@property (nonatomic, assign) NSUInteger numberOfPortraitColumns;
@property (nonatomic, assign) NSUInteger numberOfPortraitRows;
@property (nonatomic, assign) UIEdgeInsets portraitLayoutInsets;

@property (nonatomic, assign) SBHIconGridSizeClassSizes iconGridSizeClassSizes;
- (void)getLatestValuesFromManager;
@end
#include <SpringBoardHome/SBIconListFlowLayout.h>

@interface SBIconListGridLayout (HomePlus)
@property (nonatomic, assign) NSUInteger homeplus_pageIndex;
@property (nonatomic, retain) NSString *homeplus_iconLocation;
@end




@interface SBEditingDoneButton : UIButton
@end


@interface SBRootFolderView  : UIView <UIGestureRecognizerDelegate> 
@property (nonatomic, retain) SBEditingDoneButton *doneButton;
- (void)resetIconListViews;
@end


@interface SBRootFolderController
- (void)doneButtonTriggered:(id)button; 
@property (nonatomic, retain) SBIconViewMap *iconViewMap;
@property (nonatomic, retain) SBRootFolderView *contentView;
-(id)currentIconListView;
-(NSArray *)iconListViews;
- (BOOL)isSidebarPinned;
- (BOOL)isSidebarVisible;
@property (getter=isSidebarEffectivelyVisible,nonatomic,readonly) BOOL sidebarEffectivelyVisible;
@end


@interface SBRootIconListView : UIView

@property (nonatomic, retain) NSDictionary *managerValues;
@property (nonatomic, assign) CGFloat customTopInset;
@property (nonatomic, assign) CGFloat customLeftOffset;
@property (nonatomic, assign) CGFloat customSideInset;
@property (nonatomic, assign) CGFloat customVerticalSpacing;
@property (nonatomic, assign) CGFloat customRows;
@property (nonatomic, assign) CGFloat customColumns;
@property (nonatomic, assign) BOOL configured;
@property (nonatomic, assign) CGRect typicalFrame;
@property (nonatomic, retain) NSArray *allSubviews;
@property (nonatomic, retain) SBIconViewMap *viewMap;
@property (nonatomic, retain) SBIconListModel *model;

- (void)getLatestValuesFromManager;
- (NSString *)newIconLocation;
- (NSInteger)iconLocation;
- (CGFloat)horizontalIconPadding ;
- (void)setIconsLabelAlpha:(double)arg1;
- (void)updateTopInset:(CGFloat)arg1;
- (void)updateSideInset:(CGFloat)arg1;
- (void)resetValuesToDefaults;
- (void)updateVerticalSpacing:(CGFloat)arg1;
- (void)updateLeftOffset:(CGFloat)arg1;
- (void)recieveNotification:(NSNotification *)notification;
- (void)updateCustomRows:(CGFloat)arg1;
- (void)updateCustomColumns:(CGFloat)arg1;
- (NSUInteger)iconRowsForHomePlusCalculations;
- (void)layoutIconsNow;
- (CGFloat)sideIconInset;
- (CGFloat)verticalIconPadding;
- (CGFloat)topIconInset;
- (CGSize)defaultIconSize;
- (void)setLayoutReversed:(BOOL)arg;
- (void)updateRC;
- (NSUInteger)iconRowsForSpacingCalculation;
+ (NSUInteger)maxIcons;
+ (NSUInteger)iconRowsForInterfaceOrientation:(NSInteger)arg1;
+ (NSUInteger)iconColumnsForInterfaceOrientation:(NSInteger)arg1;
- (SBRootFolderController *)_viewControllerForAncestor;

@end

@interface SBIconListView : SBRootIconListView 
// This is actually backwards, but I'm lazy and it works. 
@property(readonly, nonatomic) _Bool automaticallyAdjustsLayoutMetricsToFit;
@property (nonatomic, assign) NSInteger orientation;

@property (nonatomic, assign) NSUInteger homeplus_pageIndex;
@property (nonatomic, assign, readwrite) UIEdgeInsets additionalLayoutInsets;
- (NSString *)iconLocation;
- (NSArray *)getDefaultValues;
- (SBIconListFlowLayout *)layout;
- (NSUInteger)numberOfDisplayedIconViews;
- (NSUInteger)maximumIconCount;

@end


@interface HPHitboxView : UIView 
@end 

@interface HPTouchKillerHitboxView : HPHitboxView 
@end 

@interface HPHitboxWindow : UIView
@end 


@interface FBSystemGestureView : UIView

@property (nonatomic, retain) HPHitboxView *hp_hitbox;
@property (nonatomic, retain) HPHitboxWindow *hp_hitbox_window;

- (void)createTopLeftHitboxView;
- (void)createFullScreenDragUpView;

@end


@interface SBIconListView (more)  


@end


@interface SBHomeScreenWindow : UIView
// No longer used afaik
@property (nonatomic, retain) HPHitboxView *hp_hitbox;
@property (nonatomic, retain) HPHitboxWindow *hp_hitbox_window;

- (void)createManagers;
@end


@interface SpringBoard : UIApplication
- (BOOL)isShowingHomescreen;
@end


@interface _SBWallpaperWindow : UIView 
@end
@interface SBMainScreenActiveInterfaceOrientationWindow : UIView
- (BOOL)isActive;
@end


@interface SBIconView : UIView

@property (nonatomic, retain) UIView *labelView;
@property (nonatomic, assign) CGFloat iconAccessoryAlpha;
@property (nonatomic, assign) CGFloat iconLabelAlpha;

- (NSString *)newIconLocation;
- (void)setLabelAccessoryViewHidden:(BOOL)arg;
- (NSString *)location;
- (void)_applyIconLabelAlpha:(CGFloat)a;
- (void)setIconContentScalingEnabled:(BOOL)yes;
- (void)setIconContentScale:(CGFloat)scale;
@end


@interface SBIconLabelImageParameters : NSObject
@property(readonly, nonatomic) long long iconLocation; 
@end


@interface SBIconLabelImage : UIImage
@property(readonly, copy, nonatomic) SBIconLabelImageParameters *parameters; 
@end


@interface SBIconLegibilityLabelView : UIView
@property(retain, nonatomic) UIImage *image;
@property (retain, nonatomic) SBIconView *iconView;
@end


@interface SBIconBadgeView : UIView 
@property (nonatomic, retain) SBIconListGridLayout *listLayout;
@end

@interface SBFStaticWallpaperImageView : UIImageView 
@end


@interface FBRootWindow : UIView 
@end


@interface SBDockView : UIView
@property (nonatomic, retain) UIView *backgroundView;
@end


@interface SBHomeScreenWindow (HomePlus)
- (void)configureDefaultsIfNotYetConfigured;
@end


@interface _NSCompositeLayoutXAxisAnchor : NSObject
- (NSArray *)_childAnchors;
@end


@interface NSLayoutXAxisAnchor ()
- (_NSCompositeLayoutXAxisAnchor *)offsetBy:(CGFloat)arg;
@end



@interface FBSystemGestureView (HomePlusXII)
- (void)_addGestureRecognizer:(id)arg atEnd:(BOOL)arg2;
@property (nonatomic, assign) CGFloat hpPanAmount;
@property (nonatomic, assign) BOOL editorOpened;
@property (nonatomic, assign) BOOL editorActivated;
@property (nonatomic, assign) BOOL hitboxMaxed;
@property (nonatomic, retain) HPHitboxView *hp_larger_hitbox;
@property (nonatomic, retain) HPHitboxWindow *hp_larger_window;
@end


@interface SBFloatingDockWindow : UIView
@end


@interface UIRootSceneWindow : UIView 
@end


@interface SBIconListView (HomePlus)
-(void)setIconSpacing:(CGSize)size;
@end

@interface SBFolderController : NSObject
-(NSString *)presentedIconLocations;
@end

@interface SBHDefaultIconListLayoutProvider : NSObject
-(SBIconListFlowLayout *)layoutForIconLocation:(NSString *)location;
@end
@interface SBHIconManager : NSObject 
@property (nonatomic, retain) SBHDefaultIconListLayoutProvider *listLayoutProvider;
@end

@interface SBHLibraryPodFolderController : UIViewController
-(SBIconListView *)currentIconListView;
@end
@interface SBHLibraryViewController : UIViewController 
- (SBHLibraryPodFolderController *)_podFolderViewController;
@end
@interface SBIconController : UIViewController
+ (SBIconController *)sharedInstance;
- (SBFolderController *)_openFolderController;
- (SBRootFolderController *)_rootFolderController;
- (SBHIconManager *)iconManager;
- (SBHLibraryViewController *)_libraryViewController;
@end

@interface SBFloatingDockView : UIView
@property (nonatomic, retain) UIView *backgroundView;
@end
#endif