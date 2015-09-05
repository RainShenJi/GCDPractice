//
//  ViewController.m
//  GCDPractice
//
//  Created by RainShen on 15/9/3.
//  Copyright (c) 2015年 小雨. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

{

    UIImageView * _imageView;
    UIImageView * _imageView2;
    UIImageView * _fullImageView;
    UIImage * _image1;
    UIImage * _image2;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createImageView];
}

- (void)createImageView  {

//    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    imageView.backgroundColor = [UIColor greenColor];
//    _imageView = imageView;
//    [self.view addSubview:_imageView];
//    
//    UIImageView * imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(100, 250, 100, 100)];
//    imageView2.backgroundColor = [UIColor greenColor];
//    _imageView2 = imageView2;
//    [self.view addSubview:_imageView2];
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    imageView.backgroundColor = [UIColor greenColor];
    _fullImageView = imageView;
    [self.view addSubview:_fullImageView];
}

//同步异步主要影响的是能不能开启新的线程
//串行并行主要影响的是执行任务的方式
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
   // [self asyncGlobalQueue];
  //  [self readingWrittingHandle];
  //  [self applyDispatch];
//  [self suspendAndResume];
    [self semaphoreDispatch];
    [self sourceDispatch];
}

- (void)sourceDispatch {

    
    
}

- (void)semaphoreDispatch {

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray * array = [NSMutableArray array];
//    for (int i = 0; i < 100000; i++) {
//        
//        dispatch_async(queue, ^{
//            
//            [array addObject:[NSNumber numberWithInt:i]];
//        });
//    }
    /**
     *  生成 Dispatch Semaphore
     *
     *  @param 1 初始值设为1，保证可访问NSMutableArray对象的线程同时只有1个
     *
     */
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i < 100000; i++) {
        
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [array addObject:[NSNumber numberWithInt:i]];
            dispatch_semaphore_signal(semaphore);
        });
        
    }
    NSLog(@"%@",array);
}

- (void)suspendAndResume {

    dispatch_queue_t queue = dispatch_queue_create("com.exmple", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue1 = dispatch_queue_create("com.exmple1", DISPATCH_QUEUE_CONCURRENT);
    dispatch_set_target_queue(queue1, queue);
    dispatch_suspend(queue1);
    dispatch_async(queue1, ^{
        
        NSLog(@"数据库读取操作1");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作0");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作2");
    });
    dispatch_resume(queue1);

}

- (void)applyDispatch {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //dispatch_queue_t queue = dispatch_queue_create("com.gcd", NULL);
    NSArray * array = @[@1,@2,@3,@4,@5];
    dispatch_async(queue, ^{
        dispatch_apply([array count], queue, ^(size_t index) {
           
            NSLog(@"%zu: %@", index, array[index]);
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            NSLog(@"Done");
        });
        
    });
}

- (void)readingWrittingHandle {

    dispatch_queue_t queue = dispatch_queue_create("com.exmple", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
       
        NSLog(@"数据库读取操作0");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作1");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作2");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作3");
    });
    /**
     *  写入处理
     *  将写入的内容读取之后的处理中
     */
//    dispatch_async(queue, ^{
//        
//        NSLog(@"数据库写入操作");
//    });
    /**
     *  像上面这样写肯定是不行的，因为可能在写入处理的前面读到了与期望不符的数据，或者后面有的可能读不到数据，还可能因为非法访问导致应用程序异常结束，也可能有数据竞争问题等等，那么我们应该怎么做呢？这是就可以用dispatch_barrier_async函数了
     */
    dispatch_barrier_async(queue, ^{
       
        NSLog(@"数据库写入操作");
    });

    /**
     *  barrier翻译成障碍物分界线的意思
     *  dispatch_barrier_async以它为分界线，这个函数会把等待追加到Concurrent Dispatch Queue中的执行处理结束后，把block的任务添加到队列中，等这个block中的任务执行结束之后，Concurrent Dispatch Queue才恢复一般的动作，追加到Concurrent Dispatch Queue中的任务又开始处理
     */
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作4");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作5");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作6");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作7");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作8");
    });
    dispatch_async(queue, ^{
        
        NSLog(@"数据库读取操作9");
    });


}

