//
//  ViewController.m
//  OpenGLTextureTesting
//
//  Created by Simon Haycock on 16/06/2016.
//  Copyright © 2016 oxygn. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController {
    OpenGLView *glView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tile_floor" ofType:@"png"];
    glView = [[OpenGLView alloc] initWithFrame:screenBounds textureImagePath:nil];
    self.view = glView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
                                   


@end
