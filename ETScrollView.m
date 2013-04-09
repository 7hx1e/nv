//
//  ETScrollView.m
//  Notation
//
//  Created by elasticthreads on 3/14/11.
//

#import "ETScrollView.h"
#import "ETTransparentScroller.h"
#import "ETOverlayScroller.h"
#import "GlobalPrefs.h"
#import "LinkingEditor.h"

@implementation ETScrollView


- (NSView *)hitTest:(NSPoint)aPoint{
    if([[[self documentView]className] isEqualToString:@"LinkingEditor"]){
        NSRect vsRect=[[self verticalScroller] frame];
        vsRect.origin.x-=4.0;
        vsRect.size.width+=4.0;
        
        if (NSPointInRect (aPoint,vsRect)) {
            return [self verticalScroller];
        }else if (IsLionOrLater){
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
            if([[self subviews]containsObject:[self findBarView]]) {
                NSView *tView=[super hitTest:aPoint];
                if ([tView superview]==[self findBarView]) {
                    return tView;
                }
            }
#endif
        }
        [[self documentView]setMouseInside:YES];
        return [self documentView];
    }
    return [super hitTest:aPoint];
}


//- (void)setScrollerClassWithString:(NSString *)scrollerClassName{
//    scrollerClass=NSClassFromString(scrollerClassName);
//}
//
//- (void)setNeedsOverlayTiling:(BOOL)overlay{
//    needsOverlayTiling=overlay;
//}

- (void)awakeFromNib{ 
    needsOverlayTiling=NO;
    BOOL fillIt=NO;
    if([[[self documentView]className] isEqualToString:@"NotesTableView"]){
        scrollerClass=NSClassFromString(@"ETOverlayScroller"); 
        if (!IsLionOrLater) {
            needsOverlayTiling=YES;            
        }
    }else{
        scrollerClass=NSClassFromString(@"ETTransparentScroller");   
        if (!IsLionOrLater) {
            fillIt=YES;            
        }
    }
#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
    if (IsLionOrLater) {
        [[GlobalPrefs defaultPrefs] registerForSettingChange:@selector(setUseETScrollbarsOnLion:sender:) withTarget:self];
        [self setHorizontalScrollElasticity:NSScrollElasticityNone];
        [self setVerticalScrollElasticity:NSScrollElasticityAllowed];
        [self setScrollerStyle:NSScrollerStyleOverlay];   
    }
#endif    
    if (!IsLionOrLater||([[GlobalPrefs defaultPrefs]useETScrollbarsOnLion])) {
//        NSRect vsRect=[[self verticalScroller]frame];
//        id theScroller=[[scrollerClass alloc]initWithFrame:vsRect];
         id theScroller=[[scrollerClass alloc]init];
        [theScroller setFillBackground:fillIt];
        [self setVerticalScroller:theScroller];
        [theScroller release];
    }
}


#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_7
- (void)settingChangedForSelectorString:(NSString*)selectorString{  
    if (IsLionOrLater&&([selectorString isEqualToString:SEL_STR(setUseETScrollbarsOnLion:sender:)])){
        [self changeUseETScrollbarsOnLion];
    }
}

- (void)changeUseETScrollbarsOnLion{
    if ([[GlobalPrefs defaultPrefs]useETScrollbarsOnLion]) {       
//        NSRect vsRect=[[self verticalScroller]frame];
//        id theScroller=[[scrollerClass alloc]initWithFrame:vsRect];
         id theScroller=[[scrollerClass alloc]init];
        [self setVerticalScroller:theScroller];
        [theScroller release];
        
    }else{
//        id oldScrollers=[self verticalScroller];
        NSScroller *theScroller=[[NSScroller alloc]init];
        [self setVerticalScroller:theScroller];
        [theScroller release];
//        [oldScrollers release];
        
    }
    [self setScrollerStyle:NSScrollerStyleOverlay];
    [self tile];
    [self reflectScrolledClipView:[self contentView]];
}
#endif

- (void)tile {
	[super tile];
    if (needsOverlayTiling) {
        if (![[self verticalScroller] isHidden]) {
            //            NSRect vsRect=[[self verticalScroller] frame];
            NSRect conRect = [[self contentView] frame];
            //            NSView *wdContent = [[self contentView] retain];
            conRect.size.width = conRect.size.width + [[self verticalScroller] frame].size.width;
            [[self contentView] setFrameSize:conRect.size];
            //            [wdContent setFrame:conRect];
            //            [wdContent release];
            //            [[self verticalScroller] setFrame:vsRect];            
        }
    }
}


@end
