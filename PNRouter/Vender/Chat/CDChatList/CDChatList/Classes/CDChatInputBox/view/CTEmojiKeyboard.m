//
//  CTEmojiKeyboard.m
//  CDChatList
//
//  Created by chdo on 2017/12/15.
//

#import "CTEmojiKeyboard.h"
#import "CTinputHelper.h"
#import "CTInPutMacro.h"
#import "EmojModel.h"
#import "EmoticonCell.h"
#import "ExpressionCillectionLayout.h"


@interface CTEmojiKeyboard()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    
    UIButton *sendButton;
    UICollectionView *collectV;
    NSMutableArray *dataArray;

    NSMutableArray <UIView *> *containers; // 包含 scrollview pageView
    NSMutableArray <UIPageControl*> *pageCtrs; // segment
    NSMutableArray <UIButton*> *tabButtons; // 切换按钮
    
    // 表情名数组 @[ @[@"[微笑]",@"[呵呵]"],   @[@"[:微笑:",@":呵呵:"] ]
    NSArray<NSArray<NSString *> *> *arrs;
    NSDictionary<NSString *,UIImage *> *emojiDic;
    CGFloat emojInsetTop; // scrollview对应位置内边距
    CGFloat emojInsetLeft_Right; // scrollview对应位置内边距
    CGFloat emojInsetBottom;       // scrollview对应位置内边距
    CGFloat emojiLineSpace; // 表情按钮行间距
    CGSize emojiSize;  // 表情按钮体积
    CGFloat pageViewH;  // segment高度
    CGFloat bottomBarAeraH; // 底部选择栏的高度
    
}
@end
@implementation CTEmojiKeyboard

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CTEmojiKeyboard *single;
    
    dispatch_once(&onceToken, ^{
        single = [[CTEmojiKeyboard alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
           [single initUI];
        });

    });
    return single;
}

-(void)initUI{
    
    // 表情名数组 @[ @[@"[微笑]",@"[呵呵]"],   @[@"[:微笑:",@":呵呵:"] ]
    
    arrs = CTinputHelper.share.emojiNameArr ?: @[CTinputHelper.share.emojDic.allKeys];
    
    if (arrs.count != 1) {
        self.backgroundColor = [UIColor whiteColor];
        bottomBarAeraH = 44;
    } else {
        self.backgroundColor = [UIColor whiteColor];;
        bottomBarAeraH = 44;
    }
    
    
    NSInteger rowCount = 7;
    if (SCREEN_WIDTH > 375) {
        rowCount = 8;
    }
    
    emojInsetTop = 12.0f;  // 顶部内边距
    emojiSize = CGSizeMake(ScreenWidth * 0.112, ScreenWidth * 0.112);
    emojInsetLeft_Right = (ScreenWidth - emojiSize.width * 8) * 0.5; // 左右距离
    emojiLineSpace = 5.0f; // 表情行间距
    emojInsetBottom = 5.0f; // scrollview 底部内边距
    
    pageViewH = 20; //

    // scrollview大小
    CGSize scrollViewSize = CGSizeMake(ScreenWidth, emojInsetTop + emojiSize.height * 3 + emojiLineSpace * 2 + emojInsetBottom);

    // 底部键盘大小
    self.frame = CGRectMake(0, 0, ScreenWidth, scrollViewSize.height + pageViewH + bottomBarAeraH);
    
    
    containers = [NSMutableArray arrayWithCapacity:arrs.count];
    pageCtrs = [NSMutableArray arrayWithCapacity:arrs.count];
    tabButtons = [NSMutableArray arrayWithCapacity:arrs.count];
    dataArray = [NSMutableArray array];
    
    
    emojiDic = CTinputHelper.share.emojDic;
 
    for (int i = 0; i < arrs.count; i++){
        
        NSArray <NSString *>*empjiNames = arrs[i];
        for (NSUInteger j = 0; j < empjiNames.count; j++) {
            
        
            
            if (j != 0) {
                if (j % ((rowCount*3)-1) == 0) {
                    EmojModel *model = [[EmojModel alloc] init];
                    model.emjName = @"emojiDelete";
                    model.isDel = YES;
                    [dataArray addObject:model];
                }
            }
            
            EmojModel *model = [[EmojModel alloc] init];
            model.emjName = empjiNames[j];
            model.isDel = NO;
            [dataArray addObject:model];
            
            if (j!= 0 && j == empjiNames.count - 1) {
                EmojModel *model = [[EmojModel alloc] init];
                model.emjName = @"emojiDelete";
                model.isDel = YES;
                [dataArray addObject:model];
            }
        }
        
        // 每个scroll的container
        UIView *conain = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - bottomBarAeraH -1)];
        conain.tag = i;
        [self addSubview:conain];
        
        ExpressionCillectionLayout *layout = [[ExpressionCillectionLayout alloc]init];
        layout.itemSize = CGSizeMake((SCREEN_WIDTH-20)/rowCount, (scrollViewSize.height-20
                                                           )/3);
        layout.pageContentInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSpacing = 0;
        layout.lineSpacing = 0;
        
      //  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
