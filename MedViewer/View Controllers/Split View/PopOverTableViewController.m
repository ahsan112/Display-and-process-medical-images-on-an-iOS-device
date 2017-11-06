//
//  PopOverTableViewController.m
//  MedViewer
//
//  Created by Ahsan Mirza on 26/02/2017.
//  Copyright © 2017 Ahsan Mirza. All rights reserved.
//

#import "PopOverTableViewController.h"

@interface PopOverTableViewController ()
@property (nonatomic)NSMutableArray *viewOptions;
@end

@implementation PopOverTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"uitableviewcell"];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(1, 50, 276, 60)];
    headerView.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(13, 5, 120, 75)];
    labelView.text = @"SERIES";
    labelView.font = [labelView.font fontWithSize:14];
    
    [headerView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (id)initWithStyle:(UITableViewStyle)style {
    
    if ([super initWithStyle:style]) {
        _viewOptions = [NSMutableArray array];
        
        [_viewOptions addObject:@"View 1"];
        [_viewOptions addObject:@"View 2"];
        [_viewOptions addObject:@"View 3"];
        [_viewOptions addObject:@"View 4"];
        
        self.clearsSelectionOnViewWillAppear = NO;
        
        NSInteger rowsCount = [_viewOptions count];
        NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView
                                               heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSInteger totalRowsHeight = rowsCount * singleRowHeight;
        
        //Calculate how wide the view should be by finding how
        //wide each string is expected to be
        CGFloat largestLabelWidth = 0;
        for (NSString *colorName in _viewOptions) {
            //Checks size of text using the default font for UITableViewCell's textLabel.
            CGSize labelSize = [colorName sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
            if (labelSize.width > largestLabelWidth) {
                largestLabelWidth = labelSize.width;
            }
        }
        
        //Add a little padding to the width
        CGFloat popoverWidth = largestLabelWidth + 100;
        self.tableView.frame = CGRectMake(0, 0, popoverWidth, totalRowsHeight);
        //Set the property to tell the popover container how big this view will be.
        //self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);
        self.preferredContentSize = CGSizeMake(popoverWidth, 250);
    }
    return self;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_viewOptions count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uitableviewcell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [_viewOptions objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [_popDelgate endSplitView];
        
    }
    
    if (indexPath.row == 1) {
        [_popDelgate twoSplitView];
    }
    
    if (indexPath.row == 2) {
        [_popDelgate threeSplit];
    }
    
    if (indexPath.row == 3) {
        [_popDelgate fourSplitView];
    }
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    
}




@end
