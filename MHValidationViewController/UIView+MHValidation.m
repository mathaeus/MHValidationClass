//
//  ViewController.m
//  MHValidationViewController
//
//  Created by Mario Hahn on 15.05.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import "UIView+MHValidation.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")



NSString * const SHAKE_OBJECTS_IDENTIFIER = @"SHAKE_OBJECTS_IDENTIFIER";
NSString * const CLASS_OBJECTS_IDENTIFIER = @"CLASS_OBJECTS_IDENTIFIER";
NSString * const ENABLE_NEXTPREV_IDENTIFIER = @"ENABLE_NEXTPREV_IDENTIFIER";
NSString * const CUSTOMIZATION_IDENTIFIER = @"CUSTOMIZATION_IDENTIFIER";



@implementation MHTextView

-(id)initWithFrame:(CGRect)frame customization:(MHTextObjectsCustomization*)customization isSelected:(BOOL)isSelected{
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    self.isSelected = isSelected;
    self.customization = customization;
    self.backgroundColor = [UIColor clearColor];
    return self;
}


-(void)drawRect:(CGRect)rect{
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIColor* gradientColorUp = self.customization.borderGradientColorUp;
    UIColor* gradientColorDown = self.customization.borderGradientColorDow;
    UIColor* backgroundColor = self.customization.backgroundColor;
    UIColor* shadow = self.customization.innerShadowColor;
    if (self.isSelected) {
        gradientColorUp = self.customization.selectionGradientBorderColorUp;
        gradientColorDown = self.customization.selectionGradientBorderColorDown;
        backgroundColor = self.customization.selectionBackgroundColor;
        shadow = self.customization.selectionInnerShadowColor;
    }

    
    NSArray* gradientColorsForBorder = [NSArray arrayWithObjects:
                                (id)gradientColorUp.CGColor,
                                (id)gradientColorDown.CGColor, nil];
    CGFloat gradientColorsForBorderLocations[] = {0, 1};
    CGGradientRef borderGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColorsForBorder, gradientColorsForBorderLocations);

    
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 2.5;

    
    UIBezierPath* borderGradientPath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1, 1, rect.size.width-2, rect.size.height-2) cornerRadius: self.customization.cornerRadius];
    CGContextSaveGState(context);
    [borderGradientPath addClip];
    CGContextDrawLinearGradient(context, borderGradient, CGPointMake(((rect.size.width-2)/2)+1, 1), CGPointMake(((rect.size.width-2)/2)+1, 1+rect.size.height-2), 0);
    CGContextRestoreGState(context);
        
    UIBezierPath* rectangle2Path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1+self.customization.borderWidth, 1+self.customization.borderWidth, rect.size.width-((1+self.customization.borderWidth)*2), rect.size.height-((1+self.customization.borderWidth)*2)) cornerRadius: self.customization.cornerRadius];
    [backgroundColor setFill];
    [rectangle2Path fill];
    
    CGRect rectangle2BorderRect = CGRectInset([rectangle2Path bounds], -shadowBlurRadius, -shadowBlurRadius);
    rectangle2BorderRect = CGRectOffset(rectangle2BorderRect, -shadowOffset.width, -shadowOffset.height);
    rectangle2BorderRect = CGRectInset(CGRectUnion(rectangle2BorderRect, [rectangle2Path bounds]), -1, -1);
    
    UIBezierPath* rectangle2NegativePath = [UIBezierPath bezierPathWithRect: rectangle2BorderRect];
    [rectangle2NegativePath appendPath: rectangle2Path];
    rectangle2NegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(rectangle2BorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [rectangle2Path addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectangle2BorderRect.size.width), 0);
        [rectangle2NegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [rectangle2NegativePath fill];
    }
    CGContextRestoreGState(context);

    CGGradientRelease(borderGradient);
    CGColorSpaceRelease(colorSpace);
    
}
/*-(void)drawRect:(CGRect)rect{
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor* borderColor = self.customization.borderColor;
    UIColor* fillColor = self.customization.backgroundColor;

    if (self.isSelected) {
        borderColor =  self.customization.selectionBorderColor;
        fillColor = self.customization.selectionBackgroundColor;
    }
    
    

    
    UIColor* innerShadowColor = self.customization.innerShadowColor;

    UIColor* shadow = innerShadowColor;
    CGSize shadowOffset = CGSizeMake(0.1, -0.1);
    CGFloat shadowBlurRadius = 3.5;

    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(1, 1, rect.size.width-2, rect.size.height-2) cornerRadius: self.customization.cornerRadius];
    [fillColor setFill];
    [rectanglePath fill];
    
    CGRect rectangleBorderRect = CGRectInset([rectanglePath bounds], -shadowBlurRadius, -shadowBlurRadius);
    rectangleBorderRect = CGRectOffset(rectangleBorderRect, -shadowOffset.width, -shadowOffset.height);
    rectangleBorderRect = CGRectInset(CGRectUnion(rectangleBorderRect, [rectanglePath bounds]), -1, -1);
    
    UIBezierPath* rectangleNegativePath = [UIBezierPath bezierPathWithRect: rectangleBorderRect];
    [rectangleNegativePath appendPath: rectanglePath];
    rectangleNegativePath.usesEvenOddFillRule = YES;
    
    CGContextSaveGState(context);
    {
        CGFloat xOffset = shadowOffset.width + round(rectangleBorderRect.size.width);
        CGFloat yOffset = shadowOffset.height;
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
                                    shadowBlurRadius,
                                    shadow.CGColor);
        
        [rectanglePath addClip];
        CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(rectangleBorderRect.size.width), 0);
        [rectangleNegativePath applyTransform: transform];
        [[UIColor grayColor] setFill];
        [rectangleNegativePath fill];
    }
    CGContextRestoreGState(context);
    
    [borderColor setStroke];
    rectanglePath.lineWidth = self.customization.borderWidth;
    [rectanglePath stroke];
}*/

