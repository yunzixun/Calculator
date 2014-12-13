//
//  Calculate.m
//  MyCalculator
//
//  Created by joyzh on 14/12/7.
//  Copyright (c) 2014年 SSE USTC. All rights reserved.
//

#import "Calculate.h"

@interface Calculate ()

@property (nonatomic, strong) NSMutableArray *arrayToCalculate;
@property (nonatomic, strong)NSMutableArray *
arrayForOperator;

@property (nonatomic, strong) Stack *optr;
@property (nonatomic, strong) Stack *opnd;
@property (nonatomic) NSUInteger optrSize;
@property (nonatomic) NSUInteger opndSize;

@end


@implementation Calculate

-(void)clearAll
{
    self.input = nil;
}

//override getter:如果不这样做有可能得到一个空的对象
-(NSMutableString *)input
{
    if (!_input) {
        _input = [[NSMutableString alloc]init];
    }
    return _input;
}

-(void)clearSpace
{
    self.input = nil;
}

-(void)delNumber
{
    long length = self.input.length - 1;
    if (length >= 0) {
        [self.input deleteCharactersInRange:NSMakeRange(length, 1)];//只删除一个
    }
}


+(NSArray *)validOperator
{
    return @[@"+", @"-", @"*", @"/", @"%", @"(", @")", @"="];
}

+(NSDictionary *)inStackPriority
{
    return @{@"(":@1, @"*":@5, @"/":@5, @"%":@5, @"+":@3, @"-":@3, @")":@8, @"=":@0 };
}

+(NSDictionary *)outStackPriority
{
    return @{@"(":@8, @"*":@4, @"/":@4, @"%":@4, @"+":@2, @"-":@2, @")":@1, @"=":@0 };
}

-(BOOL)isOperator:(NSString *)ch
{
    if ([[Calculate validOperator] containsObject:ch]) {
        return YES;
    }else
        return NO;
    
}

-(BOOL)isNumberic:(NSString *)ch
{
    NSCharacterSet* Digits = [NSCharacterSet decimalDigitCharacterSet];
    NSString *value = [ch stringByTrimmingCharactersInSet:Digits];
    NSLog(@"nonDigits:%@, value:%@", Digits, value);
    
    if ([value length]!= 0) {//value为ch中除数字之外的字符
        if (![value isEqualToString:@"."]) {
            NSLog(@"Error!");
            return NO;
        }
    }
    return YES;
}

