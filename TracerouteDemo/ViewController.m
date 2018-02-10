//
//  ViewController.m
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/6.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import "ViewController.h"
#import "Traceroute.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ipAddressField;
@property (weak, nonatomic) IBOutlet UITextView *resultView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icmpTraceroutePressed:(id)sender {
    _resultView.text = @"";
    NSString *target = _ipAddressField.text;
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [Traceroute startTracerouteWithHost:target
                                     isIPv6:NO
                               stepCallback:^(TracerouteRecord *record) {
                                   NSString *text = [NSString stringWithFormat:@"%@%@\n", _resultView.text, record];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       _resultView.text = text;
                                   });
                                   
                               } finish:^(NSArray<TracerouteRecord *> *results, BOOL succeed) {
                                   NSMutableString *text = [_resultView.text mutableCopy];
                                   if (succeed) {
                                       [text appendString:@"> Traceroute成功 <"];
                                   } else {
                                       [text appendString:@"> Traceroute失败 <"];
                                   }
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       _resultView.text = [text copy];
                                   });
                                   
                               }];
    });
}

@end
