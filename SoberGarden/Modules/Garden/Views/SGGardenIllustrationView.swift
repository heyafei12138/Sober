//
//  SGGardenIllustrationView.swift
//  SoberGarden
//

import UIKit

final class SGGardenIllustrationView: UIView {

    private var stage: GardenStage = .seed

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func configure(stage: GardenStage) {
        self.stage = stage
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.saveGState()

        drawSky(in: rect)
        drawGround(in: rect)

        switch stage {
        case .seed:
            drawSeed(in: rect)
        case .sprout:
            drawSprout(in: rect, scale: 0.85)
        case .youngPlant:
            drawSprout(in: rect, scale: 1.15)
            drawLeafCluster(in: rect, yOffset: -18, size: 30)
        case .flower:
            drawSprout(in: rect, scale: 1.05)
            drawFlower(in: rect, xOffset: 0, yOffset: -54, size: 18)
        case .gardenBed:
            drawGardenBed(in: rect, flowers: 3, trees: 0)
        case .bloomingGarden:
            drawGardenBed(in: rect, flowers: 5, trees: 1)
        case .peacefulGarden:
            drawGardenBed(in: rect, flowers: 6, trees: 2)
            drawPath(in: rect)
        case .smallForest:
            drawForest(in: rect, treeCount: 4)
        case .sanctuary:
            drawForest(in: rect, treeCount: 5)
            drawSun(in: rect)
            drawPath(in: rect)
        }

        context.restoreGState()
    }

    private func setupView() {
        backgroundColor = .clear
        contentMode = .redraw
        isOpaque = false
    }

    private func drawSky(in rect: CGRect) {
        let skyRect = rect.insetBy(dx: 16, dy: 14)
        let path = UIBezierPath(roundedRect: skyRect, cornerRadius: 28)
        UIColor.hexString("#FFF8E4").setFill()
        path.fill()

        let glow = UIBezierPath(ovalIn: CGRect(x: rect.maxX - 110, y: 26, width: 56, height: 56))
        SGColor.flower.withAlphaComponent(0.38).setFill()
        glow.fill()
    }

    private func drawGround(in rect: CGRect) {
        let groundRect = CGRect(x: rect.midX - 92, y: rect.maxY - 70, width: 184, height: 30)
        let ground = UIBezierPath(ovalIn: groundRect)
        UIColor.hexString("#CBA26F").withAlphaComponent(0.34).setFill()
        ground.fill()

        let shadow = UIBezierPath(ovalIn: groundRect.insetBy(dx: 22, dy: 8).offsetBy(dx: 0, dy: 7))
        UIColor.hexString("#31412B").withAlphaComponent(0.09).setFill()
        shadow.fill()
    }

    private func drawSeed(in rect: CGRect) {
        let seedRect = CGRect(x: rect.midX - 18, y: rect.maxY - 88, width: 36, height: 24)
        let seed = UIBezierPath(ovalIn: seedRect)
        UIColor.hexString("#A97843").setFill()
        seed.fill()

        drawLeaf(center: CGPoint(x: rect.midX + 8, y: rect.maxY - 93), size: 13, angle: -0.6, color: SGColor.primary)
    }

    private func drawSprout(in rect: CGRect, scale: CGFloat) {
        let baseY = rect.maxY - 76
        let stemHeight = 70 * scale
        let stem = UIBezierPath()
        stem.move(to: CGPoint(x: rect.midX, y: baseY))
        stem.addCurve(
            to: CGPoint(x: rect.midX + 6, y: baseY - stemHeight),
            controlPoint1: CGPoint(x: rect.midX - 8, y: baseY - 24 * scale),
            controlPoint2: CGPoint(x: rect.midX + 8, y: baseY - 45 * scale)
        )
        SGColor.primaryDark.setStroke()
        stem.lineWidth = 5
        stem.lineCapStyle = .round
        stem.stroke()

        drawLeaf(center: CGPoint(x: rect.midX - 20 * scale, y: baseY - 38 * scale), size: 30 * scale, angle: -0.7, color: SGColor.primary)
        drawLeaf(center: CGPoint(x: rect.midX + 28 * scale, y: baseY - 50 * scale), size: 34 * scale, angle: 0.65, color: UIColor.hexString("#9EBD78"))
    }

    private func drawGardenBed(in rect: CGRect, flowers: Int, trees: Int) {
        let startX = rect.midX - CGFloat(flowers - 1) * 24 / 2
        for index in 0..<flowers {
            drawFlower(
                in: rect,
                xOffset: startX + CGFloat(index) * 24 - rect.midX,
                yOffset: CGFloat(index.isMultiple(of: 2) ? -42 : -52),
                size: 13
            )
        }

        for index in 0..<trees {
            let offset = CGFloat(index) * 56 - CGFloat(max(trees - 1, 0)) * 28
            drawTree(in: rect, xOffset: offset, height: 92 - CGFloat(index) * 8)
        }
    }

