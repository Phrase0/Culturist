//
//  Toast.swift
//  Toast
//
//  Created by incetro on 5/11/2021.
//  Copyright © 2021 Incetro Inc. All rights reserved.
//

import UIKit

// MARK: - Toast

final public class Toast {

    // MARK: - Style

    /// Define a custom style for the toast.
    public struct Style {
        /// Specifies the position of the icon on the toast. (Default is `.left`)
        ///
        /// - left: The icon will be on the left of the text
        /// - right: The icon will be on the right of the text
        public enum IconAlignment {
            case left
            case right
        }

        /// Specifies the width of the Toast. (Default is `.fixed(Constants.wdith)`)
        ///
        /// - fixed: Specified as pixel size. i.e. 280
        /// - screenPercentage: Specified as a ratio to the screen size. This value must be between 0 and 1. i.e. 0.8
        public enum Width {
            case fixed(CGFloat)
            case screenPercentage(CGFloat)
        }

        /// Icon image type
        public enum Accessory {
            case standard(UIImage)
            case custom(UIView)
        }

        /// The background color of the toast.
        let backgroundColor: UIColor

        /// The color of the label's text
        let textColor: UIColor

        /// The color of the icon (Assuming it's rendered as template)
        let tintColor: UIColor

        /// The font of the label
        let font: UIFont

        /// The icon on the toast
        let accessory: Accessory?

        /// Our icon / view size
        let accessorySize: CGFloat

        /// The alignment of the text within the Toast
        let textAlignment: NSTextAlignment

        /// The position of the icon
        let iconAlignment: IconAlignment

        /// The width of the toast
        let width: Width

        /// True if we need to blur toast color
        let isBlurred: Bool

        // MARK: - Initializers

        public init(
            backgroundColor: UIColor,
            textColor: UIColor = .white,
            tintColor: UIColor = .white,
            font: UIFont = .systemFont(ofSize: 14, weight: .medium),
            accessory: Accessory? = .standard(Icon.info),
            accessorySize: CGFloat = 24,
            textAlignment: NSTextAlignment = .left,
            iconAlignment: IconAlignment = .left,
            width: Width = .fixed(Constants.width),
            isBlurred: Bool = false
        ) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.font = font
            self.accessory = accessory
            self.accessorySize = accessorySize
            self.textAlignment = textAlignment
            self.iconAlignment = iconAlignment
            self.width = width
            self.isBlurred = isBlurred
        }
    }

    // MARK: - State

    /// Defines the toast's status. (Default is `.info`)
    ///
    /// - success: Represents a success message
    /// - error: Represents an error message
    /// - warning: Represents a warning message
    /// - info: Represents an info message
    /// - custom: Represents a custom toast with a specified style.
    public enum State {
        case success
        case error
        case warning
        case info
        case custom(Style)
    }

    // MARK: - Location

    /// Defines the loaction to display the toast. (Default is `.bottom`)
    ///
    /// - top: Top of the display
    /// - bottom: Bottom of the display
    public enum Location {
        case top
        case bottom
    }

    // MARK: - Direction

    /// Defines either the presenting or dismissing direction of toast. (Default is `.vertical`)
    ///
    /// - left: To / from the left
    /// - right: To / from the right
    /// - vertical: To / from the top or bottom (depending on the location of the toast)
    public enum Direction {
        case left
        case right
        case vertical
    }

    // MARK: - Duration

    /// Defines the duration of the toast presentation. (Default is .`avergae`)
    ///
    /// - short: 2 seconds
    /// - average: 4 seconds
    /// - long: 8 seconds
    /// - custom: A custom duration (usage: `.custom(5.0)`)
    public enum Duration {

        case short
        case average
        case long
        case custom(TimeInterval)

        var length: TimeInterval {
            switch self {
            case .short:
                return 2.0
            case .average:
                return 4.0
            case .long:
                return 8.0
            case .custom(let timeInterval):
                return timeInterval
            }
        }
    }

    // MARK: - Icon

    /// Icons used in basic states
    public enum Icon {

        /// Framework bundle
        private static let frameworkBundle = Bundle(for: Toast.self)

        /// Success icon
        public static let success = UIImage(
            named: "success",
            in: frameworkBundle,
            compatibleWith: nil
        ).unsafelyUnwrapped.withRenderingMode(.alwaysTemplate)

        /// Error icon
        public static let error = UIImage(
            named: "error",
            in: frameworkBundle,
            compatibleWith: nil
        ).unsafelyUnwrapped.withRenderingMode(.alwaysTemplate)

        /// Warning icon
        public static let warning = UIImage(
            named: "warning",
            in: frameworkBundle,
            compatibleWith: nil
        ).unsafelyUnwrapped.withRenderingMode(.alwaysTemplate)

        /// Info icon
        public static let info = UIImage(
            named: "info",
            in: frameworkBundle,
            compatibleWith: nil
        ).unsafelyUnwrapped.withRenderingMode(.alwaysTemplate)
    }

    // MARK: - DismissalReason

    // Reason a Toast was dismissed
    public enum DismissalReason {
        case tapped
        case timedOut
    }

    // MARK: - Properties

    /// Completion closure alias
    public typealias ToastCompletionHandler = (DismissalReason) -> Void

    /// Current accessory size
    var accessorySize: CGFloat {
        switch state {
        case .custom(let style):
            return style.accessorySize
        default:
            return 24
        }
    }

    /// Toast message
    let message: String

    /// Current state
    let state: State

    /// Target location
    let location: Location

    /// Toast presentation duration
    private(set) var duration: Duration = .average

    /// Presentation direction value
    let presentingDirection: Direction

    /// Dismissing direction value
    let dismissingDirection: Direction

    /// Completion closure
    private(set) var completionHandler: ToastCompletionHandler?

    /// Source view controller
    weak var source: UIViewController?

    // MARK: - Initializers

    /// Default initializer
    /// - Parameters:
    ///   - message: toast message
    ///   - state: current state
    ///   - location: target location
    ///   - presentingDirection: presentation direction value
    ///   - dismissingDirection: dismissing direction value
    ///   - source: source view controller
    public init(
        _ message: String,
        state: State = .info,
        location: Location = .bottom,
        presentingDirection: Direction = .vertical,
        dismissingDirection: Direction = .vertical,
        source: UIViewController
    ) {
        self.message = message
        self.state = state
        self.location = location
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        self.source = source
    }

    // MARK: - Useful

    /// Show the toast for a specified duration. (Default is `.average`)
    ///
    /// - Parameter duration: Length the toast will be presented
    public func show(_ duration: Duration = .average, completionHandler: ToastCompletionHandler? = nil) {
        self.duration = duration
        self.completionHandler = completionHandler
        ToastManipulator.shared.queueAndPresent(self)
    }

    /// Manually dismiss a currently presented Toast
    ///
    /// - Parameter animated: Whether the dismissal will be animated
    public static func dismiss(source: UIViewController, animated: Bool = true){
        guard ToastManipulator.shared.isPresenting else { return }
        guard let vc = source.presentedViewController as? ToastViewController else { return }
        vc.dismiss(animated: animated) {
            vc.delegate?.toastDidDismiss()
        }
    }
}

