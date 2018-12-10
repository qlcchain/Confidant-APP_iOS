//
//  AATAudioTool.m
//  AATUtility
//
//  Created by chdo on 2018/1/9.
//  Copyright © 2018年 aat. All rights reserved.
//

#import "AATAudioTool.h"

NSNotificationName const AATAudioToolDidStopPlayNoti = @"AATAudioToolDidStopPlayNoti";

@interface AATAudioTool()<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    NSTimer *_timer; //定时器
    NSTimeInterval startTime;
    NSString *filePath;
    
    AVAuthorizationStatus audioRequest;
}

@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址
@property (nonatomic, strong) AVAudioRecorder *recorder;//录音器
@property (nonatomic, strong) AVAudioPlayer *player; //播放器
@property (nonatomic, strong) AVAudioSession *session;

@end


@implementation AATAudioTool

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static AATAudioTool *single;
    
    dispatch_once(&onceToken, ^{
        single = [[AATAudioTool alloc] init];
        single.updateInterval = 0.01;
        single.minimumAudioDuration = 1;
        single.tooShortInfo = @"说话时间太短";
        single.recordFormatDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         // 采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                         [NSNumber numberWithFloat: 8000],AVSampleRateKey,
                                         // 音频格式
                                         [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                         // 采样位数  8、16、24、32 默认为16
                                         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                         // 音频通道数 1 或 2
                                         [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                         // 录音质量
                                         [NSNumber numberWithInt:AVAudioQualityHigh],  AVEncoderAudioQualityKey,
                                         nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:single selector:@selector(enterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    });
    return single;
}


-(AVAudioSession *)session{
    if (!_session){
        
        AVAudioSession *session =[AVAudioSession sharedInstance];
        NSError *err;
        [session setActive:YES error:&err];
        [self handleError:err];
        _session = session;
    }
    return _session;
}

-(void)enterBackGround:(NSNotification *)noti{
    [self stopRecord];
    [self stopPlay];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark ====================================录音====================================

-(BOOL)isRecorderRecording{
    return self.recorder.isRecording;
}
-(AVAudioRecorder *)configRecorder:(NSError **)outError{
    _recorder = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:self.recordFormatDictionary error:outError];
    _recorder.delegate = self;
    return _recorder;
}

- (void)startRecord {
    
    if (_player) {
        // 停止播放/录音
        [self stopPlay];
        
    }
    // 设置session
    NSError *sessionError;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if ([self handleError:sessionError]){
        return;
    }
    
    // 设置文件地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",@"audio"]];
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];
    
    // 配置录音器
    NSError *error;
    [self configRecorder:&error];
    [self handleError:error];
    
    //设置参数
    if (self.recorder) {
        // 开始录音
        self.recorder.meteringEnabled = YES;
        [self.recorder prepareToRecord];
        [self.recorder record];
//        CRMLog(@"?? %d",res);
        startTime = -1;
        [self addTimer];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate aatAudioToolDidStopRecord:nil
                                           startTime:0
                                             endTime:0
                                           errorInfo:@"音频格式和文件存储格式不匹配,无法初始化Recorder"];
        });
    }
}


- (void)stopRecord {
    
    [self removeTimer];
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
}

-(void)intertrptRecord{
    [self.delegate aatAudioToolDidSInterrupted];
    self.delegate = nil;
    [self removeTimer];
    if ([self.recorder isRecording]) {
        [self.recorder stop];
    }
}


/**
 *  添加定时器
 */
- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.updateInterval target:self selector:@selector(refreshRecord) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

/**
 *  移除定时器
 */
- (void)removeTimer
{
    [_timer invalidate];
    _timer = nil;
}

-(void)refreshRecord {
    __weak typeof(self) weakS = self;
    if (startTime < 0 && !self.recorder.isRecording) { // 还未开始录音
        return;
    } else if (startTime < 0 && self.recorder.isRecording) { // 开始录音 记录时间
        startTime = self.recorder.deviceCurrentTime;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakS) {
                __strong typeof(weakS) strongS = weakS;
                [strongS.delegate aatAudioToolDidStartRecord:strongS->startTime];
            }
        });
        return;
    } else if (startTime > 0 && self.recorder.isRecording) { // 录音中
        
        NSTimeInterval duration = self.recorder.deviceCurrentTime - startTime;
        
        if (duration > 60.0) { // 停止录音
            [self stopRecord];
            return;
        }
        
        [self.recorder updateMeters];
        double lowPassResults = pow(10, (0.05 * [self.recorder peakPowerForChannel:0]));
        
        [self.delegate aatAudioToolUpdateCurrentTime:self.recorder.deviceCurrentTime
                                            fromTime:startTime
                                               power:lowPassResults];
    } else {
        
    }
    
}

