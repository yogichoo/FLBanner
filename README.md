# FLBanner

```
//FLBanner的使用方法
FLBanner *banner = [[FLBanner alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
[banner refreshUI:@[@"fl_image.jpeg", @"fl_image2.jpeg"] action:^(NSInteger index) {
    NSLog(@"=========%zd",index);
}];
[self.view addSubview:banner];
```

<img width="340" alt="image" src="https://user-images.githubusercontent.com/16301241/185619997-aee956d1-0ece-4b2b-adcc-b7ec751e1c5c.png">
