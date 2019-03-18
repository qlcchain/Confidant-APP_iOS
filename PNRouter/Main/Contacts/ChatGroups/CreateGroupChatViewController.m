//
//  CreateGroupChatViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CreateGroupChatViewController.h"

@interface CreateGroupChatViewController ()
@property (nonatomic , strong) NSMutableArray *persons;
@end

@implementation CreateGroupChatViewController

- (instancetype)initWithContacts:(NSArray *)contacts
{
    if (self = [super init]) {
        [self.persons addObjectsFromArray:contacts];
    }
    return self;
}
#pragma mark - layz
- (NSMutableArray *)persons
{
    if (!_persons) {
        _persons = [NSMutableArray array];
    }
    return _persons;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)approveSwitchAction:(id)sender {
    
}

- (IBAction)createGroupChatAction:(id)sender {
    
}


@end
