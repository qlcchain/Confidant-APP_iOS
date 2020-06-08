source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
#use_frameworks!
inhibit_all_warnings!

def performanceTest_pods
    pod 'FBRetainCycleDetector'
end

def common_pods

    pod 'libsodium'
    pod 'libopus-patched-config'

    pod 'CocoaLumberjack/Swift'
    pod 'Realm', '3.1.0'
    pod 'TPCircularBuffer', '~> 0.0.1'
    pod 'Firebase/Analytics'
    pod 'GoogleAnalytics'

end

def demo_pods
    
    pod 'IQKeyboardManager'
    pod 'MJExtension'
    pod 'MBProgressHUD'
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'KeychainAccess'
    pod 'JPush'
    pod 'SDWebImage/GIF',:inhibit_warnings => true
    pod 'FLAnimatedImage',:inhibit_warnings => true
    pod 'GDPerformanceView', '~> 1.3.1'
    pod 'YYImage',:inhibit_warnings => true
    pod 'SWTableViewCell'
    pod 'MJRefresh'
    pod 'BGFMDB'
    pod 'WZLBadge'
    pod 'OpenSSL', :git => 'https://github.com/isee15/OpenSSL.git'
    pod 'Bugly'
    pod 'YBImageBrowser'
    pod 'TZImagePickerController' #iOS8 and later
    pod 'mailcore2-ios'
    #pod 'SSZipArchive'
    # qlc chain 支持库
    pod 'APIKit'
    pod 'JSONRPCKit'
    pod 'PromiseKit'
    #pod 'Result'
    pod 'CryptoSwift'
    
    # aes
    # pod 'CocoaSecurity'
    #google 登陆
    pod'GoogleSignIn'
    pod 'GoogleAPIClientForREST'
    pod 'LFKit/Component/LFBubbleView'
end


target 'MyConfidant' do
    
    platform :ios, '9.0'
    common_pods
    demo_pods
    performanceTest_pods
    
end
