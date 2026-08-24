
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
    /// A system material, so it follows light and dark mode on its own rather than being pinned to
    /// one of them. It carries the blur, `themeController`'s tint carries the contrast .. the two
    /// are layered rather than either one doing both
    var blurView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .systemThinMaterial))
    /// Laid over the blur, not under it, so white text reads whatever the blur resolved to
    var contrastTintView: UIView = {
        let tint: UIView = .init(frame: .zero)
        tint.backgroundColor = UIColor(white: 0, alpha: 0.5)
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
        themeBackButton()
        themePoweredByTap()
        addBackButtonActionHandler()
        localize()
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
    /// Clear .. `blurView` fills the bar's whole bounds and is what actually blurs what is behind it.
    /// A colour on the view itself would sit between the blur and the screen and be the only thing
    /// the blur ever saw, which is exactly how this ended up looking flat before. The contrast the
    /// white text needs comes from a tint layered *over* the blur instead, in `setupConstraints`
    func themeController() {
        backgroundColor = .clear
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
        // Blur first, then the tint over it, then the content over both .. the tint has to sit above
        // the blur so it darkens the blurred result rather than being the thing that gets blurred
        addSubview(blurView)
        blurView.contentView.addSubview(contrastTintView)
        addSubview(poweredByTapImageView)
        addSubview(backView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        contrastTintView.translatesAutoresizingMaskIntoConstraints = false
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

            contrastTintView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            contrastTintView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            contrastTintView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            contrastTintView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
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
