//
//  ValidationViewController.h
//  MHValidationViewController
//
//  Created by Mario Hahn on 12.07.13.
//  Copyright (c) 2013 Mario Hahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIVIiew+MHValidation.h"

@interface ValidationViewController : UIViewController
@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UIButton *validateButton;
@property (nonatomic,strong) IBOutlet UITextField *firstName;
@property (nonatomic,strong) IBOutlet UITextField *secondName;
@property (nonatomic,strong) IBOutlet UITextField *email;
@end