
Pod::Spec.new do |s|

  s.name         = "ThumbnailView"
  s.version      = "1.0.0"
  s.summary      = "一个可自适应高度的显示thumbnail的控件"

  s.description  = <<-DESC
                   一个可自适应高度的显示thumbnail的控件，含有内部高度
                   DESC

  s.homepage     = "https://github.com/liukai6789/ThumbnailView"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "liukai" => "liukai6789@163.com" }

  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/liukai6789/ThumbnailView.git", :tag => s.version }

  s.source_files  = "ThumbnailView/*"

  # s.resource = "ThumbnailView/img.bundle"
  s.resource_bundles = {
                       'image' => ['ThumbnailView/Resources/image.bundle/*.png']
                       }

  s.frameworks = "UIKit"
  s.requires_arc = true

  s.swift_version = '4.1'

  # s.dependency "JSONKit", "~> 1.4"

end