// MARK: - ToastManipulator

private final class ToastManipulator: ToastDelegate {

    // MARK: - Properties

    /// Singleton instance
    static let shared = ToastManipulator()

    /// Toasts queue
    fileprivate var queue = Queue<Toast>()

    /// True if we have some toast at the moment
    fileprivate var isPresenting = false

    // MARK: - Useful

    /// Add toast to global toasts queue
    /// - Parameter toast: toast instance
    fileprivate func queueAndPresent(_ toast: Toast) {
        queue.enqueue(toast)
        presentIfPossible()
    }

    // MARK: - ToastDelegate

    /// Toast has been dismissed
    func toastDidDismiss() {
        isPresenting = false
        presentIfPossible()
    }

    /// Present next toast if it's possible
    fileprivate func presentIfPossible() {
        guard isPresenting == false, let toast = queue.dequeue(), let source = toast.source else { return }
        isPresenting = true
        let toastVC = ToastViewController(toast)
        toastVC.delegate = self
        source.toast(toastVC)
    }
}

// MARK: - ToastDelegate

private protocol ToastDelegate: AnyObject {

    /// Toast has been dismissed
    func toastDidDismiss()
}

// MARK: - ToastViewController

final class ToastViewController: UIViewController {

    // MARK: - Properties

    /// Current toast instance
    let toast: Toast

