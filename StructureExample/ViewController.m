//
//  ViewController.m
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "ViewController.h"
#import "ConstantPublicHeader.h"
#import "WXBaseViewModel.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WXBaseViewModel *viewModel = [[WXBaseViewModel alloc] init];
    
    [viewModel startWithCompletionBlockWithSuccess:^(__kindof WXBaseRequest *request, id responseObject) {
        
        
    } failure:^(__kindof WXBaseRequest *request, id responseObject) {
        
    }];
    
//    NSOperationQueue
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
