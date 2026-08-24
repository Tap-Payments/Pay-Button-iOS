
import UIKit
import TapFontKit_iOS

class PoweredByTapView: UIView {

    /// The view holding the back button
    var backView: UIView = .init(frame: .zero)
    /// The back button
    var backButton: UIButton = .init(frame: .zero)
    /// The back label
    var backLabel: UILabel = .init(frame: .zero)
    /// Indicating the back icon for the user
    var backIconImageView: UIImageView = .init(frame: .zero)
    /// Indicating the powered by tap icon for the user
    var poweredByTapImageView: UIImageView = .init(frame: .zero)
    /// The bar's own backdrop blur, of whatever sits directly behind the bar and nothing else.
    ///
    /// A public system material. Card-iOS reaches its blur through `_UICustomBlurEffect` and private
    /// key paths, and copying that verbatim here rendered the bar solid black .. measured, rgb 0
    /// against Card-iOS's own 89. It resolves in Card-iOS and does not resolve here, which is what
    /// undocumented api does. The material blurs, `tintOverBlur` supplies the step, and between them
    /// they land where Card-iOS lands without depending on anything Apple can withdraw
    var blurView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .systemThinMaterial))
    /// The step between the bar and the dim behind it, measured to land where Card-iOS's does.
    ///
    /// A plain sibling over the blur rather than the effect view's own tint .. its overlay does not
    /// exist on current ios and anything put in `contentView` is dropped, both confirmed in the live
    /// view tree, so neither is somewhere a tint can be relied on to render
    var tintOverBlur: UIView = {
        let tint: UIView = .init(frame: .zero)
        tint.isUserInteractionEnabled = false
        return tint
    }()
    /// Represents the locale needed to render the powered by tap view with
    var selectedLocale:String = "en" {
        didSet{
            localize()
        }
    }
    /// A callback to do when the back button is clicked
    var backButtonClicked:()->() = {}
    /// Whether the "powered by tap" image shows. The back button shows either way, there has to be
    /// a way out of the page regardless of who the page belongs to
    var showsPoweredByTapImage:Bool {
        get { !poweredByTapImageView.isHidden }
        set { poweredByTapImageView.isHidden = !newValue }
    }

    //MARK: - Init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    //MARK: - Private methods
    /// Used as a consolidated method to do all the needed steps upon creating the view
    private func commonInit() {
        setupConstraints()
        themeController()
        themeVisualEffectView()
        themeBackButton()
        themePoweredByTap()
        addBackButtonActionHandler()
        localize()
    }

    /// The blur's tint is picked per appearance, so it has to be picked again when the appearance
    /// changes under a bar that is already on screen. Card-iOS reads the style once at init and
    /// never revisits it, which is the one part of it not worth copying
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard #available(iOS 13.0, *),
              traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else { return }
        themeVisualEffectView()
    }

    /// Creates an event listener when clicking on the back button
    func addBackButtonActionHandler() {
        backButton.addTarget(self, action: #selector(didButtonClick), for: .touchUpInside)
    }

    @objc func didButtonClick(_ sender: UIButton) {
        self.backButtonClicked()
    }
}

// MARK: - Theme based methods
extension PoweredByTapView {
    /// Theme the view level.
    ///
    /// Clear .. `blurView` covers the bar's whole bounds, so a colour here would only ever be a
    /// thing behind the blur rather than something anyone sees. The darkening the white text needs
    /// comes from `tintOverBlur`, over the blur, where it actually renders
    func themeController() {
        backgroundColor = .clear
    }