- (void)asyncGlobalQueue {

    //全局并发队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //把任务添加到全局队列当中去异步执行
//    dispatch_async(globalQueue, ^{
//        //1.下载
//        UIImage * image = [self callMethodWithUrl:@"http://dmimg.5054399.com/allimg/optuji/kidd/4.jpg"];
//        _image1 = image;
//        [self drawWithImage];
//
//    });
//    
//    dispatch_async(globalQueue, ^{
//       
//        UIImage * image2 = [self callMethodWithUrl:@"https://www.baidu.com/img/bd_logo1.png"];
//        _image2 = image2;
//        [self drawWithImage];
//    });
    __block UIImage * image = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, globalQueue, ^{
        
        image = [self callMethodWithUrl:@"http://dmimg.5054399.com/allimg/optuji/kidd/4.jpg"];
    });
    __block UIImage * image2 = nil;
    dispatch_group_async(group, globalQueue, ^{
        
        image2 = [self callMethodWithUrl:@"https://www.baidu.com/img/bd_logo1.png"];
    });
    //下载图片的任务放到globalQueue中，globalQueue再放到group中
    //队列组的一个好处就是凡是扔到队列组中的任务，它会等队列组中的所有任务都搞定后，他会调用下面的这个API
    //合并图片
    //唤醒
    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    if (result == 0) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
        
        //绘制第一张图片
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        
        //绘制第二张图片
        [image2 drawInRect:CGRectMake(340, image.size.height-image2.size.height*0.5, image2.size.width*0.5, image2.size.height*0.5)];
        
        //得到上下文中的图片
        UIImage * fullImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //结束上下文
        UIGraphicsEndImageContext();
        
        //3.回到主线程刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            _fullImageView.image = fullImage;
        });
    }else{
        
        NSLog(@"某一个处理还在进行中");
    }
//    dispatch_group_notify(group, globalQueue, ^{
//       
//        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
//        
//        //绘制第一张图片
//        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//        
//        //绘制第二张图片
//        [image2 drawInRect:CGRectMake(340, image.size.height-image2.size.height*0.5, image2.size.width*0.5, image2.size.height*0.5)];
//        
//        //得到上下文中的图片
//        UIImage * fullImage = UIGraphicsGetImageFromCurrentImageContext();
//        
//        //结束上下文
//        UIGraphicsEndImageContext();
//        
//        //3.回到主线程刷新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _fullImageView.image = fullImage;
//        });
//    });
//    dispatch_async(globalQueue, ^{
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _imageView2.image = image2;
//        });
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            NSLog(@"2--%@",[NSThread currentThread]);
////            _imageView2.image = image2;
////        });
//    });
    
}

- (void)drawWithImage {
    if (_image1 == nil || _image2 == nil) return ; //这里判断只要任一图片下载失败的话都不往下执行
    
    //2.合并图片（利用2D画图）
    //开启一个位图上下文
    UIGraphicsBeginImageContextWithOptions(_image1.size, NO, 0.0);
    
    //绘制第一张图片
    [_image1 drawInRect:CGRectMake(0, 0, _image1.size.width, _image1.size.height)];
    
    //绘制第二张图片
    [_image2 drawInRect:CGRectMake(340, _image1.size.height-_image2.size.height*0.5, _image2.size.width*0.5, _image2.size.height*0.5)];
    
    //得到上下文中的图片
    UIImage * fullImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    //3.回到主线程刷新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        _fullImageView.image = fullImage;
    });
}

- (UIImage *)callMethodWithUrl:(NSString *)urlStr {
    NSURL * url = [NSURL URLWithString:urlStr];
    NSData * data = [NSData dataWithContentsOfURL:url];
    UIImage * image = [UIImage imageWithData:data];
    return image;
}

@end
