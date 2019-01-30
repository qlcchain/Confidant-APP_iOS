source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
#use_frameworks!
inhibit_all_warnings!


def common_pods
    #    pod 'toxcore', '0.2.2'
    pod 'libsodium'
    pod 'libopus-patched-config'
    
    #pod 'CocoaLumberjack', '~> 1.9.2'
    pod 'CocoaLumberjack/Swift'
    pod 'Realm', '3.1.0'
    pod 'TPCircularBuffer', '~> 0.0.1'
end

def demo_pods
    #pod 'Masonry', '~> 0.6.1'
    # pod 'BlocksKit', '~> 2.2.5'
    pod 'IQKeyboardManager'
    pod 'MJExtension'
    pod 'MBProgressHUD'
    pod 'AFNetworking'
    pod 'Masonry'
    pod 'KeychainAccess'
    
    # pod 'Starscream'
    pod 'SDWebImage/GIF',:inhibit_warnings => true
    pod 'FLAnimatedImage',:inhibit_warnings => true
    pod 'GDPerformanceView', '~> 1.3.1'
    pod 'YYImage',:inhibit_warnings => true
    #pod 'Toast'
    pod 'SWTableViewCell'
    pod 'MJRefresh'
    pod 'BGFMDB'
    pod 'WZLBadge'
    pod 'OpenSSL', :git => 'https://github.com/isee15/OpenSSL.git'
    pod 'Bugly'
#    pod 'JCDownloader'
end


target 'PNRouter' do
    
    platform :ios, '9.0'
    common_pods
    demo_pods
    
end
