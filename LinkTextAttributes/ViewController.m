//
//  ViewController.m
//  LinkTextAttributes
//
//  Created by Hosel on 2017/9/8.
//  Copyright © 2017年 Hosel. All rights reserved.
//

#import "ViewController.h"

// 屏幕大小
#define ScreenBounds ([UIScreen mainScreen].bounds)
// 屏幕宽度
#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
// 屏幕高度
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

//十六进制颜色的RGB转换
#define UIColorFromRGB(rgbValue,alp) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alp]

@interface ViewController ()<UITextViewDelegate>

@property(nonatomic,weak)UITextView *linkTV;
@property(nonatomic,assign)BOOL select;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.select = NO;
    
    [self setSubView];//设置子view
    [self setLinkText];//设置文本
}

//设置子view
- (void)setSubView{
    UIFont *linkFont = [UIFont systemFontOfSize:14.0];
    CGFloat linkW = ScreenWidth - 10*2;
    
    UITextView *linkTV = [[UITextView alloc]initWithFrame:CGRectMake(10, 100, linkW, 100)];
    self.linkTV = linkTV;
    linkTV.userInteractionEnabled = YES;
    linkTV.font = linkFont;
    linkTV.textColor = UIColorFromRGB(0x999999,1.0);
    [self.view addSubview:linkTV];
    linkTV.editable = NO;//必须禁止输入，否则点击将弹出输入键盘
    linkTV.scrollEnabled = NO;
    linkTV.delegate = self;
    linkTV.textContainerInset = UIEdgeInsetsMake(0,0, 0, 0);//文本距离边界值
}

//设置文本
- (void)setLinkText{
    NSString *linkStr = @"我已阅读《登录协议》和《注册协议》，并且还有《支付宝支付协议》、《微信支付协议》，《中国工商银行协议》、《中国银行协议》、《中国建设银行协议》、《中国农业银行协议》";
    UIFont *linkFont = [UIFont systemFontOfSize:14.0];
    CGFloat linkW = ScreenWidth - 10*2;
    CGSize linkSize = [self getAttributionHeightWithString:linkStr lineSpace:1.5 kern:1 font:linkFont width:linkW];
    self.linkTV.frame = CGRectMake(10, 100, linkW, linkSize.height);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:linkStr];
    [attributedString addAttribute:NSLinkAttributeName value:@"login://" range:[[attributedString string] rangeOfString:@"《登录协议》"]];
    [attributedString addAttribute:NSLinkAttributeName value:@"register://" range:[[attributedString string] rangeOfString:@"《注册协议》"]];
    
    CGSize size = CGSizeMake(12, 12);
    UIImage *image = [UIImage imageNamed:self.select == YES ? @"selected" : @"unSelected"];
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    [image drawInRect:CGRectMake(0, 0.25, 12, 12)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = resizeImage;
    NSMutableAttributedString *imageString = (NSMutableAttributedString *)[NSMutableAttributedString attributedStringWithAttachment:textAttachment];
    [imageString addAttribute:NSLinkAttributeName value:@"checkbox://" range:NSMakeRange(0, imageString.length)];
    [attributedString insertAttributedString:imageString atIndex:0];
//    [attributedString addAttribute:NSFontAttributeName value:linkFont range:NSMakeRange(0, attributedString.length)];
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    //调整行间距
    paragraphStyle.lineSpacing = 1.5;
    NSDictionary *attriDict = @{NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@(1),
                                NSFontAttributeName:linkFont};
    [attributedString addAttributes:attriDict range:NSMakeRange(0, attributedString.length)];
    
    self.linkTV.attributedText = attributedString;
    self.linkTV.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor], NSUnderlineColorAttributeName: [UIColor lightGrayColor], NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
}

/*
 *  设置行间距和字间距
 *
 *  @param string    字符串
 *  @param lineSpace 行间距
 *  @param kern      字间距
 *  @param font      字体大小
 *
 *  @return 富文本
 */
- (NSAttributedString *)getAttributedWithString:(NSString *)string WithLineSpace:(CGFloat)lineSpace kern:(CGFloat)kern font:(UIFont *)font{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    //调整行间距
    paragraphStyle.lineSpacing = lineSpace;
    NSDictionary *attriDict = @{NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@(kern),
                                NSFontAttributeName:font};
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:string attributes:attriDict];
    return attributedString;
}

/* 获取富文本的高度
 *
 * @param string    文字
 * @param lineSpace 行间距
 * @param kern      字间距
 * @param font      字体大小
 * @param width     文本宽度
 *
 * @return size
 */
- (CGSize)getAttributionHeightWithString:(NSString *)string lineSpace:(CGFloat)lineSpace kern:(CGFloat)kern font:(UIFont *)font width:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = lineSpace;
    NSDictionary *attriDict = @{
                                NSParagraphStyleAttributeName:paragraphStyle,
                                NSKernAttributeName:@(kern),
                                NSFontAttributeName:font};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attriDict context:nil].size;
    return size;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"checkbox"]) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.select = !self.select;
        [self setLinkText];//设置文本
        return NO;
    }else if ([[URL scheme] isEqualToString:@"login"]) {
        self.view.backgroundColor = [UIColor redColor];
        return NO;
    }else if ([[URL scheme] isEqualToString:@"register"]) {
        self.view.backgroundColor = [UIColor greenColor];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