    /// Theme the blur view level
    func themeVisualEffectView() {
        blurView.effect = UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemThinMaterialDark : .systemThinMaterial)
        // Card-iOS's dark tint is 0.06/0.32, but its blur resolves differently .. these are the
        // numbers that put this bar at the same measured value as its bar
        tintOverBlur.backgroundColor = UIColor(white: 0, alpha: traitCollection.userInterfaceStyle == .dark ? 0.32 : 0.08)
    }


    /// Theme the back button level
    func themeBackButton() {
        backIconImageView.image = .init(systemName: "chevron.backward")
        backIconImageView.tintColor = .white
        backLabel.textColor = .white
        backLabel.backgroundColor = .clear
        backView.backgroundColor = .clear
        backButton.backgroundColor = .clear
        backView.backgroundColor = .clear
    }

    /// Theme the back button level
    func themePoweredByTap() {
        poweredByTapImageView.image = UIImage(named: "Powered-by-tap",in: Bundle.currentBundle, with: nil)
        poweredByTapImageView.tintColor = .white
        poweredByTapImageView.contentMode = .scaleAspectFit
    }

    func setupConstraints() {
        backView.addSubview(backIconImageView)
        backView.addSubview(backLabel)
        backView.addSubview(backButton)
        addSubview(blurView)
        // A plain sibling over the blur, not inside its `contentView` .. the effect view's own
        // overlay does not exist on current ios, and subviews put into `contentView` are dropped
        // when the private path swaps `effect` out from under them. Verified in the live view tree
        addSubview(tintOverBlur)
        addSubview(poweredByTapImageView)
        addSubview(backView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        tintOverBlur.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false
        backIconImageView.translatesAutoresizingMaskIntoConstraints = false
        backLabel.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        poweredByTapImageView.translatesAutoresizingMaskIntoConstraints = false
        poweredByTapImageView.tintColor = .white

        let constraintsBlur = [
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            tintOverBlur.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tintOverBlur.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tintOverBlur.topAnchor.constraint(equalTo: self.topAnchor),
            tintOverBlur.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]

        // Anchored to the bottom, not the top .. the view itself now reaches up to cover the safe
        // area above it too, and the row has to stay put at the bottom of that, where it always was
        let constraintsPoweredImage = [
            poweredByTapImageView.heightAnchor.constraint(equalToConstant: 30),
            poweredByTapImageView.widthAnchor.constraint(equalToConstant: 112),
            poweredByTapImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            poweredByTapImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -17),
        ]

        let constraintsBackView = [
            backView.heightAnchor.constraint(equalToConstant: 20),
            backView.widthAnchor.constraint(equalToConstant: 64),
            backView.centerYAnchor.constraint(equalTo: self.bottomAnchor, constant: -32),
            backView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
        ]

        let constraintsBackButton = [
            backButton.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            backButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            backButton.topAnchor.constraint(equalTo: backView.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor)
        ]

        let constraintsBackIcon = [
            backIconImageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            backIconImageView.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            backIconImageView.widthAnchor.constraint(equalToConstant: 10),
            backIconImageView.heightAnchor.constraint(equalToConstant: 20)
        ]


        let constraintsBackLabel = [
            backLabel.leadingAnchor.constraint(equalTo: backIconImageView.trailingAnchor, constant: 8),
            backLabel.centerYAnchor.constraint(equalTo: backIconImageView.centerYAnchor),
            backLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor)
        ]


        NSLayoutConstraint.activate(constraintsBlur+constraintsPoweredImage+constraintsBackView+constraintsBackButton+constraintsBackIcon+constraintsBackLabel)


        DispatchQueue.main.async {
            self.blurView.setNeedsLayout()
            self.blurView.updateConstraints()

            self.poweredByTapImageView.setNeedsLayout()
            self.poweredByTapImageView.updateConstraints()

            self.backView.setNeedsLayout()
            self.backView.updateConstraints()

            self.backButton.setNeedsLayout()
            self.backButton.updateConstraints()

            self.backIconImageView.setNeedsLayout()
            self.backIconImageView.updateConstraints()

            self.backLabel.setNeedsLayout()
            self.backLabel.updateConstraints()

            self.setNeedsLayout()
            self.updateConstraints()
        }

    }

    /// Will change the direction of the language based uiviews/elements
    func localize() {
        DispatchQueue.main.async {
            self.semanticContentAttribute = self.selectedLocale.lowercased() == "ar" ? .forceRightToLeft : .forceLeftToRight
            self.backIconImageView.semanticContentAttribute = self.selectedLocale.lowercased() == "ar" ? .forceRightToLeft : .forceLeftToRight
            self.backView.semanticContentAttribute = self.selectedLocale.lowercased() == "ar" ? .forceRightToLeft : .forceLeftToRight
            self.backLabel.font = FontProvider.localizedFont(.robotoRegular, size: 16, languageIdentifier: self.selectedLocale.lowercased())
            self.backLabel.text = self.selectedLocale.lowercased() == "ar" ? "رجوع" : "Back"
            self.backLabel.semanticContentAttribute = self.selectedLocale.lowercased() == "ar" ? .forceRightToLeft : .forceLeftToRight
        }
    }

}