#pragma mark  ---AVAudioRecorderDelegate---
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (startTime < 0) { // 还未开始录音
        
    }else {
        NSTimeInterval dura = recorder.deviceCurrentTime - startTime;
        if (dura < self.minimumAudioDuration) { // 录音时长不到最小时长
            [self.delegate aatAudioToolDidStopRecord:nil
                                           startTime:startTime
                                             endTime:recorder.deviceCurrentTime
                                           errorInfo:self.tooShortInfo];
        } else {
            [self.delegate aatAudioToolDidStopRecord:recorder.url
                                           startTime:startTime
                                             endTime:recorder.deviceCurrentTime
                                           errorInfo:nil];
        }
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    [self.delegate aatAudioToolDidStopRecord:recorder.url
                                   startTime:startTime
                                     endTime:recorder.deviceCurrentTime
                                   errorInfo:error.description];
}



#pragma mark ====================================播放====================================
-(BOOL)isPlaying{
    return [self.player isPlaying];
}

-(void)setAudioPath:(NSString *)audioPath{
    _audioPath = audioPath;
    _player = nil;
}

-(AVAudioPlayer *)player{
    if (!_player) {
        NSError *err;
        NSURL *fileUrl;
        if ([[NSFileManager defaultManager] fileExistsAtPath: self.audioPath]){
            fileUrl = [NSURL fileURLWithPath:self.audioPath];
        } else {
            fileUrl = [NSURL URLWithString:self.audioPath];
        }
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL: fileUrl error: &err];
        _player.delegate = self;
        [self.session setCategory: AVAudioSessionCategoryPlayback error:&err];
        [_player prepareToPlay];
        [self handleError:err];
    }
    return _player;
}

- (void)play {
    
    NSError *outError;
    [self.session setCategory:AVAudioSessionCategoryPlayback error:&outError];
    
    [self intertrptRecord];
    if ([self.player isPlaying]){
        [self stopPlay];
        self.player = nil;
    };
    
    [self.player play];
}

-(void)stopPlay{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: AATAudioToolDidStopPlayNoti object:self.audioPath];
    [self.player stop];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[NSNotificationCenter defaultCenter] postNotificationName: AATAudioToolDidStopPlayNoti object:self.audioPath];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    [[NSNotificationCenter defaultCenter] postNotificationName: AATAudioToolDidStopPlayNoti object:self.audioPath];
}

#pragma mark ====================================public====================================
-(BOOL)handleError:(NSError *)err{
    if (err) {
        [self.delegate aatAudioToolDidStopRecord:nil startTime:0 endTime:0 errorInfo:[NSString stringWithFormat:@"Error creating session: %@",[err description]]];
        [self removeTimer];
        return YES;
    }
    return NO;
}

+ (void)checkCameraAuthorizationGrand:(void (^)(void))permissionGranted withNoPermission:(void (^)(void))noPermission{
    if ([AATAudioTool share]->audioRequest == AVAuthorizationStatusAuthorized) {
        permissionGranted();
        return;
    } else if ([AATAudioTool share]->audioRequest == AVAuthorizationStatusRestricted) {
        noPermission();
        return;
    } else if ( [AATAudioTool share]->audioRequest == AVAuthorizationStatusRestricted) {
//        "跳转相机授权设置"
        return;
    }
    
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    [AATAudioTool share]->audioRequest = videoAuthStatus;
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (!granted) {
                    noPermission();
                }else{
                    //                            permissionGranted();
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            //通过授权
            permissionGranted();
            break;
        }
        case AVAuthorizationStatusRestricted:
            //不能授权
            NSLog(@"不能完成授权，可能开启了访问限制");
            noPermission();
        case AVAuthorizationStatusDenied:{
//            "跳转相机授权设置"
        }
            break;
        default:
            break;
    }
}


@end
