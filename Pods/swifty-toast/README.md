![](toast.png)

<H1 align="center">Toast</H1>

<p align="center">
<a href="https://cocoapods.org/pods/swifty-toast"><img alt="Version" src="https://img.shields.io/cocoapods/v/Toast.svg?style=flat"></a> 
<a href="https://github.com/Incetro/swifty-toast/blob/master/LICENSE"><img alt="Liscence" src="https://img.shields.io/cocoapods/l/Toast.svg?style=flat"></a> 
<a href="https://developer.apple.com/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"/></a> 
<a href="https://developer.apple.com/swift"><img alt="Swift4.2" src="https://img.shields.io/badge/language-Swift5.3-orange.svg"/></a>
</p>

## Usage

From any view controller, a Toast can be presented by calling:

```swift
Toast("Your message", source: self).show()
```

So, I will discuss how to customize your Toast!

## Playground

I've provided an example project to showcase uses of Toast! Simply clone this repo, and open `Example.xcodeproj`. From here you can see and experiment custom Toast styles in `ViewController.swift`

## Customization

### Basic styles

Toast comes with 4 basic style out of the box.

| Success | Error |
| ------- | ----- |
| <img width="525" src="https://user-images.githubusercontent.com/66957916/118022496-17f60500-b365-11eb-8aa2-df2b7fee7d0f.PNG"> | <img width="525" src="https://user-images.githubusercontent.com/66957916/118022617-35c36a00-b365-11eb-83e3-5e700ac9a8b9.PNG"> |

| Warning | Info |
| ------- | ---- |
| <img width="525" src="https://user-images.githubusercontent.com/66957916/118022609-33f9a680-b365-11eb-949e-f0b52227f7cc.PNG"> | <img width="525" src="https://user-images.githubusercontent.com/66957916/118022593-2fcd8900-b365-11eb-887a-c61482292b7b.PNG"> |

These styles can be specified in the `style` property.
For instance, to use `Success` styled Toast, call it like so:

```swift
Toast("This is a success toast", state: .success, source: self).show()
```

### Custom styles

Toast allows you to specify a custom style! This will let you set the colors, font, icon. and icon alignment. Here are some examples of custom Toast styles!

| Colors and icon | Right icon alignment | No icon |
| ---- | ---- | ---- |
| <img width="517" src="https://user-images.githubusercontent.com/66957916/118022626-36f49700-b365-11eb-951c-e80c0ad10ada.PNG"> | <img width="517" src="https://user-images.githubusercontent.com/66957916/118022635-38be5a80-b365-11eb-9262-91719cf21e98.PNG"> | <img width="517" src="https://user-images.githubusercontent.com/66957916/118022648-3c51e180-b365-11eb-86d6-15bd7d313918.PNG"> |

All of these properties are specified as part of custom state, like so:

```swift
Toast(
    "Toast message", 
    state: .custom(
        .init(
            backgroundColor: .black, 
            icon: UIImage(named: "image")
        )
    ),
    source: self
).show()
```

### Presenting and dismissing

Toast allows you to specify the presenting and dismissing direction. The presenting direction is independant from the dismissal direction. Here are some examples:

| Vertical | Left |
| ---- | ---- |
| ![vertical](https://user-images.githubusercontent.com/66957916/118023751-93a48180-b366-11eb-99cb-3e142ee7409c.mp4) | ![left](https://user-images.githubusercontent.com/66957916/118023746-91dabe00-b366-11eb-8ece-388083384387.mp4) |

| Right | Combo |
| ---- | ---- |
| ![right](https://user-images.githubusercontent.com/66957916/118027751-f566ea80-b36a-11eb-9945-e059c2a99bfd.mp4) | ![combo](https://user-images.githubusercontent.com/66957916/118023733-8c7d7380-b366-11eb-9c59-192b11b63e87.mp4) |

These are specified in the function signature, like so:

```swift
Toast(
    "Toast message", 
    presentingDirection: .left, 
    dismissingDirection: .vertical, 
    source: self
).show()
```

### Other

Specify the presentation duration. When presenting a Toast with `.show()`, a presentation duration can be specified. The default value is 4s, but there are presets for 2s and 8s. This is done by using `.show(.short)` for 2s, or `.show(.long)` for 8s. A custom duration can also be specified with `.show(.custom(x))`, where x represents the duration in seconds.

A Toast's width can be specified via the `Style` component. The width can be specifed as a fixed size (i.e. 280px) or as a percentage of the screen's width. (i.e. `0.8` -> 87%). Here is some example usage:

```swift
Toast(
    "Toast message", 
    state: .custom(
        .init(
            backgroundColor: .black, 
            width: .screenPercentage(0.87)
        )
    ),
    source: self
).show()
```

## Installation

### Cocoapods

Toast is on Cocoapods! After [setting up Cocoapods in your project](https://guides.cocoapods.org/), simply add the folowing to your Podfile: `pod 'swifty-toast'` then run `pod install` from the directory containing the Podfile!

Don't forget to include `import Toast` in every file you'd like to use Toast

### Requirements

- Swift 5.3+
- iOS 12.0+
