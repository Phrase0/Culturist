//
//  CMHUD.swift
//  CMHUD
//
//  Created by incetro on 5/21/21.
//

import UIKit
import Layout

// MARK: - CMHUD

final public class CMHUD: UIView {

    // MARK: - Accessibility

    private enum Accessibility {

        /// CMHUD general id
        static let accessiilityIdentifier = "com.incetro.CMHUD.id"

        /// CMHUD progress id
        static let progressAccessiilityIdentifier = "\(accessiilityIdentifier).progress"

        /// CMHUD indication id
        static let indicationAccessiilityIdentifier = "\(accessiilityIdentifier).loading"

        /// CMHUD success id
        static let successAccessiilityIdentifier = "\(accessiilityIdentifier).success"

        /// CMHUD error id
        static let errorAccessiilityIdentifier = "\(accessiilityIdentifier).error"

        /// CMHUD wrapping view id
        static let wrapperAccessiilityIdentifier = "com.incetro.CMHUD-wrapper.id"
    }

    // MARK: - Constants

    /// Current constants
    private enum Constants {

        /// HUD side size
        static let size: CGFloat = 80

        /// Current view's corner radius
        static let cornerRadius: CGFloat = 13

        /// Initial hud transform (before appearing animation)
        static let initialTransform: CGAffineTransform = .init(scaleX: 0.75, y: 0.75)
    }

    // MARK: - Properties

    /// Last shown CMHUD
    private static var current: CMHUD?

    /// Current blur view
    private let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    /// View that displaying in the center of HUD
    private let contentView: UIView

    // MARK: - Initializers

    /// Default internal initialzier
    /// - Parameter contentView: view that displaying in the center of HUD
    internal init(contentView: UIView) {
        self.contentView = contentView
        super.init(
            frame: CGRect(
                origin: .zero,
                size: CGSize(
                    width: CMHUD.Constants.size,
                    height: CMHUD.Constants.size
                )
            )
        )
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView

    public override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = bounds
        smoothlyRoundCourners(radius: CMHUD.Constants.cornerRadius)
    }

    // MARK: - Private

    /// Some hud setup
    private func setup() {
        addSubview(visualEffectView.prepareForAutolayout())
        visualEffectView.pinToSuperview()
        addSubview(contentView.prepareForAutolayout())
        contentView.center(in: self)
    }

    // MARK: - Public

    /// Styles the current view
    /// - Parameter appearance: some colors and styles
    public func design(appearance: CMHUDAppearance) {
        visualEffectView.subviews[1].backgroundColor = appearance.backgroundColor
    }

