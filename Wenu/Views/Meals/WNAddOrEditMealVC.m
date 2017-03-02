//
//  WNAddOrEditMealVC.m
//  Wenu
//
//  Created by Ruslan Kurmakaev on 31/07/16.
//  Copyright © 2016 rkurmakaev. All rights reserved.
//

#import "WNAddOrEditMealVC.h"
#import "AddOrEditMealVM.h"
#import "WNDatePickerWithToolbar.h"
#import "WNSwitchCell.h"
#import "WNAddCategoryTableHeaderView.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIViewController+TableViewSignals.h"

static NSString * const AddCategoryHeaderIdentifier = @"WNAddCategoryTableHeaderView";

@interface WNAddOrEditMealVC () <UINavigationControllerDelegate,
                            UIImagePickerControllerDelegate,
                            UITextFieldDelegate,
                            UITableViewDelegate,
                            UITableViewDataSource>


@property (nonatomic, strong) WNDatePickerWithToolbar *datePicker;

@property (nonatomic, strong) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) IBOutlet UITextField *mealTitleTextField;
@property (nonatomic, strong) IBOutlet UIButton *dateButton;
@property (nonatomic, strong) IBOutlet UIImageView *mealImageView;
@property (nonatomic, strong) IBOutlet UITextView *mealDescriptionTextView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tableViewBottomOffset;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end


@implementation WNAddOrEditMealVC

#pragma mark - UIViewController life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self subscribeRacEvents];

    [self.navigationItem setTitle:[self.viewModel navigationTitle]];
    [self addBarButtons];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:AddCategoryHeaderIdentifier bundle:nil] forHeaderFooterViewReuseIdentifier:AddCategoryHeaderIdentifier];
    
    [self.mealTitleTextField setDelegate:self];
    
    self.mealDescriptionTextView.layer.cornerRadius = 8.f;
    
    self.mealTitleTextField.text = [self.viewModel mealTitle];
    [self.mealDescriptionTextView setText:[self.viewModel mealDescription]];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.mainTableView setDelegate:self];
    [self.mainTableView setDataSource:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];

    [self hideDatePicker:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Selectors

- (void)cancelButtonPressed:(UIBarButtonItem *)sender {
    
    [self.viewModel cancelChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed:(UIBarButtonItem *)sender {
    
    if ([self.mealTitleTextField.text length] == 0 || [self.mealDescriptionTextView.text length] == 0) {
        
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@""
                                            message:@"Please, fill in empty fields"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil]];
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
        return ;
    }
    
    [self.viewModel setMealTitle:self.mealTitleTextField.text];
    [self.viewModel setMealDescription:self.mealDescriptionTextView.text];
    [self.viewModel saveChanges];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeImageButtonPressed:(UIButton *)sender {

    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePickerController.delegate = self;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)dateButtonPressed:(UIButton *)sender {
    
    [self hideKeyboard];
    [self hideDatePicker:NO];
    [self.datePicker setDate:[self.viewModel date] animated:NO];
}

- (void)addCategoryButtonPressed:(UIButton *)btn {

    [self.viewModel goToAddingNewCategory];
}

#pragma mark - Private actions

- (void)addBarButtons {
    
    self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancelButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(doneButtonPressed:)];
    
    
}

- (void)subscribeRacEvents {
    
    [self subscribeTableView:self.mainTableView toViewModel:self.viewModel];
    
    @weakify(self)
    [RACObserve(self.viewModel, dateString) subscribeNext:^(NSString *newDate) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.dateButton setTitle:newDate forState:UIControlStateNormal];
    }];
    
    [RACObserve(self.viewModel, pictureURL) subscribeNext:^(NSString *url) {
        @strongify(self)
        
        if (self == nil)
            return ;
        
        [self.mealImageView cancelImageDownloadTask];
        if (!url) {
            
            return;
        }
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        
        [self.mealImageView setImageWithURLRequest:imageRequest
                                  placeholderImage:[UIImage imageNamed:@"plate"]
                                           success:nil
                                           failure:nil];
    }];
}