    /// Visual effect (blur) view
    private lazy var blurBackgroundView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blur.isUserInteractionEnabled = false
        blur.subviews[1].backgroundColor = UIColor.black.withAlphaComponent(0.93)
        return blur
    }()

    /// Current toast message
    private let label = UILabel()

    /// Current accessory view unwrapped to UIImageView
    private var imageView: UIImageView? {
        accessoryView as? UIImageView
    }

    /// Current toast image
    private let accessoryView: UIView

    /// Current message font
    private var font = UIFont.systemFont(ofSize: 14, weight: .medium)

    /// Current toast text alignment
    private var textAlignment: NSTextAlignment = .left

    /// Transitioning delegate instance
    var transDelegate: UIViewControllerTransitioningDelegate

    /// Delegate instance
    fileprivate weak var delegate: ToastDelegate?

    // MARK: - Initializers

    /// Default initializer
    /// - Parameter toast: some toast
    init(_ toast: Toast) {
        switch toast.state {
        case .custom(let style):
            if case let .custom(view) = style.accessory {
                accessoryView = view
            } else {
                fallthrough
            }
        default:
            accessoryView = UIImageView()
        }
        self.toast = toast
        self.transDelegate = ToastTransitioningDelegate(toast: toast, size: .zero)
        super.init(nibName: nil, bundle: nil)
        let width: CGFloat
        if case let Toast.State.custom(style) = toast.state {
            self.font = style.font
            self.textAlignment = style.textAlignment
            switch style.width {
            case .fixed(let value):
                width = value
            case .screenPercentage(let percentage):
                guard 0...1 ~= percentage else { return }
                width = UIScreen.main.bounds.width * percentage
            }
        } else {
            width = Constants.width
        }
        let height = max(
            toast.message.heightWithConstrainedWidth(
                width: Constants.width - Constants.sidesInset * 2,
                font: font
            ) + 36,
            Constants.height
        )
        preferredContentSize = CGSize(width: width, height: height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        label.text = toast.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.font = font
        label.textAlignment = textAlignment
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false

        imageView?.tintColor = .white
        imageView?.contentMode = .scaleAspectFit
        accessoryView.translatesAutoresizingMaskIntoConstraints = false

        switch toast.state {
        case .success:
            imageView?.image = Toast.Icon.success
            view.backgroundColor = UIColor(hexString: "#2ECC71")
            constrainWithIconAlignment(.left)
        case .warning:
            imageView?.image = Toast.Icon.warning
            view.backgroundColor = UIColor(hexString: "#FCAB10")
            constrainWithIconAlignment(.left)
        case .error:
            imageView?.image = Toast.Icon.error
            view.backgroundColor = UIColor(hexString: "#F8333C")
            constrainWithIconAlignment(.left)
        case .info:
            imageView?.image = Toast.Icon.info
            view.backgroundColor = UIColor(hexString: "#738290")
            constrainWithIconAlignment(.left)
        case .custom(style: let style):
            if style.isBlurred {
                blurBackgroundView.subviews[1].backgroundColor = style.backgroundColor
            } else {
                view.backgroundColor = style.backgroundColor
            }
            label.textColor = style.textColor
            label.font = style.font
            switch style.accessory {
            case .standard(let image):
                imageView?.image = image
                imageView?.tintColor = style.tintColor
                constrainWithIconAlignment(style.iconAlignment, showsIcon: imageView?.image != nil)
            case .none:
                constrainWithIconAlignment(style.iconAlignment, showsIcon: false)
            default:
                constrainWithIconAlignment(style.iconAlignment, showsIcon: true)
                break
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)

        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration.length, execute: {
            self.dismiss(animated: true) { [weak self] in
                self?.delegate?.toastDidDismiss()
                self?.toast.completionHandler?(.timedOut)
            }
        })
    }

    // MARK: - Actions

    @objc private func handleTap() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.toastDidDismiss()
            self?.toast.completionHandler?(.tapped)
        }
    }

    // MARK: - Private

    private func constrainWithIconAlignment(_ alignment: Toast.Style.IconAlignment, showsIcon: Bool = true) {

        if case let .custom(style) = toast.state, style.isBlurred {
            view.addSubview(blurBackgroundView)
            blurBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                blurBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                blurBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
                blurBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        view.addSubview(label)
        let sidesInset: CGFloat = 13
        if showsIcon {
            view.addSubview(accessoryView)
            switch alignment {
            case .left:
                NSLayoutConstraint.activate([
                    accessoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidesInset),
                    accessoryView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    accessoryView.heightAnchor.constraint(equalToConstant: toast.accessorySize),
                    accessoryView.widthAnchor.constraint(equalToConstant: toast.accessorySize),
                    label.leadingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: sidesInset),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidesInset),
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    accessoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidesInset),
                    accessoryView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    accessoryView.heightAnchor.constraint(equalToConstant: toast.accessorySize),
                    accessoryView.widthAnchor.constraint(equalToConstant: toast.accessorySize),
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidesInset),
                    label.trailingAnchor.constraint(equalTo: accessoryView.leadingAnchor, constant: -sidesInset),
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: sidesInset),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -sidesInset),
                label.topAnchor.constraint(equalTo: view.topAnchor),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}

// MARK: - Queue

/// FIFO Queue simple implementation
private struct Queue<T> {

    // MARK: - Properties

    /// Elements array
    fileprivate var array = [T]()

    /// Enqueue some element
    /// - Parameter element: queue element
    mutating func enqueue(_ element: T) {
        array.append(element)
    }

    /// Dequeue first element
    /// - Returns: first element in queue
    mutating func dequeue() -> T? {
        if array.isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}
