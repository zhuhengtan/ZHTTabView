//
//  ViewController.m
//  ZHTTabViewDemo
//
//  Created by admin on 2017/7/26.
//  Copyright © 2017年 zht. All rights reserved.
//

#import "ViewController.h"
#import "ZHTTabView.h"
#import "DemoViewController.h"

@interface ViewController ()<ZHTTabViewDelegate>

@property (nonatomic, strong) NSMutableArray *vcArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ZHTTabView *tabView = [[ZHTTabView alloc] initWithFrame:CGRectMake(0, 20, kScreenW, kScreenH-20)];
    tabView.delegate = self;
    [self.view addSubview:tabView];
    
    self.vcArray = [[NSMutableArray alloc] init];
    
    DemoViewController *vc1 = [[DemoViewController alloc] init];
    vc1.backgroundColor = [UIColor redColor];
    vc1.title = @"第一个";
    [_vcArray addObject:vc1];
    
    DemoViewController *vc2 = [[DemoViewController alloc] init];
    vc2.backgroundColor = [UIColor orangeColor];
    vc2.title = @"第二个";
    [_vcArray addObject:vc2];

    DemoViewController *vc3 = [[DemoViewController alloc] init];
    vc3.backgroundColor = [UIColor yellowColor];
    vc3.title = @"第三个";
    [_vcArray addObject:vc3];
    
    DemoViewController *vc4 = [[DemoViewController alloc] init];
    vc4.backgroundColor = [UIColor greenColor];
    vc4.title = @"第四个";
    [_vcArray addObject:vc4];
    
    DemoViewController *vc5 = [[DemoViewController alloc] init];
    vc5.backgroundColor = [UIColor blackColor];
    vc5.title = @"第五个";
    [_vcArray addObject:vc5];
    
    DemoViewController *vc6 = [[DemoViewController alloc] init];
    vc6.backgroundColor = [UIColor blueColor];
    vc6.title = @"第六个";
    [_vcArray addObject:vc6];
    
    DemoViewController *vc7 = [[DemoViewController alloc] init];
    vc7.backgroundColor = [UIColor purpleColor];
    vc7.title = @"第七个";
    [_vcArray addObject:vc7];
    
    tabView.heightForHead = 60;
    tabView.heightForGap = 30;
    tabView.textColorForStateNormal = [UIColor grayColor];
    tabView.textColorForStateSelected = [UIColor cyanColor];
    
    tabView.backgroundColorForStateSelected = [UIColor lightGrayColor];
    
    tabView.fontForStateNormal = [UIFont systemFontOfSize:12 weight:UIFontWeightLight];
    tabView.fontForStateSelected = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    
    tabView.colorForSeparatorLine = [UIColor yellowColor];
    
    tabView.colorForUnderLine = [UIColor greenColor];
    tabView.heightForUnderLine = 2;
    
    [tabView startBuildingUI];
    [tabView didSelectPageOfIndex:0 animated:NO];
}

-(NSUInteger)numberOfPagesInZHTTabView:(ZHTTabView *)tabView{
    return _vcArray.count;
}

-(UIViewController *)pageViewControllerOfZHTTabView:(ZHTTabView *)tabView indexOfPagers:(NSUInteger)number{
    return _vcArray[number];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
