/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import AVFoundation
import Foundation
import UIKit
import Chatto

class LiveCameraCell: UICollectionViewCell {

    fileprivate struct Constants {
        static let backgroundColor = UIColor(red: 24.0/255.0, green: 101.0/255.0, blue: 245.0/255.0, alpha: 1)
        static let cameraImageName = "camera"
        static let lockedCameraImageName = "camera_lock"
    }

    fileprivate var iconImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    fileprivate func commonInit() {
        self.configureIcon()
        self.contentView.backgroundColor = Constants.backgroundColor
    }

    var captureLayer: CALayer? {
        didSet {
            if oldValue !== self.captureLayer {
                oldValue?.removeFromSuperlayer()
                if let captureLayer = self.captureLayer {
                    self.contentView.layer.insertSublayer(captureLayer, below: self.iconImageView.layer)
                    let animation = CABasicAnimation.bma_fadeInAnimationWithDuration(0.25)
                    let animationKey = "fadeIn"
                    captureLayer.removeAnimation(forKey: animationKey)
                    captureLayer.add(animation, forKey: animationKey)
                }
                self.setNeedsLayout()
            }
        }
    }

    typealias CellCallback = (_ cell: LiveCameraCell) -> Void

    var onWasAddedToWindow: CellCallback?
    var onWasRemovedFromWindow: CellCallback?
    override func didMoveToWindow() {
        if let _ = self.window {
            self.onWasAddedToWindow?(self)
        } else {
            self.onWasRemovedFromWindow?(self)
        }
    }

    func updateWithAuthorizationStatus(_ status: AVAuthorizationStatus) {
        self.authorizationStatus = status
        self.updateIcon()
    }

    fileprivate var authorizationStatus: AVAuthorizationStatus = .notDetermined

    fileprivate func configureIcon() {
        self.iconImageView = UIImageView()
        self.iconImageView.contentMode = .center
        self.contentView.addSubview(self.iconImageView)
    }

    fileprivate func updateIcon() {
        switch self.authorizationStatus {
        case .notDetermined, .authorized:
            self.iconImageView.image = UIImage(named: Constants.cameraImageName, in: Bundle(for: LiveCameraCell.self), compatibleWith: nil)
        case .restricted, .denied:
            self.iconImageView.image = UIImage(named: Constants.lockedCameraImageName, in: Bundle(for: LiveCameraCell.self), compatibleWith: nil)
        }
        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.captureLayer?.frame = self.contentView.bounds
        self.iconImageView.sizeToFit()
        self.iconImageView.center = self.contentView.bounds.bma_center
    }
}
