#include "HomePlus.h"
#include "HPDataManager.h"
#include "HPManager.h"

@interface SBIconListView (MainLayout13)

@property (nonatomic, assign) NSInteger iconsInRowForSpacingCalculation;
@property (nonatomic, assign) CGSize alignmentIconSize;
@property (nonatomic, assign) NSInteger firstFreeSlotIndex;
@property (nonatomic, retain) SBIconListFlowLayout *homeplus_layout;

- (void)setIconsLabelAlpha:(CGFloat)alpha;
- (NSUInteger)iconRowsForCurrentOrientation; 
-( SBHDefaultIconListLayoutProvider *)layoutProvider;
-(void)homeplus_updateCache;

@end


@interface SBIconListFlowLayout (MainLayout)

@property (nonatomic, retain) SBIconListGridLayoutConfiguration *homeplus_cachedConfiguration;
@property (nonatomic, retain) SBIconListGridLayoutConfiguration *homeplus_cachedDefault;

- (void)homeplus_updateCachedConfiguration;

@end

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


%hook SBIconListView 

%property (nonatomic, assign) BOOL configured;

// TODO: WHY WHY WHY WHY WHY
- (void)layoutSubviews 
{
    %orig;

    if (!self.configured) 
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightView:) name:kHighlightViewNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutIconsNow) name:@"HPLayoutIconViews" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutIconsNowWithAnimation) name:@"HPLayoutIconViewsAnimated" object:nil];
        self.configured = YES;
        
        [HPManager sharedInstance]._rtConfigured = YES;
    }

    [self layoutIconsNow];
}

// TODO: Need to add the prefix "homeplus_" to this
%new 
- (void)layoutIconsNowWithAnimation
{
    [UIView animateWithDuration:(0.15) delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self layoutIconsNow];
    } completion:NULL];
}

// TODO: figure out what this even does, i cant remember.
- (BOOL)automaticallyAdjustsLayoutMetricsToFit
{
    if ([self.iconLocation containsString:@"Root"]
        || [self.iconLocation containsString:@"Dock"])
        return NO;
    
    return %orig;
}

%end


@interface SBIconListModel (here)
-(SBHIconGridSizeClassSizes)iconGridSizeClassSizes;
@end
@interface SBFolder : NSObject 
-(NSString *)displayName;
@end

// TODO: this is disgusting
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

// idk why we're forced to do this
%hook SBHLibraryCategoriesRootFolder

-(SBHLibraryCategoriesRootFolder *)initWithUniqueIdentifier:(id)arg1 
                                                displayName:(id)arg2 
                                               maxListCount:(NSUInteger)arg3 
                                               listGridSize:(SBHIconGridSize)arg4 
                                     iconGridSizeClassSizes:(SBHIconGridSizeClassSizes)arg5
{
    SBHIconGridSize size = { .width = GetLoadoutValue(@"Root", @"Columns"), .height = arg4.height };

    SBHIconGridSizeClassSizes sizes = { .small = { .width = 2, .height = 2 }, .medium = { .width = 4, .height = 2 }, 
                                    .large = { .width = 4, .height = 4 }, .extralarge = { .width = 4, .height = 6 } };

    return %orig(arg1, arg2, arg3, size, sizes);
}

%end