//判断是否为括号
-(BOOL)isBracket:(NSString *)ch
{
    if ([ch isEqualToString:@"("] || [ch isEqualToString:@")"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isValidInput:(NSString *)ch
{
    NSUInteger length = [ch length];
    for (int i = 0; i < length; i++) {
        char c = [ch characterAtIndex:i];
        NSString *temp1 = [NSString stringWithFormat:@"%c", c];
        
        if (![self isOperator:temp1]) {
            continue;
        }else{
            int j = i + 1;
            if (j < length) {
                char nextc = [ch characterAtIndex:j];
                NSString *temp2 = [NSString stringWithFormat:@"%c", nextc];
                
                if ([self isOperator:temp2]) {
                    if (!([self isBracket:temp1] ^ [self isBracket:temp2])) {
                        //只有一个是括号，返回值为yes，否则，返回值为no
                        //异或
                        return NO;
                    }
                }
            }

        }
        
    }
    return YES;
}

-(NSString *)comparePriority:(NSString *)inOptr outOptr:(NSString *)outOptr
{
    NSDictionary *inStackPriority = [Calculate inStackPriority];
    NSDictionary *outStackPriority = [Calculate outStackPriority];
    
    NSString *inPriority = inStackPriority[inOptr];
    NSString *outPriority = outStackPriority[outOptr];
    
    NSInteger isp = [inPriority integerValue];
    NSInteger icp = [outPriority integerValue];
    
    NSLog(@"栈外 %@ 优先级:%@ 栈内 %@ 优先级:%@", outOptr, outPriority, inOptr, inPriority);
    
    if (isp > icp)
        return @">";
    else if (isp < icp)
        return @"<";
    else
        return @"=";
}


-(float)calculate:(float)opnd1 opnd2:(float)opnd2 optr:(NSString *)optr
{
    NSArray *items = @[@"+", @"-", @"*", @"/"];
    int item = (int)[items indexOfObject:optr];
    
    switch (item) {
        case 0:
            return (opnd1 + opnd2);
            break;
        case 1:
            return (opnd1 - opnd2);
            break;
        case 2:
            return (opnd1 * opnd2);
            break;
        case 3:
            if (opnd2 == 0) {
                NSLog(@"除法，除数为0");
                return 0;
                break;
            }
            return (opnd1 / opnd2);
            break;
        default:
            NSLog(@"calculate default case");
            return 0;
            break;
    }
}

-(NSMutableArray *)clearWhitespace:(NSMutableArray *)inputArray
{
    NSMutableArray * tempArray = [NSMutableArray array];//必须初始化，否则数组存不上东西
    for (int i = 0; i < inputArray.count; i++) {
        if (![inputArray[i] isEqualToString:@""]) {
            [tempArray addObject:inputArray[i]];
        }
    }
    return tempArray;
}

-(NSString *)ExpressionCalculate:(NSString *)inputString
{
    if (![self isValidInput:inputString]) {
        return @"Error input!";
    }
    
    //从输入的字符串中提取运算符
    self.arrayForOperator = [NSMutableArray array];//必须初始化，否则数组存不上东西
    self.arrayToCalculate = [NSMutableArray array];
    
    for (int i = 0; i < [inputString length]; i++) {
        char ch = [inputString characterAtIndex:i];
        if ((ch == '+') || (ch == '-') || (ch == '*') || (ch == '/') || (ch == '%') || (ch == '(') || (ch == ')') ) {
            NSString *temp = [NSString stringWithFormat:@"%c", ch];
            [self.arrayForOperator addObject:temp];
        }
    }
    
    //从输入的字符串中提取数字，并且清除字符串中的空格
    NSArray *tempArray = [inputString componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"(+-*/%=)"]];
    self.arrayToCalculate = [NSMutableArray arrayWithArray:tempArray];
    self.arrayToCalculate = [self clearWhitespace:self.arrayToCalculate];
    
    
    //检查是否包含非法字符
    
    for (NSString *ch in self.arrayToCalculate) {
        if (![self isNumberic:ch]) {
            return @"Error!";
        }
    }
    
    self.optrSize = self.arrayForOperator.count;
    self.opndSize = self.arrayToCalculate.count;
    
    NSLog(@"arrayToCalculate:%@", self.arrayToCalculate);
    NSLog(@"arrayForOperator:%@", self.arrayForOperator);
    
    //表达式计算
    
    //初始化两个栈
    self.optr = [[Stack alloc] initWithStacksize:self.optrSize];
    [self.optr push:@"=" stack:self.optr];
    self.opnd = [[Stack alloc] initWithStacksize:self.opndSize];
    
    NSLog(@"optr: %@", self.optr.stackArray);
    NSLog(@"opnd: %@", self.opnd.stackArray);
    
    
    NSString *bracket;//接收括号
    NSString *theta;//存放计算符号
    NSString *a, *b;//存放操作数
    
    for (int i = 0; i < [inputString length]; i++) {
        
        char ch = [inputString characterAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%c", ch];
        
        if (([str isEqualToString:@"="]) && ([[self.optr getTop:self.optr] isEqualToString:@"="]) ) {
            break;
        }else{
            
            if (![self isOperator:str]) {
                NSLog(@"%@ 不是运算符", str);
                
                int j = i+1;
                NSLog(@"j = %d", j);
                if (j < [inputString length]) {
                    NSLog(@"j < %d", (int)[inputString length]);
                    char nextch = [inputString characterAtIndex:j];
                    NSString *nextStr = [NSString stringWithFormat:@"%c", nextch];
                    NSLog(@"nextStr:%@", nextStr);
                    if (![self isOperator:nextStr]){//下一个字符仍然是数字
                        NSLog(@"下一个字符仍为数字");
                        continue;
                    }
                    else{
                        NSLog(@"下一个字符不是数字");
                        [self.opnd push:[self.arrayToCalculate firstObject] stack:self.opnd];
                        [self.arrayToCalculate removeObjectAtIndex:0];
                    }
                }else{
                    [self.opnd push:[self.arrayToCalculate firstObject] stack:self.opnd];
                    [self.arrayToCalculate removeObjectAtIndex:0];
                }
                /*NSLog(@"opnd:%@", self.opnd.stackArray);
                NSLog(@"optr:%@", self.optr.stackArray);*/
                
            }else{
                
                NSLog(@"%@ 是运算符", str);
                NSLog(@"optr:%@", self.optr.stackArray);
                
                //判断优先级
                NSString *priority = [self comparePriority:[self.optr getTop:self.optr] outOptr:str];
                NSArray *items = @[@"<", @"=", @">"];
                int item = (int)[items indexOfObject:priority];
                
                switch (item) {
                    case 0:
                    {   //栈顶元素优先级低
                        if([self.optr push:str stack:self.optr])
                            NSLog(@"栈顶元素优先级低,将 %@ 压入栈", str);
                        else
                            NSLog(@"push failed.");
                        break;
                    }
                    case 1:
                    {    //脱括号并接收下一元素
                        bracket = [self.optr pop:self.optr];
                        NSLog(@"%@ 和 %@ 优先级相等，脱括号并接收下一元素", str, bracket);
                        break;
                    }
                    case 2:
                    {   //退栈并将运算结果入栈
                        
                        --i;//栈外运算符的优先级小于栈顶元素，弹出当前栈顶元素，保留当前栈外元素
                        
                        b = [self.opnd pop:self.opnd];
                        a = [self.opnd pop:self.opnd];
                        theta = [self.optr pop:self.optr];
                        NSLog(@"计算%@ %@ %@", a, theta, b);
                        
                        float da = [a doubleValue];
                        float db = [b doubleValue];
                        float res = [self calculate:da opnd2:db optr:theta];
                        NSString *result = [NSString stringWithFormat:@"%f", res];
                        [self.opnd push:result stack:self.opnd];
                        
                        NSLog(@"after compute, opnd is:%@", self.opnd.stackArray);
                        NSLog(@"after compute, optr is:%@", self.optr.stackArray);
                
                        break;
                    }
                    default:
                        NSLog(@"default case");
                        break;
                }
            }
        
        }
    }//for
    NSString *expResult = [self.opnd getTop:self.opnd];
    return expResult;
}

@end