@end


@implementation MHTextObjectsCustomization

- (id)initWithClassesForCustomization:(NSArray*)classes
                      backgroundColor:(UIColor*)backgroundColor
             selectionBackgroundColor:(UIColor*)selectionBackgroundColor
                borderGradientColorUp:(UIColor*)borderGradientColorUp
               borderGradientColorDow:(UIColor*)borderGradientColorDow
       selectionGradientBorderColorUp:(UIColor*)selectionGradientBorderColorUp
     selectionGradientBorderColorDown:(UIColor*)selectionGradientBorderColorDown
                          borderWidth:(float)borderWidth
                         cornerRadius:(float)cornerRadius
                     innerShadowColor:(UIColor*)innerShadowColor
            selectionInnerShadowColor:(UIColor*)selectionInnerShadowColor
                           labelColor:(UIColor*)labelColor
                            labelFont:(UIFont*)labelFont
                  selectionLabelColor:(UIColor*)selectionLabelColor
{
    self = [super init];
    if (!self)
        return nil;
    self.classes = classes;
    self.backgroundColor = backgroundColor;
    self.selectionBackgroundColor = selectionBackgroundColor;
    self.borderGradientColorDow = borderGradientColorDow;
    self.borderGradientColorUp = borderGradientColorUp;
    self.selectionGradientBorderColorDown = selectionGradientBorderColorDown;
    self.selectionGradientBorderColorUp = selectionGradientBorderColorUp;
    self.borderWidth = borderWidth;
    self.cornerRadius = cornerRadius;
    self.innerShadowColor = innerShadowColor;
    self.labelColor = labelColor;
    self.labelFont = labelFont;
    self.selectionLabelColor = selectionLabelColor;
    self.selectionInnerShadowColor = selectionInnerShadowColor;
    return self;
}


@end


@implementation MHValidationItem

-(id)initWithObject:(id)object regexString:(NSString *)regexString{
    self = [super init];
    if (!self)
        return nil;
    self.object = object;
    self.regexString = regexString;
    return self;
}
@end



@implementation UIView (MHValidation)
@dynamic classObjects;
@dynamic showNextAndPrevSegmentedControl;
@dynamic shouldShakeNonValidateObjects;
@dynamic textObjectsCustomization;



