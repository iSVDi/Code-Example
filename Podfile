# Uncomment the next line to define a global platform for your project
 ios_deployment_target = '13.0'
 platform :ios, ios_deployment_target

target 'smm-barcode' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'TinyConstraints', '4.0.2'
  pod 'PKHUD', '5.3.0'
  pod 'SwiftyStoreKit', '0.16.1'
  pod 'AppsFlyerFramework', '6.9.1'
  pod 'FMDB', '2.7.5'
  pod 'RSBarcodes_Swift', :git => 'https://github.com/yeahdongcn/RSBarcodes_Swift', :branch => 'master', :commit => 'fde53070cdf5c5fde92697d33512161486cc37b9'
  pod 'Toast-Swift', '5.0.1'
  pod 'Moya', '~> 15.0.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # fix xcode 12 'IPHONEOS_DEPLOYMENT_TARGET' is set to 8.0 warnings
    # fix xcode 14.3 libarclite_iphoneos.a missing
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'].to_f < ios_deployment_target.to_f
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = ios_deployment_target
      end
    end
    # fix xcode 14 needs selected Development Team for Pod Bundles
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
