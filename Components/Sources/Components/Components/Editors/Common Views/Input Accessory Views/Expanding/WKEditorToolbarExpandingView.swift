import UIKit

protocol WKEditorToolbarExpandingViewDelegate: AnyObject {
    func toolbarExpandingViewDidTapFind(toolbarView: WKEditorToolbarExpandingView)
    func toolbarExpandingViewDidTapFormatText(toolbarView: WKEditorToolbarExpandingView)
    func toolbarExpandingViewDidTapTemplate(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool)
    func toolbarExpandingViewDidTapUnorderedList(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool)
    func toolbarExpandingViewDidTapOrderedList(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool)
    func toolbarExpandingViewDidTapIncreaseIndent(toolbarView: WKEditorToolbarExpandingView)
    func toolbarExpandingViewDidTapDecreaseIndent(toolbarView: WKEditorToolbarExpandingView)
}

class WKEditorToolbarExpandingView: WKEditorToolbarView {
    
    // MARK: - Nested Types
    
    private enum ActionsType: CGFloat {
        case primary
        case secondary

        static func visible(rawValue: RawValue) -> ActionsType {
            if rawValue == 0 {
                return .primary
            } else {
                return .secondary
            }
        }

        static func next(rawValue: RawValue) -> ActionsType {
            if rawValue == 0 {
                return .secondary
            } else {
                return .primary
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var primaryContainerView: UIView!
    @IBOutlet weak var secondaryContainerView: UIView!

    @IBOutlet private weak var formatTextButton: WKEditorToolbarButton!
    @IBOutlet private weak var citationButton: WKEditorToolbarButton!
    @IBOutlet private weak var linkButton: WKEditorToolbarButton!
    @IBOutlet private weak var templateButton: WKEditorToolbarButton!
    @IBOutlet private weak var mediaButton: WKEditorToolbarButton!
    @IBOutlet private weak var findInPageButton: WKEditorToolbarButton!
    
    @IBOutlet private weak var unorderedListButton: WKEditorToolbarButton!
    @IBOutlet private weak var orderedListButton: WKEditorToolbarButton!
    @IBOutlet private weak var decreaseIndentionButton: WKEditorToolbarButton!
    @IBOutlet private weak var increaseIndentionButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorUpButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorDownButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorLeftButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorRightButton: WKEditorToolbarButton!
    
    @IBOutlet private weak var expandButton: WKEditorToolbarNavigatorButton!
    
    weak var delegate: WKEditorToolbarExpandingViewDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            stackView.removeArrangedSubview(primaryContainerView)
            stackView.addArrangedSubview(primaryContainerView)
        }

        expandButton.isAccessibilityElement = false
        expandButton.setImage(WKSFSymbolIcon.for(symbol: .chevronRightCircle), for: .normal)
        expandButton.addTarget(self, action: #selector(tappedExpand), for: .touchUpInside)
        expandButton.isAccessibilityElement = false

        formatTextButton.setImage(WKIcon.formatText, for: .normal)
        formatTextButton.addTarget(self, action: #selector(tappedFormatText), for: .touchUpInside)
        formatTextButton.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.formatTextButton
        formatTextButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonFormatText

        citationButton.setImage(WKSFSymbolIcon.for(symbol: .quoteOpening), for: .normal)
        citationButton.addTarget(self, action: #selector(tappedCitation), for: .touchUpInside)
        citationButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonCitation

        linkButton.setImage(WKSFSymbolIcon.for(symbol: .link), for: .normal)
        linkButton.addTarget(self, action: #selector(tappedLink), for: .touchUpInside)
        linkButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonLink

        templateButton.setImage(WKSFSymbolIcon.for(symbol: .curlybraces), for: .normal)
        templateButton.addTarget(self, action: #selector(tappedTemplate), for: .touchUpInside)
        templateButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonTemplate

        mediaButton.setImage(WKSFSymbolIcon.for(symbol: .photo), for: .normal)
        mediaButton.addTarget(self, action: #selector(tappedMedia), for: .touchUpInside)
        mediaButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonMedia

        findInPageButton.setImage(WKSFSymbolIcon.for(symbol: .docTextMagnifyingGlass), for: .normal)
        findInPageButton.addTarget(self, action: #selector(tappedFindInPage), for: .touchUpInside)
        findInPageButton.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.findButton
        findInPageButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonFind

        unorderedListButton.setImage(WKSFSymbolIcon.for(symbol: .listBullet), for: .normal)
        unorderedListButton.addTarget(self, action: #selector(tappedUnorderedList), for: .touchUpInside)
        unorderedListButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonListUnordered

        orderedListButton.setImage(WKSFSymbolIcon.for(symbol: .listNumber), for: .normal)
        orderedListButton.addTarget(self, action: #selector(tappedOrderedList), for: .touchUpInside)
        orderedListButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonListOrdered

        decreaseIndentionButton.setImage(WKSFSymbolIcon.for(symbol: .decreaseIndent), for: .normal)
        decreaseIndentionButton.addTarget(self, action: #selector(tappedDecreaseIndentation), for: .touchUpInside)
        decreaseIndentionButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonDecreaseIndent
        decreaseIndentionButton.isEnabled = false

        increaseIndentionButton.setImage(WKSFSymbolIcon.for(symbol: .increaseIndent), for: .normal)
        increaseIndentionButton.addTarget(self, action: #selector(tappedIncreaseIndentation), for: .touchUpInside)
        increaseIndentionButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonInceaseIndent
        increaseIndentionButton.isEnabled = false

        cursorUpButton.setImage(WKIcon.chevronUp, for: .normal)
        cursorUpButton.addTarget(self, action: #selector(tappedCursorUp), for: .touchUpInside)
        cursorUpButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonCursorUp

        cursorDownButton.setImage(WKIcon.chevronDown, for: .normal)
        cursorDownButton.addTarget(self, action: #selector(tappedCursorDown), for: .touchUpInside)
        cursorDownButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonCursorDown

        cursorLeftButton.setImage(WKIcon.chevronLeft, for: .normal)
        cursorLeftButton.addTarget(self, action: #selector(tappedCursorLeft), for: .touchUpInside)
        cursorLeftButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonCursorLeft

        cursorRightButton.setImage(WKIcon.chevronRight, for: .normal)
        cursorRightButton.addTarget(self, action: #selector(tappedCursorRight), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateButtonSelectionState(_:)), name: Notification.WKSourceEditorSelectionState, object: nil)
    }
    
    // MARK: - Notifications
    
    @objc private func updateButtonSelectionState(_ notification: NSNotification) {
        guard let selectionState = notification.userInfo?[Notification.WKSourceEditorSelectionStateKey] as? WKSourceEditorSelectionState else {
            return
        }
        
        templateButton.isSelected = selectionState.isHorizontalTemplate
        
        unorderedListButton.isSelected = selectionState.isBulletSingleList || selectionState.isBulletMultipleList
        unorderedListButton.isEnabled = !selectionState.isNumberSingleList && !selectionState.isNumberMultipleList
        
        orderedListButton.isSelected = selectionState.isNumberSingleList || selectionState.isNumberMultipleList
        orderedListButton.isEnabled = !selectionState.isBulletSingleList && !selectionState.isBulletMultipleList
        
        decreaseIndentionButton.isEnabled = false
        if selectionState.isBulletMultipleList || selectionState.isNumberMultipleList {
            decreaseIndentionButton.isEnabled = true
        }
        
        if selectionState.isBulletSingleList ||
            selectionState.isBulletMultipleList ||
            selectionState.isNumberSingleList ||
            selectionState.isNumberMultipleList {
            increaseIndentionButton.isEnabled = true
        } else {
            increaseIndentionButton.isEnabled = false
        }
        
        cursorRightButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelButtonCursorRight
    }

    // MARK: - Button Actions
    
    @objc private func tappedExpand() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let offsetX = scrollView.contentOffset.x
        let actionsType = ActionsType.next(rawValue: offsetX)
        
        let transform = CGAffineTransform.identity
        let buttonTransform: () -> Void
        let newOffsetX: CGFloat
        
        let sender = expandButton

        switch actionsType {
        case .primary:
            buttonTransform = {
                sender?.transform = transform
            }
            newOffsetX = 0
        case .secondary:
            buttonTransform = {
                sender?.transform = transform.rotated(by: 180 * CGFloat.pi)
                sender?.transform = transform.rotated(by: -1 * CGFloat.pi)
            }
            newOffsetX = stackView.bounds.width / 2
        }

        let scrollViewContentOffsetChange = {
            self.scrollView.setContentOffset(CGPoint(x: newOffsetX , y: 0), animated: false)
        }

        let buttonAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7, animations: buttonTransform)
        let scrollViewAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: scrollViewContentOffsetChange)

        buttonAnimator.startAnimation()
        scrollViewAnimator.startAnimation()
    }

    @objc private func tappedFormatText() {
        delegate?.toolbarExpandingViewDidTapFormatText(toolbarView: self)
    }
    
    @objc private func tappedFormatHeading() {
    }

    @objc private func tappedCitation() {
    }

    @objc private func tappedLink() {
    }

    @objc private func tappedUnorderedList() {
        delegate?.toolbarExpandingViewDidTapUnorderedList(toolbarView: self, isSelected: unorderedListButton.isSelected)
    }

    @objc private func tappedOrderedList() {
        delegate?.toolbarExpandingViewDidTapOrderedList(toolbarView: self, isSelected: orderedListButton.isSelected)
    }

    @objc private func tappedDecreaseIndentation() {
        delegate?.toolbarExpandingViewDidTapDecreaseIndent(toolbarView: self)
    }

    @objc private func tappedIncreaseIndentation() {
        delegate?.toolbarExpandingViewDidTapIncreaseIndent(toolbarView: self)
    }

    @objc private func tappedCursorUp() {
    }

    @objc private func tappedCursorDown() {
    }

    @objc private func tappedCursorLeft() {
    }

    @objc private func tappedCursorRight() {
    }

    @objc private func tappedTemplate() {
        delegate?.toolbarExpandingViewDidTapTemplate(toolbarView: self, isSelected: templateButton.isSelected)
    }

    @objc private func tappedFindInPage() {
        delegate?.toolbarExpandingViewDidTapFind(toolbarView: self)
    }

    @objc private func tappedMedia() {
    }

}
