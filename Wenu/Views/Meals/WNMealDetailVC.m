//
//  WNMealDetailVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 24/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNMealDetailVC.h"
#import "MealDetailVM.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface WNMealDetailVC ()

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) IBOutlet UILabel *categoriesLabel;

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *synchronizeViewHeight;
@property (nonatomic, strong) IBOutlet UIButton *synchronizeButton;
@property (nonatomic, assign) CGFloat defaultSynchronizedViewHeight;

@end


@implementation WNMealDetailVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[self.viewModel navigationTitle]];
    [self addBarButtons];
    
    [self.synchronizeButton configureDefaultFooterButton];
    self.defaultSynchronizedViewHeight = [self.synchronizeViewHeight constant];
    
    [self subscribeRacEvents];
}

#pragma mark - Selectors

- (void)editButtonPressed:(UIBarButtonItem *)sender {
    
    [self.viewModel goToEditingMeal];
}

- (IBAction)synchronizeButtonPressed:(UIButton *)sender {
    
    [self.viewModel synchronizeWithServer];
}

#pragma mark - Private

- (void)addBarButtons {
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                  target:self
                                                  action:@selector(editButtonPressed:)];
}

- (void)subscribeRacEvents {
    
    @weakify(self)
    RAC(self.titleLabel, text) = RACObserve(self.viewModel, mealTitle);
    RAC(self.dateLabel, text) = RACObserve(self.viewModel, dateString);
    RAC(self.descriptionLabel, text) = RACObserve(self.viewModel, mealDescription);
    
    [RACObserve(self.viewModel, pictureURL) subscribeNext:^(NSString *url) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.imageView cancelImageDownloadTask];
        if (!url) {
            
            return;
        }
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [self.imageView setImageWithURLRequest:imageRequest
                              placeholderImage:[UIImage imageNamed:@"plate"]
                                       success:nil
                                       failure:nil];
    }];
    
    [RACObserve(self.viewModel, categories) subscribeNext:^(NSArray *categories) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        NSMutableString *categoriesText;
        
        if ([categories count]) {
            
            categoriesText = [[NSMutableString alloc] init];
            BOOL inputComma = NO;
            for (NSString *categoryName in categories) {
                
                [categoriesText appendFormat:@"%@%@", inputComma ? @", " : @"", categoryName];
                
                inputComma = YES;
            }
        }
        
        [self.categoriesLabel setText:categoriesText];
    }];
    
    [RACObserve(self.viewModel, isSynchronized) subscribeNext:^(NSNumber *isSynchronized) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.synchronizeViewHeight setConstant:[isSynchronized boolValue] ? 0.f : self.defaultSynchronizedViewHeight];
        
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             [self.view layoutIfNeeded];
                         }];
    }];
    
    [[self.viewModel.goBack takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(id _) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