- (void)hideDatePicker:(BOOL)hide {
    
    if ((self.datePicker != nil && self.datePicker.hidden == hide) || (self.datePicker == nil && hide)) {
        
        return ;
    }
    
    if (!self.datePicker) {
        
        self.datePicker = [WNDatePickerWithToolbar new];
        
        [self.datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.view addSubview:self.datePicker];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_datePicker]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_datePicker)]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_datePicker]|"
                                                                          options:0
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(_datePicker)]];
        
        @weakify (self)
        [self.datePicker setOnCancel:^{
           
            @strongify(self)
            [self hideDatePicker:YES];
        }];
        
        [self.datePicker setOnDateSelected:^(NSDate *date) {
            
            @strongify(self)
            [self.viewModel setDate:date];
            [self hideDatePicker:YES];
        }];
        
        [self.view layoutIfNeeded];
    }
    
    self.datePicker.hidden = hide;
    [self.datePicker.layer WN_addPushAnimationWithDirection:hide ? kCATransitionFromBottom : kCATransitionFromTop
                                                   duration:0.3f];
}

- (void)changeBottomOffset:(CGFloat)offset
                  duration:(CGFloat)duration
                     curve:(UIViewAnimationCurve)curve {
    
    UIViewAnimationOptions options;
    
    switch (curve) {
            
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.f
                        options:options
                     animations:^{
                         
                         [self.tableViewBottomOffset setConstant:offset];
                     }
                     completion:^(BOOL finished) {
                        
                         if ([self.mealDescriptionTextView isFirstResponder]) {
                             
                             [self.mainTableView scrollRectToVisible:[self.mealDescriptionTextView superview].frame animated:YES];
                         }
                     }];
}

#pragma mark - Keyboard apperance

- (void)onKeyboardWillShow:(NSNotification *)notification {
    
    [self hideDatePicker:YES];

    NSDictionary *info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [number floatValue];
    
    UIViewAnimationCurve curve =
    (UIViewAnimationCurve)[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat keyboardHeight = kbSize.height;
    
    [self changeBottomOffset:keyboardHeight - CGRectGetHeight([[self.tabBarController tabBar] bounds])
                    duration:duration
                       curve:curve];
}

- (void)onKeyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    NSNumber *number = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    CGFloat duration = [number floatValue];
    UIViewAnimationCurve curve = (UIViewAnimationCurve)[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    
    [self changeBottomOffset:0.f
                    duration:duration
                       curve:curve];
}

- (void)hideKeyboard {
    
    if ([self.mealTitleTextField isFirstResponder]) {
        
        [self.mealTitleTextField resignFirstResponder];
    }
    else if ([self.mealDescriptionTextView isFirstResponder]) {
        
        [self.mealDescriptionTextView resignFirstResponder];
    }
}

- (void)dismissImagePicker {
    
    if (!self.imagePickerController) {
        
        return ;
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:^{
        
        self.imagePickerController = nil;
    }];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    WNAddCategoryTableHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:AddCategoryHeaderIdentifier];
    
    UIView *view = [[UIView alloc] initWithFrame:headerView.bounds];
    [view setBackgroundColor:[UIColor colorWithRed:200./255. green:200./255. blue:200./255. alpha:1.]];
    [headerView setBackgroundView:view];
    [headerView.titleLabel setText:@"Categories"];
    [headerView.actionButton addTarget:self
                                action:@selector(addCategoryButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"SwitchCell";

    WNSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[WNSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:identifier];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    [cell configure:[self.viewModel categoryForIndexPath:indexPath]];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSInteger numberOfSections = [self.viewModel numberOfSections];
    
    if (numberOfSections == 1 && [self.viewModel numberOfItemsInSection:0] == 0)
        numberOfSections = 0;
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfItemsInSection:section];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideDatePicker:YES];
    [self hideKeyboard];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [self.viewModel setImagePathURL:[info objectForKey:UIImagePickerControllerReferenceURL]];
    
    [self.mealImageView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    
    [self dismissImagePicker];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self dismissImagePicker];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.mealDescriptionTextView becomeFirstResponder];
    
    return YES;
}

@end