//        layout.itemSize = CGSizeMake(30, 30);
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        layout.minimumLineSpacing = 15;
//        layout.minimumInteritemSpacing = 15;
        //每个分区的左右边距
      //  CGFloat sectionOffset = (SCREEN_WIDTH - 8 * 30 - 7 * 15) / 2;
        //分区内容偏移
       // layout.sectionInset = UIEdgeInsetsMake(15, sectionOffset, 15, sectionOffset);
        
        UICollectionView *myCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, scrollViewSize.height) collectionViewLayout:layout];
        myCollectionView.backgroundColor = HexColor(0xF5F5F7);
       
        myCollectionView.bounces = NO;
        myCollectionView.pagingEnabled = YES;
        myCollectionView.showsVerticalScrollIndicator = NO;
        myCollectionView.showsHorizontalScrollIndicator = NO;
        
       
        collectV = myCollectionView;
        
        [collectV registerClass:[EmoticonCell class] forCellWithReuseIdentifier:@"Emoticon"];
        
        //设置代理和数据源
        collectV.delegate = self;
        collectV.dataSource = self;
        
        [conain addSubview:collectV];
        
        
        
        
//        UIScrollView *scrol = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollViewSize.width, scrollViewSize.height)];
//        scrol.backgroundColor = HexColor(0xF5F5F7);
//        scrol.showsHorizontalScrollIndicator = NO;
//        scrol.delegate = self;
//        scrol.pagingEnabled = YES;
//        scrol.alwaysBounceHorizontal = YES;
//        scrol.tag = i;
//        [conain addSubview:scrol];
        
        
        
        
       /*
        // 表情页数
        NSUInteger emojiPages = (arrs[i].count % 23 != 0 ? 1 : 0) + arrs[i].count / 23;
        // 设置scrollview contentsize
        scrol.contentSize = CGSizeMake(scrollViewSize.width * emojiPages, 0);
        
        NSArray <NSString *>*empjiNames = arrs[i];
        // 添加每一页的表情
        NSMutableArray *arr = [NSMutableArray array];
        [emojiButs addObject: arr];
        for (NSUInteger j = 0; j < empjiNames.count; j++) {
            NSInteger currentPage = j / 23;
            
            NSUInteger currentRow = j % 23 / 8;
            NSUInteger currentColumn = j % 23 % 8;
            
            CGFloat x = emojInsetLeft_Right + currentColumn * emojiSize.width + currentPage * scrollViewSize.width;
            CGFloat y = emojInsetTop + currentRow * (emojiSize.height + emojiLineSpace) ;
            
            EmojiBut *but = [[EmojiBut alloc] initWithFrame:CGRectMake(x, y, emojiSize.width, emojiSize.height)];
            [but setImage:emojiDic[empjiNames[j]] forState:UIControlStateNormal];
            but.tag = i * 1000 + j;
            [but addTarget:self action:@selector(emojiButtonTabed:) forControlEvents:UIControlEventTouchUpInside];
            CGRect rect = but.imageView.frame;
            rect.size = CGSizeMake(40, 40);
            [but.imageView setFrame:rect];
            if (j % 22 == 0 || j == empjiNames.count - 1) {
                UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(emojInsetLeft_Right + emojiSize.width * 7 + currentPage * scrollViewSize.width,
                                                                              emojInsetTop + emojiLineSpace * 2 + emojiSize.height * 2,
                                                                              emojiSize.width,
                                                                              emojiSize.height)];
                [delete setImage:emojiDelete forState:UIControlStateNormal];
                [delete addTarget:self action:@selector(emojiButtonTabedDelete) forControlEvents:UIControlEventTouchUpInside];
                [scrol addSubview:delete];
            }
            if (currentPage == 0 && i == 0) {
                [scrol addSubview:but];
            } else {
                [moveButs addObject:but];
            }
            [arr addObject:but];
        }
        
        */
        NSInteger emojiPages = 4;
        // pagecontroll
        UIPageControl *control = [[UIPageControl alloc] initWithFrame:CGRectMake(0, collectV.frame.size.height, self.frame.size.width, pageViewH)];
        control.enabled = NO;
        control.backgroundColor = HexColor(0xF5F5F7);
        control.numberOfPages = emojiPages;
        control.pageIndicatorTintColor = [UIColor lightGrayColor];
        control.currentPageIndicatorTintColor = [UIColor blackColor];
        [conain addSubview:control];
        
        [containers addObject:conain];
       // [scrollViews addObject:scrol];
        [pageCtrs addObject:control];
    }
    
    for (UIView *con in containers) {
        if (con.tag == 0) {
            [con setHidden:NO];
        } else {
           // [con setHidden:YES];
        }
    }
    
    // 选择按钮
    UIButton *tabBut = [[UIButton alloc] initWithFrame:CGRectMake(0,self.frame.size.height - bottomBarAeraH, 60, bottomBarAeraH)];
    [tabBut setImage:[UIImage imageNamed:@"File-n"] forState:UIControlStateNormal];
    tabBut.userInteractionEnabled = NO;
   // [tabBut addTarget:self action:@selector(containSelectsss:) forControlEvents:UIControlEventTouchUpInside];
   // [tabBut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    if (i == 0) {