    /// Shows somw hud instance in the given view
    /// - Parameters:
    ///   - hud: some hud instance
    ///   - view: some view for hud showing
    ///   - animated: true if need to animate this action
    private static func show(
        hud: CMHUD,
        in view: UIView,
        animated: Bool,
        withId identifier: String,
        layoutCenter: Bool = false,
        removingCurrent: Bool
    ) {
        if removingCurrent {
            current?.superview?.removeFromSuperview()
            current = hud
        }
        var animated = animated
        if view.isContainsHUD {
            animated = false
            hide(from: view, animated: animated, animationDuration: 0.6)
        }
        hud.alpha = animated ? 0 : 1
        hud.transform = animated ? CMHUD.Constants.initialTransform : .identity
        if !layoutCenter {
            hud.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        }
        let wrappingView = UIView(frame: view.bounds)
        view.addSubview(wrappingView)
        wrappingView.accessibilityIdentifier = Accessibility.wrapperAccessiilityIdentifier
        wrappingView.addSubview(hud)
        if layoutCenter {
            wrappingView.prepareForAutolayout().pinToSuperview()
            hud
                .prepareForAutolayout()
                .size(CMHUD.Constants.size)
                .center(in: wrappingView)
        }
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut]
            ) { [weak hud] in
                hud?.alpha = 1
                hud?.transform = .identity
            }
        }
    }

    /// Show loading indicator in some view
    /// - Parameters:
    ///   - view: some view for showing hud inside
    ///   - appearance: some colors and styles
    ///   - animated: true if need to animate hud appearance
    public static func loading(
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        removingCurrent: Bool = false
    ) {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.color = appearance.centralViewContentColor
        activityIndicator.transform = .init(scaleX: 1.75, y: 1.75)
        let hud = CMHUD(contentView: activityIndicator)
        hud.design(appearance: appearance)
        show(
            hud: hud,
            in: view,
            animated: animated,
            withId: Accessibility.indicationAccessiilityIdentifier,
            removingCurrent: removingCurrent
        )
    }

    /// Show loading indicator in some view
    /// - Parameters:
    ///   - view: some view for showing hud inside
    ///   - appearance: some colors and styles
    ///   - animated: true if need to animate hud appearance
    public static func loading(
        contentView: UIView,
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        removingCurrent: Bool = false
    ) {
        let hud = CMHUD(contentView: contentView)
        hud.design(appearance: appearance)
        show(
            hud: hud,
            in: view,
            animated: animated,
            withId: Accessibility.indicationAccessiilityIdentifier,
            layoutCenter: true,
            removingCurrent: removingCurrent
        )
    }

    /// Shows hud with image in center
    /// - Parameters:
    ///   - image: some image
    ///   - view: some view for hud presenting
    ///   - appearance: colors and styles for hud
    ///   - imageSize: preferred image size
    ///   - animated: true if need to animate hud appearance
    public static func show(
        image: UIImage,
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        identifier: String,
        imageSize: CGSize,
        animated: Bool = true,
        removingCurrent: Bool = false
    ) {
        let imageWrappingView = UIView()
        let imageWrappingViewSize: CGFloat = 44
        imageWrappingView.layer.cornerRadius = imageWrappingViewSize / 2
        let imageView = UIImageView(image: image.withRenderingMode(.alwaysTemplate))
        imageView.frame.size = imageSize
        imageView.tintColor = appearance.centralViewContentColor
        imageWrappingView.backgroundColor = appearance.centralViewBackgroundColor
        imageWrappingView.prepareForAutolayout().size(imageWrappingViewSize)
        imageWrappingView.addSubview(imageView.prepareForAutolayout())
        imageView.center(in: imageWrappingView)
        let hud = CMHUD(contentView: imageWrappingView)
        hud.design(appearance: appearance)
        show(
            hud: hud,
            in: view,
            animated: animated,
            withId: identifier,
            removingCurrent: removingCurrent
        )
    }

    /// Shows success state inside hud
    /// - Parameters:
    ///   - view: some view for hud presenting
    ///   - appearance: colors anf styles for hud
    ///   - animated: true if need to animate hud appearance
    ///   - interval: the interval after which it needs to be hidden
    public static func success(
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        hideAfter interval: Double = 1.33
    ) {
        let bundle = Bundle(for: CMHUD.self)
        let image = UIImage(named: "success", in: bundle, compatibleWith: nil).unsafelyUnwrapped
        show(
            image: image,
            in: view,
            withAppearance: appearance,
            identifier: Accessibility.successAccessiilityIdentifier,
            imageSize: CGSize(width: 28, height: 20),
            animated: animated
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            hide(from: view, animated: animated)
        }
    }

    /// Shows error state inside hud
    /// - Parameters:
    ///   - view: some view for hud presenting
    ///   - appearance: colors anf styles for hud
    ///   - animated: true if need to animate hud appearance
    ///   - interval: the interval after which it needs to be hidden
    public static func error(
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        hideAfter interval: Double = 1.33
    ) {
        let bundle = Bundle(for: CMHUD.self)
        let image = UIImage(
            named: "error",
            in: bundle,
            compatibleWith: nil
        ).unsafelyUnwrapped
        show(image: image,
             in: view,
             withAppearance: appearance,
             identifier: Accessibility.errorAccessiilityIdentifier,
             imageSize: CGSize(width: 20, height: 20),
             animated: animated
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            hide(from: view, animated: animated)
        }
    }

    /// Shows progress view
    /// - Parameters:
    ///   - progress: progress value
    ///   - view: some view for hud presenting
    ///   - appearance: colors anf styles for hud
    ///   - animated: true if need to animate hud appearance
    public static func progress(
        _ progress: Double,
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        removingCurrent: Bool = false
    ) {
        if let hud = view.hud, let circleView = hud.contentView as? ProgressView {
            circleView.updateWith(progress: CGFloat(progress))
        } else {
            let circleView = ProgressView()
            let size: CGFloat = 44
            circleView.prepareForAutolayout().size(size)
            circleView.layer.cornerRadius = size / 2
            circleView.backgroundColor = appearance.centralViewBackgroundColor
            circleView.fillColor = appearance.centralViewContentColor
            circleView.updateWith(progress: CGFloat(progress))
            let hud = CMHUD(contentView: circleView)
            hud.design(appearance: appearance)
            show(
                hud: hud,
                in: view,
                animated: animated,
                withId: Accessibility.progressAccessiilityIdentifier,
                removingCurrent: removingCurrent
            )
        }
        if progress >= 1 {
            hide(from: view, animated: animated, delay: 0.125)
        }
    }

    /// Shows progress using custom view inside (e.g. animation view)
    /// - Parameters:
    ///   - progress: progress value
    ///   - view: some view for hud presenting
    ///   - appearance: colors anf styles for hud
    ///   - animated: true if need to animate hud appearance
    public static func progress<T: UIView & Progressable>(
        _ progress: Double,
        with animationView: T,
        in view: UIView,
        withAppearance appearance: CMHUDAppearance = .standard,
        animated: Bool = true,
        removingCurrent: Bool = false
    ) {
        if let hud = view.hud, hud.contentView == animationView {
            animationView.updateProgress(progress)
        } else {
            let hud = CMHUD(contentView: animationView)
            hud.design(appearance: appearance)
            show(
                hud: hud,
                in: view,
                animated: animated,
                withId: Accessibility.progressAccessiilityIdentifier,
                removingCurrent: removingCurrent
            )
        }
        if progress >= 1 {
            hide(from: view, animated: animated, delay: 0.125)
        }
    }

    /// Hides some hud from the given view
    /// - Parameters:
    ///   - view: some view with hud
    ///   - animated: true if need to animate hiding
    public static func hide(
        from view: UIView,
        animated: Bool = true,
        delay: TimeInterval = 0,
        animationDuration: Double = 0.3
    ) {
        guard let wrapperView = view.subview(withId: Accessibility.wrapperAccessiilityIdentifier) else {
            return
        }
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: { [weak wrapperView] in
                    wrapperView?.alpha = 0
                    wrapperView?.transform = CMHUD.Constants.initialTransform
                },
                completion: { [weak wrapperView] _ in
                    wrapperView?.removeFromSuperview()
                }
            )
        } else {
            wrapperView.removeFromSuperview()
        }
    }
}

