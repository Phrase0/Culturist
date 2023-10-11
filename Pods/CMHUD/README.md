![](toast.png)

<H1 align="center">CMHUD</H1>

<p align="center">
<a href="https://cocoapods.org/pods/CMHUD"><img alt="Version" src="https://img.shields.io/cocoapods/v/CMHUD.svg?style=flat"></a> 
<a href="https://github.com/Incetro/CMHUD/blob/master/LICENSE"><img alt="Liscence" src="https://img.shields.io/cocoapods/l/CMHUD.svg?style=flat"></a> 
<a href="https://developer.apple.com/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"/></a> 
<a href="https://developer.apple.com/swift"><img alt="Swift4.2" src="https://img.shields.io/badge/language-Swift5.3-orange.svg"/></a>
</p>

## Usage

```swift
/// Success
CMHUD.success(in: view)
CMHUD.success(in: self.view, hideAfter: 4)
CMHUD.success(in: self.view, withAppearance: customAppearance)

/// Error
CMHUD.error(in: self.view)
CMHUD.error(in: self.view, hideAfter: 4)
CMHUD.error(in: self.view, withAppearance: customAppearance)

/// Loading
CMHUD.loading(in: view)

/// Loading with animation view (you can see it in example)
CMHUD.loading(contentView: animationView, in: self.view)

/// Hide CMHUD
CMHUD.hide(from: view)

/// Progress
CMHUD.progress(progressValue, in: view)

/// Progress with custom animation view (you can see it in example)
CMHUD.progress(
    $0,
    with: animationView,
    in: self.view,
    withAppearance: customAppearance
)
```

## Installation

### Cocoapods

CMHUD is on Cocoapods! After [setting up Cocoapods in your project](https://guides.cocoapods.org/), simply add the folowing to your Podfile: `pod "CMHUD", :git => 'https://github.com/Incetro/CMHUD'` then run `pod install` from the directory containing the Podfile!

Don't forget to include `import CMHUD` in every file you'd like to use CMHUD

### Requirements

- Swift 5.3+
- iOS 12.0+

## License
Source code is distributed under MIT license.