//        [tabBut setBackgroundColor:HexColor(0xF5F5F7)];
//    } else {
//        [tabBut setBackgroundColor:[UIColor whiteColor]];
//    }
    [self addSubview:tabBut];
   
    
    // 发送按钮
    sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width -100, self.frame.size.height - 44, 100, 44)];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendButton addTarget:self action:@selector(emojiButtonTabedSend) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self bringSubviewToFront:self->sendButton];
    });
    
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1);
    lineLayer.backgroundColor = HexColor(0xD7D7D9).CGColor;
    [self.layer insertSublayer:lineLayer atIndex:0];
}

-(void)didMoveToSuperview {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        for (int i = 0; i < self->emojiButs.count; i++) {
//            UIScrollView *scrol = self->scrollViews[i];
//            for (UIButton *b in self->emojiButs[i]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (!b.superview) {
//                        [scrol addSubview:b];
//                    }
//                });
//
//            }
//        }
//    });
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIScrollView *scrol = self->scrollViews[0];
//        for (UIButton *b in self->moveButs) {
//            NSUInteger imagIdx = b.tag % 1000;
//            if (imagIdx == 46) {
//                break;
//            }
//            if (!b.superview) {
//                [scrol addSubview:b];
//            }
//        }
//    });
}

-(void)containSelectsss:(UIButton *)but{
    for (UIView *conain in containers) {
        BOOL res = conain.tag != but.tag;
        [conain setHidden:res];
    }
    
    for (UIButton *conain in tabButtons) {
        BOOL res = conain.tag == but.tag;
        if (res) {
            conain.backgroundColor = HexColor(0xF5F5F7);
        } else {
            conain.backgroundColor = [UIColor whiteColor];
        }
    }
}


/*
- (void)scrollViewDidScroll: (UIScrollView *) aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    NSUInteger idx =  offset.x / aScrollView.frame.size.width;
    pageCtrs[aScrollView.tag].currentPage = idx;
    
    if (idx == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIScrollView *scrol = self->scrollViews[0];
            for (UIButton *b in self->moveButs) {
                NSUInteger imagIdx = b.tag % 1000;
                if (imagIdx == 69) {
                    break;
                }
                if (!b.superview) {
                    [scrol addSubview:b];
                }
            }
        });
    } else if (idx == 2) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIScrollView *scrol = self->scrollViews[0];
            for (UIButton *b in self->moveButs) {
                NSUInteger imagIdx = b.tag % 1000;
                if (imagIdx == 92) {
                    break;
                }
                if (!b.superview) {
                    [scrol addSubview:b];
                }
            }
        });
    }
}
*/
+(CTEmojiKeyboard *)keyBoard{
    
    [[CTEmojiKeyboard share] updateKeyBoard];
    return [CTEmojiKeyboard share];
}

-(void)updateKeyBoard{
    for (UIButton *but in tabButtons) {
        if (but.tag == 0) {
            but.backgroundColor = HexColor(0xF5F5F7);
        } else {
            but.backgroundColor = [UIColor whiteColor];
        }
    }

    [self bringSubviewToFront:containers.firstObject];

}

-(void)emojiButtonTabed:(UIButton *)but{
    NSUInteger buttag =  but.tag;
    NSUInteger arrIdx = buttag * 0.001;
    NSUInteger imagIdx = buttag % 1000;
    NSString *name = arrs[arrIdx][imagIdx];
    UIImage *img = emojiDic[name];
    [self.emojiDelegate emojiKeyboardSelectKey:name image:img];
}

-(void)emojiButtonTabedWithEmjModel:(EmojModel *) model{
    if (model.isDel) {
        [self.emojiDelegate emojiKeyboardSelectDelete];
    } else {
        [self.emojiDelegate emojiKeyboardSelectKey:model.emjName image:emojiDic[model.emjName]];
    }
}


-(void)emojiButtonTabedDelete{
    [self.emojiDelegate emojiKeyboardSelectDelete];
}

-(void)emojiButtonTabedSend{
    [self.emojiDelegate emojiKeyboardSelectSend];
}

//-(void)layoutSubviews{
//    [super layoutSubviews];
//
//}

/*
#pragma mark - UICollectionView DateSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (dataArray.count / 24) + (dataArray.count % 24 == 0 ? 0 : 1);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (((dataArray.count / 24) + (dataArray.count % 24 == 0 ? 0 : 1)) != section + 1) {
        return 24;
    }else {
        return dataArray.count - 24 * section;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Emoticon";
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self setCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (void)setCell:(EmoticonCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSString *emjName = dataArray[indexPath.section * 24 + indexPath.row];
    [cell.emoticonButton setImage:emojiDic[emjName] forState:UIControlStateNormal];
}
*/

#pragma mark - CollectionView Delegate & DataSource
-(void)refreshPageControl{
    //ceil返回大于或者等于指定表达式的最小整数
    pageCtrs[0].numberOfPages=ceil(collectV.contentSize.width)/CGRectGetWidth(collectV.bounds);
    //floor向下取整
    pageCtrs[0].currentPage=floor(collectV.contentOffset.x/CGRectGetWidth(collectV.bounds));
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self refreshPageControl];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshPageControl];
    });
    return dataArray.count;
    
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Emoticon";
    EmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.emoticonButton.tag = indexPath.row;
    EmojModel *emjModel = dataArray[indexPath.row];
    if (emjModel.isDel) {
        UIImage *delImg = CTinputHelper.share.imageDic[@"emojiDelete"];
        //cell.emoticonButton.image = delImg;
        [cell.emoticonButton setImage:delImg forState:UIControlStateNormal];
    } else {
         //cell.emoticonButton.image = emojiDic[emjModel.emjName];
         [cell.emoticonButton setImage:emojiDic[emjModel.emjName] forState:UIControlStateNormal];
       
    }
   
    //cell.emoticonButton.backgroundColor = [UIColor greenColor];
    
    @weakify_self
    [cell setClickCellB:^(NSInteger row) {
        EmojModel *model = self->dataArray[row];
        [weakSelf emojiButtonTabedWithEmjModel:model];
    }];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"%ld",(long)indexPath.row);
    
}

@end