// MARK: - UIView

extension UIView {

    public var isContainsHUD: Bool {
        hud != nil
    }

    public var hud: CMHUD? {
        subviews.compactMap {
            $0.subviews.compactMap { $0 as? CMHUD }.first
        }.first
    }
}

// MARK: - Progressable

public protocol Progressable {

    /// Update progress value
    /// - Parameter progress: new progress value
    func updateProgress(_ progress: Double)
}

// MARK: - ProgressView

private final class ProgressView: UIView {

    // MARK: - Properties

    private var progress: CGFloat = 0 {
        didSet {
            progressLayer?.progress = progress
        }
    }

    private var progressLayer: ProgressLayer? {
        layer as? ProgressLayer
    }

    override class var layerClass: AnyClass {
        ProgressLayer.self
    }

    override var backgroundColor: UIColor? {
        didSet {
            layer.backgroundColor = backgroundColor?.cgColor
        }
    }

    var fillColor: UIColor = .white

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        genericInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        genericInit()
    }

    // MARK: - Private

    private func genericInit() {
        isOpaque = false
        layer.contentsScale = UIScreen.main.scale
        layer.setNeedsDisplay()
    }

    // MARK: - Internal

    func updateWith(progress: CGFloat) {
        self.progress = progress
    }
}

// MARK: - ProgressLayer

private final class ProgressLayer: CALayer {

    // MARK: - Properties

    var fillColor: CGColor {
        (delegate as? ProgressView)?.fillColor.cgColor ?? UIColor.white.cgColor
    }

    @NSManaged var progress: CGFloat

    // MARK: - CALayer

    override class func needsDisplay(forKey key: String) -> Bool {
        key == "progress" || super.needsDisplay(forKey: key)
    }

    override func action(forKey event: String) -> CAAction? {
        if event == "progress" {
            let animation = CABasicAnimation(keyPath: event)
            animation.duration = 0.125
            animation.fromValue = presentation()?.value(forKey: event) ?? 0
            return animation
        }
        return super.action(forKey: event)
    }

    override func draw(in ctx: CGContext) {

        guard progress > 0 else {
            return
        }

        let circleRect = bounds
        let backgroundColor = backgroundColor ?? UIColor.white.cgColor

        ctx.setFillColor(fillColor)
        ctx.fillEllipse(in: circleRect)

        let radius = min(circleRect.midX, circleRect.midY)
        let center = CGPoint(x: radius, y: circleRect.midY)
        let startAngle = CGFloat(-(Double.pi / 2))
        let endAngle = CGFloat(startAngle + 2 * CGFloat(.pi * Double(progress)))

        ctx.setFillColor(backgroundColor)
        ctx.move(
            to: CGPoint(
                x: center.x,
                y: center.y
            )
        )
        ctx.addArc(
            center: CGPoint(
                x: center.x,
                y: center.y
            ),
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: true
        )
        ctx.closePath()
        ctx.fillPath()
    }
}
