//
//  HPViewController.m
//  HaoMaTong
//
//  Created by Hongtao Guo on 3/31/14.
//  Copyright (c) 2014 guohongtao. All rights reserved.
//

#import "HPViewController.h"
#import "HMTServer.h"
#import "HMTLocationInfo.h"
#import "MBProgressHUD.h"
#import "HMTManager.h"
#import "HMTNumberInfo.h"

@interface HPViewController () <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UIToolbar *inputAccessoryView;

@property (strong, nonatomic) UITableViewCell *infoCell;
@property (strong, nonatomic) UITableViewCell *locationCell;
@property (strong, nonatomic) UISwitch *serviceSwitch;

- (IBAction)toggleService:(id)sender;

@property (strong, nonatomic) NSOperation *locationRequestOperation;
@property (strong, nonatomic) NSOperation *infoRequestOperation;

- (IBAction)activateService:(id)sender;
- (IBAction)deactivateService:(id)sender;

@end

@implementation HPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  self.navigationItem.titleView = _searchBar;
  self.searchBar.delegate = self;
  
  self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Search", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(search:)];
  
  
	// Do any additional setup after loading the view, typically from a nib.
  self.searchBar.keyboardType = UIKeyboardTypeDecimalPad;
  self.searchBar.inputAccessoryView = self.inputAccessoryView;

#ifdef DEBUG
  self.searchBar.text= @"14730359182";
#endif
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
  
  
  
  self.infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  self.infoCell.imageView.image = [UIImage imageNamed:@"icon_info"];
  self.infoCell.separatorInset = UIEdgeInsetsMake(0, 15.0f, 0, 0);
  
  self.locationCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
  self.locationCell.imageView.image = [UIImage imageNamed:@"icon_location"];
  self.locationCell.separatorInset = UIEdgeInsetsMake(0, 15.0f, 0, 0);
  
  self.serviceSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
  [self.serviceSwitch addTarget:self action:@selector(toggleService:) forControlEvents:UIControlEventValueChanged];
  
}
- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - custom accessor
- (UIView *)inputAccessoryView
{
  if (!_inputAccessoryView)
  {
    _inputAccessoryView = [[UIToolbar alloc] init];
    _inputAccessoryView.backgroundColor = [UIColor lightGrayColor];
    _inputAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_inputAccessoryView sizeToFit];
    CGRect frame = _inputAccessoryView.frame;
    frame.size.height = 44.0f;
    _inputAccessoryView.frame = frame;
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search:)];
    [doneBtn setTintColor:[UIColor blackColor]];
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *array = [NSArray arrayWithObjects:flexibleSpaceLeft, doneBtn, nil];
    [_inputAccessoryView setItems:array];
  }
  
  return _inputAccessoryView;
}

- (IBAction)toggleService:(id)sender {
  
  UISwitch *theSwitcher = (UISwitch*)sender;
   if(theSwitcher.on)
   {
     [self activateService:nil];
   }else
   {
     [self activateService:nil];
   }
}


#pragma mark - IBAction

- (IBAction)activateService:(id)sender
{

  [[HMTManager shared] activate];
}

- (IBAction)deactivateService:(id)sender
{

  [[HMTManager shared] deactivate];
}

- (IBAction)search:(id)sender
{

  [self.searchBar resignFirstResponder];
  
  [self.locationRequestOperation cancel];
  UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.locationCell.accessoryView = activityIndicatorView;
  [activityIndicatorView startAnimating];
  
  self.locationRequestOperation = [[HMTServer sharedServer] queryNumberLocation:self.searchBar.text
                                                        success:^(HMTLocationInfo *result) {
                                                          
                                                       
                                                          NSLog(@"result:%@",result);
                                                          self.locationCell.textLabel.text = [result displayString];
                                                          self.locationCell.accessoryView = nil;
                                                          
                                                        } failure:^(NSError *error) {
                                                         

                                                          self.locationCell.textLabel.text = error.localizedDescription;
                                                          self.locationCell.accessoryView = nil;
                                                          
                                                        }];
  
  
  
  [self.infoRequestOperation cancel];

  UIActivityIndicatorView * indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  self.infoCell.accessoryView = indicatorView;
  [indicatorView startAnimating];
  
  
  self.infoRequestOperation =[[HMTServer sharedServer] queryNumberInfo:self.searchBar.text success:^(HMTNumberInfo *result) {
    
    self.infoCell.textLabel.text = result.info;
    self.infoCell.accessoryView = nil;
  } failure:^(NSError *error) {

    self.infoCell.textLabel.text = error.localizedDescription;
    self.infoCell.accessoryView = nil;
  }];
  
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 66.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(indexPath.row == 0 ) return self.locationCell;
  if(indexPath.row == 1 ) return self.infoCell;
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
  cell.textLabel.text = @"来电时，查找电话信息";
  cell.accessoryView = self.serviceSwitch;
  return cell;
}

@end