//SHAKE OBEJCTS
-(void)setShouldShakeNonValidateObjects:(BOOL)shouldShakeNonValidateObjects{
    objc_setAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER, [NSNumber numberWithBool:shouldShakeNonValidateObjects], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)shouldShakeNonValidateObjects{
    return [objc_getAssociatedObject(self, &SHAKE_OBJECTS_IDENTIFIER) boolValue];
}

//CUSTOMIZATION
-(void)setTextObjectsCustomization:(MHTextObjectsCustomization *)textObjectsCustomization{
    objc_setAssociatedObject(self, &CUSTOMIZATION_IDENTIFIER, textObjectsCustomization, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(MHTextObjectsCustomization*)textObjectsCustomization{
    return objc_getAssociatedObject(self, &CUSTOMIZATION_IDENTIFIER);
}


//ENABLE NEXT PREV
-(void)setShowNextAndPrevSegmentedControl:(BOOL)showNextAndPrevSegmentedControl{
    objc_setAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER, [NSNumber numberWithBool:showNextAndPrevSegmentedControl], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(BOOL)showNextAndPrevSegmentedControl{
    return [objc_getAssociatedObject(self, &ENABLE_NEXTPREV_IDENTIFIER) boolValue];
}

//CLASS OBEJCTS
-(void)setClassObjects:(NSArray *)classObjects{
    objc_setAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER, classObjects, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSArray*)classObjects{
    return objc_getAssociatedObject(self, &CLASS_OBJECTS_IDENTIFIER);
}

-(void)searchForObjectsOfClass:(NSArray*)classes
        selectNextOrPrevObject:(MHSelectionType)selectionType
              foundObjectBlock:(void(^)(id object,
                                        MHSelectedObjectType objectType )
                                )FoundObjectBlock{
    
    
    id selectedObject = [self findFirstResponderOnView:self];
    NSMutableArray *classesOnlyText = [NSMutableArray new];
    for (id classFromClasses in classes) {
        if ([[classFromClasses class] isEqual:[UITextView class]]||[[classFromClasses class] isEqual:[UITextField class]]) {
            [classesOnlyText addObject:classFromClasses];
        }
    }
    NSArray *allObjectsWhichAreKindOfClasses = [self findObjectsofClass:classesOnlyText onView:self showOnlyNonHiddenObjects:YES];
    if (allObjectsWhichAreKindOfClasses.count<=1) {
        [self hideSegment:YES];
    }else{
        [self hideSegment:NO];
    }
    
    NSComparator comparatorBlock = ^(id obj1, id obj2) {
        if ([obj1 frame].origin.y > [obj2 frame].origin.y) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 frame].origin.y < [obj2 frame].origin.y) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    id objectWhichShouldBecomeFirstResponder= nil;
    NSMutableArray *fieldsSort = [[NSMutableArray alloc]initWithArray:allObjectsWhichAreKindOfClasses];
    [fieldsSort sortUsingComparator:comparatorBlock];
    for (id viewsAndFields in fieldsSort) {
        if (([viewsAndFields frame].origin.y == [selectedObject frame].origin.y)&&([viewsAndFields frame].origin.x > [selectedObject frame].origin.x) ) {
            objectWhichShouldBecomeFirstResponder = viewsAndFields;
            break;
        }
        if (([viewsAndFields frame].origin.y > [selectedObject frame].origin.y) ) {
            objectWhichShouldBecomeFirstResponder = viewsAndFields;
            break;
        }
    }
    if (selectionType == MHSelectionTypeNext ) {
        if (objectWhichShouldBecomeFirstResponder) {
            int index = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
            if (index == fieldsSort.count-1) {
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeLast);
                [self disableSegment:MHSelectionTypeNext];
            }else{
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
            }
            return;
        }
    }else if(selectionType == MHSelectionTypePrev){
        int index = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
        if (index ==1) {
            FoundObjectBlock(nil,MHSelectedObjectTypeFirst);
            return;
        }
        
        if (!objectWhichShouldBecomeFirstResponder) {
            int index = [fieldsSort indexOfObject:[self findFirstResponderOnView:self]];
            objectWhichShouldBecomeFirstResponder = [fieldsSort objectAtIndex:index-1];
            FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
            
            return;
        }
        
        if (index>=2) {
            objectWhichShouldBecomeFirstResponder = [fieldsSort objectAtIndex:index-2];
            if (index == NSNotFound && [selectedObject isFirstResponder ]) {
                FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
            }else{
                int firstresponderIndex = [fieldsSort indexOfObject:objectWhichShouldBecomeFirstResponder];
                if (firstresponderIndex ==0) {
                    FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
                    [self disableSegment:MHSelectionTypePrev];
                }else{
                    FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeMiddle);
                }
            }
        }else{
            FoundObjectBlock(objectWhichShouldBecomeFirstResponder,MHSelectedObjectTypeFirst);
            
        }
    }else{
        if ([fieldsSort indexOfObject:[self findFirstResponderOnView:self]]==0) {
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeFirst);
        }else if ([fieldsSort indexOfObject:[self findFirstResponderOnView:self]]==fieldsSort.count-1) {
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeLast);
        }else{
            FoundObjectBlock([self findFirstResponderOnView:self],MHSelectedObjectTypeMiddle);
        }
    }
    if ([selectedObject isFirstResponder] && selectionType == MHSelectionTypeNext) {
        FoundObjectBlock(nil,MHSelectedObjectTypeLast);
    }
}
-(void)hideSegment:(BOOL)hide{
    id firstresponder = [self findFirstResponderOnView:self];
    for (id object in [[firstresponder inputAccessoryView] subviews]) {
        if ([object isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segm = object;
            [segm setHidden:hide];
        }
    }
    
}
-(void)disableSegment:(MHSelectionType)mhselectionType{
    id firstresponder = [self findFirstResponderOnView:self];
    for (id object in [[firstresponder inputAccessoryView] subviews]) {
        if ([object isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segm = object;
            if (mhselectionType == MHSelectionTypePrev) {
                [segm setEnabled:NO forSegmentAtIndex:0];
            }else{
                [segm setEnabled:NO forSegmentAtIndex:1];
            }
        }
    }
}
-(void)dismissInputView{
    [self endEditing:YES];
}



-(void)keyboardWillShow:(NSNotification*)not{

    
    if (![not userInfo]) {
        
        if (self.showNextAndPrevSegmentedControl) {
            [self setCustomization:self.textObjectsCustomization
                        forObjects:[self findObjectsofClass:self.textObjectsCustomization.classes
                                                     onView:self
                                   showOnlyNonHiddenObjects:NO]];
            id firstResponder = [self findFirstResponderOnView:self];
            if (![firstResponder inputAccessoryView]) {
                [firstResponder becomeFirstResponder];

                UIToolbar *toolBar = [self toolbarInit];
                [toolBar sizeToFit];
                [firstResponder setInputAccessoryView:toolBar];
                if ([firstResponder isKindOfClass:[UITextView class]]) {
                    [self endEditing:YES];
                }
            }
            [self searchForObjectsOfClass:self.classObjects
                   selectNextOrPrevObject:MHSelectionTypeCurrent
                         foundObjectBlock:^(id object,
                                            MHSelectedObjectType objectType
                                            ) {
                             
                             if (objectType == MHSelectedObjectTypeFirst) {
                                 [self disableSegment:MHSelectionTypePrev];
                             }else if(objectType == MHSelectedObjectTypeLast){
                                 [self disableSegment:MHSelectionTypeNext];
                             }
                         }];
            
        }
    }else{
        id firstResponder = [self findFirstResponderOnView:self];

        if ([self isKindOfClass:[UIScrollView class]]) {
            
            [self adjustContentOffset];
            
            if (![firstResponder isKindOfClass:[UITextField class]]|| ![firstResponder isKindOfClass:[UITextView class]] || !firstResponder) {
                UIScrollView *scroll = (UIScrollView*)self;
                [scroll setContentInset:UIEdgeInsetsMake(scroll.contentInset.top, scroll.contentInset.left, scroll.contentInset.bottom+280, scroll.contentInset.right)];
            }
        }
    }
}




-(void)adjustContentOffset{
    UIScrollView *scroll = (UIScrollView*)self;
    
    id firstResponder = [self findFirstResponderOnView:self];
    
    if([firstResponder frame].origin.y+[firstResponder frame].size.height<(self.bounds.size.height-[firstResponder inputAccessoryView].frame.size.height-250)){
        [scroll setContentOffset:CGPointMake(0,0) animated:YES];
    }else{
        [scroll setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0,([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+265, 0)];
        [scroll setContentOffset:CGPointMake(0,([firstResponder frame].origin.y+ [firstResponder frame].size.height)- self.bounds.size.height+265) animated:YES];
    }
    
}

- (UIImage *)imageByRenderingView:(id)view{
    CGFloat scale = 1.0;
    if([[UIScreen mainScreen]respondsToSelector:@selector(scale)]) {
        CGFloat tmp = [[UIScreen mainScreen]scale];
        if (tmp > 1.5) {
            scale = 2.0;
        }
    }
    if(scale > 1.5) {
        UIGraphicsBeginImageContextWithOptions([view bounds].size, NO, scale);
    } else {
        UIGraphicsBeginImageContext([view bounds].size);
    }
    
    
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}



-(void)setCustomization:(MHTextObjectsCustomization*)customization
             forObjects:(NSArray*)customizationObjects{
    
    for (id object in customizationObjects) {
        BOOL isSelected =NO;
        if (object == [self findFirstResponderOnView:self]) {
            isSelected =YES;
        }
        
        MHTextView *txtView = [[MHTextView alloc]initWithFrame:[object frame]
                                                 customization:customization
                                                    isSelected:isSelected];
            if ([object isKindOfClass:[UITextField class]]) {
                [object setBorderStyle:UITextBorderStyleNone];
                [object setBackground:[self imageByRenderingView:txtView]];
                UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
                [object setLeftView:paddingView];
                [object setLeftViewMode:UITextFieldViewModeAlways];
                [object setRightView:paddingView];
                [object setRightViewMode:UITextFieldViewModeAlways];
                [object setBorderStyle:UITextBorderStyleNone];
            }else{
                [object setBackgroundColor:[UIColor colorWithPatternImage:[self imageByRenderingView:txtView] ]];
            }
        
            [object setFont:customization.labelFont];
            [object setTextColor:customization.labelColor];

            if (isSelected) {
                [object setTextColor:customization.selectionLabelColor];
            }
    }
}



-(void)doTextFieldShadowForObject:(id)object{
    
}


-(void)keyboardWillHide:(id)sender{
    [self setCustomization:self.textObjectsCustomization
                forObjects:[self findObjectsofClass:self.textObjectsCustomization.classes
                                             onView:self
                           showOnlyNonHiddenObjects:NO]];
    
    if (self.showNextAndPrevSegmentedControl) {
        if ([self isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll= (UIScrollView*)self;
            [scroll setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [scroll setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [scroll setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
}

-(void)installMHValidationWithClasses:(NSArray*)typeOfClasses
                setCustomizationBlock:(void(^)(MHTextObjectsCustomization *customization))CustomizationBlock{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UITextViewTextDidBeginEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
    if (CustomizationBlock) {
        self.textObjectsCustomization = [self setDefaultCustomization];
        CustomizationBlock(self.textObjectsCustomization);
        [self setCustomization:self.textObjectsCustomization
                    forObjects:[self findObjectsofClass:self.textObjectsCustomization.classes
                                                 onView:self
                               showOnlyNonHiddenObjects:NO]];
        

    }
    
    self.classObjects = typeOfClasses;
    [self findObjectsofClass:typeOfClasses
                      onView:self
    showOnlyNonHiddenObjects:NO];
}
-(MHTextObjectsCustomization*)setDefaultCustomization{
    return [[MHTextObjectsCustomization alloc]initWithClassesForCustomization:@[[UITextField class],[UITextView class]]
                                                              backgroundColor:[UIColor whiteColor]
                                                     selectionBackgroundColor:[UIColor whiteColor]
                                                        borderGradientColorUp:[UIColor colorWithRed:0.65f green:0.64f blue:0.63f alpha:1.00f]
                                                       borderGradientColorDow:[UIColor colorWithRed:0.91f green:0.89f blue:0.88f alpha:1.00f]
                                               selectionGradientBorderColorUp:[UIColor colorWithRed:0.64f green:0.00f blue:0.00f alpha:1.00f]
                                             selectionGradientBorderColorDown:[UIColor colorWithRed:0.94f green:0.30f blue:0.36f alpha:1.00f]
                                                                  borderWidth:1
                                                                 cornerRadius:8
                                                             innerShadowColor:[UIColor grayColor]
                                                    selectionInnerShadowColor:[UIColor redColor]
                                                                   labelColor:[UIColor blackColor]
                                                                    labelFont:[UIFont systemFontOfSize:12]
                                                          selectionLabelColor:[UIColor blackColor]];
}

- (UIView*)findFirstResponderOnView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderOnView:childView];
        if ( result ) return result;
    }
    return nil;
}

-(void)prevOrNext:(UISegmentedControl*)segm{
    
    MHSelectionType type = MHSelectionTypePrev;
    
    if (segm.selectedSegmentIndex ==1) {
        type = MHSelectionTypeNext;
    }
    
    
    [self searchForObjectsOfClass:self.classObjects
           selectNextOrPrevObject:type
                 foundObjectBlock:^(id object,
                                    MHSelectedObjectType objectType
                                    ) {
                     [object becomeFirstResponder];
                 }];
}

-(UISegmentedControl *)prevNextSegment {
    UISegmentedControl*  prevNextSegment = [[UISegmentedControl alloc] initWithItems:@[ NSLocalizedString(@"Zurück", nil), NSLocalizedString(@"Weiter", nil) ]];
    prevNextSegment.momentary = YES;
    prevNextSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [prevNextSegment addTarget:self
                        action:@selector(prevOrNext:)
              forControlEvents:UIControlEventValueChanged];
    
    return prevNextSegment;
}

-(UIToolbar *)toolbarInit{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    [barItems addObject:[[UIBarButtonItem alloc] initWithCustomView:[self prevNextSegment]]];
    
    [barItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                      target:nil
                                                                      action:nil]];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(dismissInputView)];
    
    [barItems addObject:doneItem];
    [toolbar setItems:barItems animated:NO];
    return toolbar;
}

-(void)validateWithNONMandatoryTextObjects:(NSArray*)nonMandatoryFields
         validateObjectsWithMHRegexObjects:(NSArray*)regexObject
                     switchesWhichMustBeON:(NSArray*)onSwitches
                        curruptObjectBlock:(void(^)(NSArray *curruptItem)
                                            )CurruptedObjectBlock
                              successBlock:(void(^)(NSString *emailString,
                                                    NSDictionary *valueKeyDict,
                                                    NSArray *object,
                                                    bool isFirstRegistration)
                                            )SuccessBlock{
    
    
    NSArray *fields = [self findObjectsofClass:self.classObjects
                                        onView:self
                      showOnlyNonHiddenObjects:YES];
    
    
    NSMutableArray *curruptFields = [NSMutableArray new];
    [fields enumerateObjectsUsingBlock:^(id field, NSUInteger idx, BOOL *stop) {
        if ([field isKindOfClass:[UITextField class]] || [field isKindOfClass:[UITextView class]]) {
            if ([field alpha]==1) {
                if (([field text].length ==0) && ![nonMandatoryFields containsObject:field]) {
                    [curruptFields addObject:field];
                }
                for (MHValidationItem *item in regexObject) {
                    if ([item.object isEqual:field]) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",item.regexString];
                        BOOL isStringValid = [predicate evaluateWithObject:[field  text]];
                        if (!isStringValid) {
                            [curruptFields addObject:field];
                        }
                    }
                }
            }
        }
        if ([field isKindOfClass:[UISwitch class]]) {
            if(![field isOn] && [onSwitches containsObject:field]){
                [curruptFields addObject:field];
            }
        }
    }];
    if (curruptFields.count) {
        if (CurruptedObjectBlock) {
            CurruptedObjectBlock([NSArray arrayWithArray:curruptFields]);
            if (self.shouldShakeNonValidateObjects) {
                [self shakeObjects:[NSArray arrayWithArray:curruptFields] shakeBorderColor:nil];
            }
        }
    }else{
        if (SuccessBlock) {
            NSString *stringForMail = [NSString new];
            NSMutableDictionary *dictMail = [NSMutableDictionary new];
            for (id object in fields) {
                NSString *objectString = [NSString new];
                if ([object isKindOfClass:[UITextField class]] || [object isKindOfClass:[UITextView class]]) {
                    objectString = [object text];
                }
                if ([object isKindOfClass:[UISwitch class]]) {
                    objectString = @"OFF";
                    if ([object isOn]) {
                        objectString = @"ON";
                    }
                }
                if ([object isKindOfClass:[UISegmentedControl class]]) {
                    objectString = [object titleForSegmentAtIndex:[object selectedSegmentIndex]];
                }
                [dictMail setObject:objectString forKey:[object accessibilityIdentifier]];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",[object accessibilityIdentifier],objectString ]];
            }
            bool isFirstRegistration =NO;
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"MHValidationStorage"]) {
                [dictMail setObject:@"update" forKey:@"status"];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",@"status",@"update" ]];
                
            }else{
                [dictMail setObject:@"new" forKey:@"status"];
                stringForMail = [stringForMail stringByAppendingString:[NSString stringWithFormat:@"<br /><br />%@:         %@",@"status",@"new" ]];
                isFirstRegistration =YES;
            }
            
            [[NSUserDefaults standardUserDefaults]setObject:dictMail forKey:@"MHValidationStorage"];
            [[NSUserDefaults standardUserDefaults ]synchronize];
            SuccessBlock(stringForMail,dictMail,fields,isFirstRegistration);
        }
    }
}
-(NSArray*)findAllTextFieldsInView:(UIView*)view{
    NSMutableArray *fields= [NSMutableArray new];
    for(id field in [view subviews]){
        if([field isKindOfClass:[UITextField class]])
            if (![fields containsObject:field]) {
                [fields addObject:field];
            }
        if([field respondsToSelector:@selector(subviews)]){
            [self findAllTextFieldsInView:field];
        }
    }
    return fields;
}

-(NSArray*)findObjectsofClass:(NSArray*)classArray
                       onView:(UIView*)view
     showOnlyNonHiddenObjects:(BOOL)nonHidden{
    
    
    NSMutableArray *fields= [NSMutableArray new];
    for(id field in [view subviews]){
        for (id class in classArray) {
            if([field isKindOfClass:class]){
                if (![fields containsObject:field]) {
                    if (nonHidden) {
                        BOOL isHidden = NO;
                        if ([field alpha]==0) {
                            isHidden =YES;
                        }
                        if ([field isHidden]) {
                            isHidden =YES;
                        }
                        if (!isHidden) {
                            [fields addObject:field];
                        }
                    }else{
                        [fields addObject:field];
                    }
                }
                if ([field isKindOfClass:[UITextField class]] || [field isKindOfClass:[UITextView class]]) {
                    if (self.showNextAndPrevSegmentedControl) {
                        [field setDelegate:self];
                    }
                }
            }
            if([field respondsToSelector:@selector(subviews)]){
                [self findObjectsofClass:classArray
                                  onView:field
                showOnlyNonHiddenObjects:nonHidden];
                
            }
        }
    }
    return fields;
}

- (void)shakeObjects:(id)objects
    shakeBorderColor:(UIColor*)borderColor{
    
    for (id object in objects){
        CALayer *layer = [object layer];
        if (borderColor) {
            [layer setBorderColor:[borderColor CGColor]];
        }
        CGPoint pos = layer.position;
        static int numberOfShakes = 4;
        CAKeyframeAnimation *shakeAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        CGMutablePathRef shakePath = CGPathCreateMutable();
        CGPathMoveToPoint(shakePath, NULL, pos.x, pos.y);
        int index;
        for (index = 0; index < numberOfShakes; ++index){
            CGPathAddLineToPoint(shakePath, NULL, pos.x - 8, pos.y);
            CGPathAddLineToPoint(shakePath, NULL, pos.x + 8, pos.y);
        }
        CGPathAddLineToPoint(shakePath, NULL, pos.x, pos.y);
        CGPathCloseSubpath(shakePath);
        shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        shakeAnimation.duration = 1.2;
        shakeAnimation.path = shakePath;
        [layer addAnimation:shakeAnimation forKey:nil];
    }
}


@end
