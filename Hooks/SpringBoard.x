// TODO: clean these up, this file used to do a lot more than it does now
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#import "sys/types.h"
#import "sys/sysctl.h"
#include "HomePlus.h"
#include "HPEditorManager.h"
#include "HPManager.h"
#include "HPDataManager.h"
#include "HPUtility.h"
#include <arpa/inet.h>
#include <inttypes.h>
#include "ImageData.h"

@import Foundation;
@import UIKit;
@import WebKit;

%hook SpringBoard

- (BOOL)isShowingHomescreen
{
    [[[HPDataManager sharedInstance] currentConfiguration] setInteger:1 forKey:@"HPTutorialGiven"];

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
    if (%orig && [[[HPDataManager sharedInstance] currentConfiguration] integerForKey:@"HPTutorialGiven"] == 0)
    {
        [[[HPDataManager sharedInstance] currentConfiguration] writeDefaults];
        [[[HPDataManager sharedInstance] currentConfiguration] saveConfigurationToFile];

        return %orig;
    }

    return %orig;
}

%end