    private func drawForest(in rect: CGRect, treeCount: Int) {
        let spacing: CGFloat = 42
        let start = -CGFloat(treeCount - 1) * spacing / 2
        for index in 0..<treeCount {
            let xOffset = start + CGFloat(index) * spacing
            let height: CGFloat = index.isMultiple(of: 2) ? 112 : 92
            drawTree(in: rect, xOffset: xOffset, height: height)
        }
    }

    private func drawTree(in rect: CGRect, xOffset: CGFloat, height: CGFloat) {
        let base = CGPoint(x: rect.midX + xOffset, y: rect.maxY - 76)
        let trunk = UIBezierPath()
        trunk.move(to: base)
        trunk.addLine(to: CGPoint(x: base.x, y: base.y - height * 0.58))
        UIColor.hexString("#8E633B").setStroke()
        trunk.lineWidth = 8
        trunk.lineCapStyle = .round
        trunk.stroke()

        drawLeafCluster(in: rect, center: CGPoint(x: base.x, y: base.y - height * 0.72), size: height * 0.42)
    }

    private func drawLeafCluster(in rect: CGRect, yOffset: CGFloat, size: CGFloat) {
        drawLeafCluster(in: rect, center: CGPoint(x: rect.midX, y: rect.maxY - 86 + yOffset), size: size)
    }

    private func drawLeafCluster(in rect: CGRect, center: CGPoint, size: CGFloat) {
        let colors = [SGColor.primary, UIColor.hexString("#9EBD78"), SGColor.primaryDark]
        let offsets = [
            CGPoint(x: -size * 0.24, y: 0),
            CGPoint(x: size * 0.22, y: -size * 0.1),
            CGPoint(x: 0, y: -size * 0.28)
        ]

        for (index, offset) in offsets.enumerated() {
            let leafRect = CGRect(
                x: center.x + offset.x - size * 0.35,
                y: center.y + offset.y - size * 0.28,
                width: size * 0.7,
                height: size * 0.56
            )
            let leaf = UIBezierPath(ovalIn: leafRect)
            colors[index].withAlphaComponent(0.92).setFill()
            leaf.fill()
        }
    }

    private func drawFlower(in rect: CGRect, xOffset: CGFloat, yOffset: CGFloat, size: CGFloat) {
        let base = CGPoint(x: rect.midX + xOffset, y: rect.maxY - 76)
        let top = CGPoint(x: base.x, y: base.y + yOffset)

        let stem = UIBezierPath()
        stem.move(to: base)
        stem.addLine(to: top)
        SGColor.primaryDark.setStroke()
        stem.lineWidth = 3
        stem.lineCapStyle = .round
        stem.stroke()

        for angle in stride(from: 0.0, to: Double.pi * 2, by: Double.pi / 3) {
            let petalCenter = CGPoint(
                x: top.x + cos(angle) * Double(size * 0.72),
                y: top.y + sin(angle) * Double(size * 0.72)
            )
            let petal = UIBezierPath(ovalIn: CGRect(x: petalCenter.x - size * 0.38, y: petalCenter.y - size * 0.38, width: size * 0.76, height: size * 0.76))
            SGColor.flower.setFill()
            petal.fill()
        }

        let core = UIBezierPath(ovalIn: CGRect(x: top.x - size * 0.36, y: top.y - size * 0.36, width: size * 0.72, height: size * 0.72))
        UIColor.hexString("#E89B5C").setFill()
        core.fill()
    }

    private func drawLeaf(center: CGPoint, size: CGFloat, angle: CGFloat, color: UIColor) {
        let leaf = UIBezierPath(ovalIn: CGRect(x: center.x - size / 2, y: center.y - size / 3, width: size, height: size * 0.66))
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .rotated(by: angle)
            .translatedBy(x: -center.x, y: -center.y)
        leaf.apply(transform)
        color.setFill()
        leaf.fill()
    }

    private func drawPath(in rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.midX - 16, y: rect.maxY - 54))
        path.addCurve(
            to: CGPoint(x: rect.midX + 48, y: rect.maxY - 26),
            controlPoint1: CGPoint(x: rect.midX - 2, y: rect.maxY - 40),
            controlPoint2: CGPoint(x: rect.midX + 30, y: rect.maxY - 40)
        )
        UIColor.hexString("#DDBE8A").withAlphaComponent(0.58).setStroke()
        path.lineWidth = 12
        path.lineCapStyle = .round
        path.stroke()
    }

    private func drawSun(in rect: CGRect) {
        let sun = UIBezierPath(ovalIn: CGRect(x: rect.minX + 48, y: rect.minY + 34, width: 38, height: 38))
        SGColor.flower.withAlphaComponent(0.68).setFill()
        sun.fill()
    }
}
