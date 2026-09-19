require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
is_new_arch_enabled = ENV['RCT_NEW_ARCH_ENABLED'] == '1'

Pod::Spec.new do |s|
  s.name           = 'react-native-notifications'
  s.version        = package['version']
  s.summary        = package['description']

  s.authors        = "Wix.com"
  s.homepage       = package['homepage']
  s.license        = package['license']
  s.platform       = :ios, '11.0'

  s.module_name    = 'RNNotifications'
  s.source         = { :git => 'https://github.com/wix/react-native-notifications', :tag => s.version }

  s.requires_arc   = true

  s.preserve_paths = 'LICENSE', 'README.md', 'package.json', 'notification.ios.js', 'notification.android.js', 'index.android.js', 'index.ios.js'
  s.source_files   = 'lib/ios/*.{h,m,mm}'
  s.exclude_files  = "lib/ios/RNNotificationsTests/**/*.*", "lib/ios/OCMock/**/*.*"
  if is_new_arch_enabled
    if respond_to?(:install_modules_dependencies)
      install_modules_dependencies(s)
    else
      use_react_native_codegen!(
        s,
        :react_native_path => '../react-native',
        :js_srcs_dir => 'lib/src',
        :library_name => 'RNNotificationsSpec',
        :library_type => 'modules'
      ) if respond_to?(:use_react_native_codegen!)

      s.dependency 'React-Core'
      s.dependency 'React-Codegen'
      s.dependency 'React-callinvoker'
      s.dependency 'ReactCommon/turbomodule/core'
      s.dependency 'RCT-Folly'
    end
  else
    s.dependency 'React-Core'
  end
end
