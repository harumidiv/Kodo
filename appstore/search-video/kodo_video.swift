// 検索結果用動画（3:2）: 闇に浮かぶ人の輪郭と、胸で脈打つ心臓。文字なし・ループ。
// usage: kodo_video <human_1.png（同じ並びの human_2〜4 も読む）> <out.mp4|out.mov> <width> <height> [--stills <dir>]
import AppKit
import AVFoundation
import CoreImage

let args = CommandLine.arguments
let srcPath = args[1], outPath = args[2]
let W = Int(args[3])!, H = Int(args[4])!
let stillsDir: String? = args.firstIndex(of: "--stills").map { args[$0 + 1] }
let k = Double(W) / 3840.0           // 3840基準で組んで、1920でも同じ構図にする

let fps = 30
let beats = 12
let beatT = 10.0 / Double(beats)      // 72bpm, 10秒で12拍 → ループの継ぎ目なし
let duration = Double(beats) * beatT
let frameCount = Int(duration * Double(fps))

// ---- 素材: 輪郭だけ取り出す（赤い心臓は消して、自前で描く）
let srcPaths = (1...4).map { srcPath.replacingOccurrences(of: "human_1", with: "human_\($0)") }
let srcReps = srcPaths.map { NSBitmapImageRep(data: NSImage(contentsOfFile: $0)!.tiffRepresentation!)! }
let sw = srcReps[0].pixelsWide, sh = srcReps[0].pixelsHigh
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
func makeCtx(_ w: Int, _ h: Int) -> CGContext {
    CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: cs,
              bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
}
func extractOutline(_ srcRep: NSBitmapImageRep) -> (CGImage, CGImage) {
let outlineCtx = makeCtx(sw, sh)
let heartCtx = makeCtx(sw, sh)   // アプリの絵の赤い心臓だけ
outlineCtx.draw(srcRep.cgImage!, in: CGRect(x: 0, y: 0, width: sw, height: sh))
do {
    let p = outlineCtx.data!.bindMemory(to: UInt8.self, capacity: outlineCtx.bytesPerRow * sh)
    let hp = heartCtx.data!.bindMemory(to: UInt8.self, capacity: heartCtx.bytesPerRow * sh)
    for y in 0..<sh { for x in 0..<sw {
        let i = y * outlineCtx.bytesPerRow + x * 4   // BGRA premultiplied
        let b = Int(p[i]), g = Int(p[i+1]), r = Int(p[i+2]), a = Int(p[i+3])
        // 輪郭は白（premultiplied で b == a）。心臓は赤なので b が a よりずっと小さい
        if a > 0 && b * 100 < a * 85 { for o in 0..<4 { hp[i + o] = p[i + o] }; p[i] = 0; p[i+1] = 0; p[i+2] = 0; p[i+3] = 0 }
        else if a > 0 { p[i] = UInt8(a); p[i+1] = UInt8(a); p[i+2] = UInt8(a) } // 純白に
    }}
}
return (outlineCtx.makeImage()!, heartCtx.makeImage()!)
}

// 輪郭のにじみ（光の滲み）を事前に作る
let ciCtx = CIContext()
func blurred(_ img: CGImage, _ r: Double) -> CGImage {
    let ci = CIImage(cgImage: img).clampedToExtent().applyingGaussianBlur(sigma: r)
        .cropped(to: CGRect(x: 0, y: 0, width: img.width, height: img.height))
    return ciCtx.createCGImage(ci, from: ci.extent)!
}
// アプリと同じく、描き直した4枚を 1→2→3→4→3→2 の順に1拍で切り替えて、線をぐにゃぐにゃさせる
let extracted = srcReps.map { extractOutline($0) }
let outlineFrames = extracted.map { $0.0 }
let heartFrames = extracted.map { $0.1 }
let outlineGlows = outlineFrames.map { blurred($0, 6) }
let paraparaOrder = [0, 1, 2, 3, 2, 1]

// ---- 構図（3840x2560基準、左上原点）
// 検索結果で実際に見える範囲 ≒ (1037, 765, 1766x822) の中心に心臓を置く
let heartSrc = CGPoint(x: 510.7, y: 326.6)        // 素材内の心臓の中心
let scale = 2.9 * k
let heartPos = CGPoint(x: 1920 * k, y: 1150 * k)
let figRect = CGRect(x: heartPos.x - heartSrc.x * scale, y: heartPos.y - heartSrc.y * scale,
                     width: Double(sw) * scale, height: Double(sh) * scale)
// こちらを向いて立っているので、本人の左胸＝画面の右。アプリの絵は体の中央（x≈511）なので右へずらす
// 胸の幅は素材で約190px（x 420〜612、中心 516）。心臓は中心から約1/7 左胸側に置く
// アプリの心臓は大きく広がるコマ（半径約50px）があり、そのままずらすと右腕の線に重なるので、0.75倍に縮める
let heartShiftSrc = 22.0
let heartScale = 0.75
let heartAt = CGPoint(x: heartPos.x + (512 - heartSrc.x + heartShiftSrc) * scale, y: heartPos.y + (322 - heartSrc.y) * scale)

// ---- 鼓動の波形（ドクン・ドクン）
func pulse(_ p: Double, _ a: Double) -> Double { p <= 0 ? 0 : (p / a) * exp(1 - p / a) }
func beatEnv(_ t: Double) -> Double {
    var v = 0.0
    for j in -1...1 {               // 前後の拍もみて、継ぎ目でも途切れないように
        let p = (t.truncatingRemainder(dividingBy: beatT)) - Double(j) * beatT
        v += pulse(p, 0.055) + 0.55 * pulse(p - 0.2, 0.06)
    }
    return min(v, 1.4)
}
// 心電図の形（1拍ぶん、位相0..1）
func ecg(_ ph: Double) -> Double {
    let t = ph * beatT
    func g(_ c: Double, _ w: Double, _ a: Double) -> Double { a * exp(-pow((t - c) / w, 2)) }
    return g(-0.12, 0.035, 0.12) - g(-0.025, 0.008, 0.18) + g(0.0, 0.011, 1.0) - g(0.028, 0.01, 0.32)
         + g(0.26, 0.05, 0.22) + g(beatT - 0.12, 0.035, 0.12) - g(beatT - 0.025, 0.008, 0.18)
}

func color(_ r: Double, _ g: Double, _ b: Double, _ a: Double) -> CGColor { CGColor(srgbRed: r, green: g, blue: b, alpha: a) }
func radial(_ c: CGContext, _ center: CGPoint, _ r0: Double, _ r1: Double, _ c0: CGColor, _ c1: CGColor) {
    // 直線で減らすと縁に輪が見えるので、なめらかに減らす（smoothstep）
    let a0 = c0.components!, a1 = c1.components!
    let n = 12
    var cols: [CGColor] = [], locs: [CGFloat] = []
    for i in 0...n {
        let x = Double(i) / Double(n), m = x * x * (3 - 2 * x)
        cols.append(color(a0[0] + (a1[0] - a0[0]) * m, a0[1] + (a1[1] - a0[1]) * m,
                          a0[2] + (a1[2] - a0[2]) * m, a0[3] + (a1[3] - a0[3]) * m))
        locs.append(x)
    }
    let g = CGGradient(colorsSpace: cs, colors: cols as CFArray, locations: locs)!
    c.drawRadialGradient(g, startCenter: center, startRadius: r0, endCenter: center, endRadius: r1, options: [])
}

// フィルムの粒子（数枚を使い回す）
let grainTiles: [CGImage] = (0..<6).map { _ in
    let n = 512, gc = makeCtx(n, n)
    let p = gc.data!.bindMemory(to: UInt8.self, capacity: gc.bytesPerRow * n)
    for y in 0..<n { for x in 0..<n {
        let v = UInt8.random(in: 0...255), a: UInt8 = 14
        let pv = UInt8(Int(v) * Int(a) / 255)
        let i = y * gc.bytesPerRow + x * 4
        p[i] = pv; p[i+1] = pv; p[i+2] = pv; p[i+3] = a
    }}
    return gc.makeImage()!
}

func drawUp(_ c: CGContext, _ img: CGImage, _ r: CGRect) {   // 左上原点の中で正立させて描く
    c.saveGState(); c.translateBy(x: 0, y: r.maxY + r.minY); c.scaleBy(x: 1, y: -1); c.draw(img, in: r); c.restoreGState()
}
// ---- 1コマ描く
func draw(_ c: CGContext, t: Double, frame: Int) {
    c.saveGState()
    c.translateBy(x: 0, y: Double(H)); c.scaleBy(x: 1, y: -1)   // 左上原点に
    c.interpolationQuality = .high
    let e = beatEnv(t)
    let ph = t.truncatingRemainder(dividingBy: beatT) / beatT
    let fi = paraparaOrder[min(paraparaOrder.count - 1, Int(ph * Double(paraparaOrder.count)))]
    let outline = outlineFrames[fi], outlineGlow = outlineGlows[fi], heartImg = heartFrames[fi]

    // 背景: ほぼ黒、心臓のあたりだけ深い赤が呼吸する
    c.setFillColor(color(0.012, 0.010, 0.012, 1)); c.fill(CGRect(x: 0, y: 0, width: W, height: H))
    radial(c, heartAt, 0, 1600 * k, color(0.20, 0.0, 0.02, 0.03 + 0.05 * e), color(0, 0, 0, 0))

    // カメラがわずかに揺れる（鼓動で前に押される）
    c.saveGState()
    let z = 1 + 0.006 * e
    c.translateBy(x: heartPos.x, y: heartPos.y); c.scaleBy(x: z, y: z); c.translateBy(x: -heartPos.x, y: -heartPos.y)

    // 心電図: 胸の高さを左から右へ掃引。4往復で10秒
    do {
        let sweepT = duration / 4, v = Double(W) / sweepT
        let headX = (t.truncatingRemainder(dividingBy: sweepT)) * v
        let baseY = heartPos.y, amp = 210 * k, tail = 0.9  // 秒
        c.setLineCap(.round); c.setLineJoin(.round)
        var x = headX - tail * v * 1.6
        let step = 6 * k
        var prev: CGPoint? = nil
        while x <= headX {
            let age = (headX - x) / v
            let tx = t - age
            let ph = (tx.truncatingRemainder(dividingBy: beatT) + beatT).truncatingRemainder(dividingBy: beatT) / beatT
            let pt = CGPoint(x: x < 0 ? x + Double(W) : x, y: baseY - amp * ecg(ph))
            if let pv = prev, abs(pt.x - pv.x) < 100 * k {
                let a = exp(-age / tail * 2.2)
                c.setStrokeColor(color(1, 0.16, 0.18, 0.10 * a)); c.setLineWidth(14 * k)
                c.strokeLineSegments(between: [pv, pt])
                c.setStrokeColor(color(1, 0.30, 0.30, 0.42 * a)); c.setLineWidth(3.2 * k)
                c.strokeLineSegments(between: [pv, pt])
            }
            prev = pt; x += step
        }
        // 掃引の先端の小さな光
        let hph = (t.truncatingRemainder(dividingBy: beatT)) / beatT
        let hp = CGPoint(x: headX, y: baseY - amp * ecg(hph))
        radial(c, hp, 0, 40 * k, color(1, 0.55, 0.55, 0.55), color(1, 0.2, 0.2, 0))
    }

    // 人の輪郭: 普段はかすか。波紋が通ると照らされる
    c.beginTransparencyLayer(auxiliaryInfo: nil)
    c.saveGState()
    c.setAlpha(0.22 + 0.10 * e)
    drawUp(c, outlineGlow, figRect)
    c.setAlpha(0.34 + 0.12 * e)
    drawUp(c, outline, figRect)
    c.restoreGState()
    c.setBlendMode(.destinationIn)   // 心臓から離れるほど闇に溶ける
    let fade = CGGradient(colorsSpace: cs, colors: [color(1,1,1,1), color(1,1,1,0.75), color(1,1,1,0.0)] as CFArray, locations: [0, 0.45, 1])!
    c.drawRadialGradient(fade, startCenter: heartPos, startRadius: 0, endCenter: heartPos, endRadius: 1500 * k, options: [.drawsAfterEndLocation])
    c.endTransparencyLayer()

    // 心臓の光が胸の輪郭を照らす
    c.beginTransparencyLayer(auxiliaryInfo: nil)
    drawUp(c, outlineGlow, figRect)
    drawUp(c, outline, figRect)
    c.setBlendMode(.destinationIn)
    // destinationIn は描いた範囲にしか効かないので、円の外も透明で塗り切る
    let lit = CGGradient(colorsSpace: cs, colors: [color(1, 1, 1, 0.25 * min(e, 1)), color(1, 1, 1, 0)] as CFArray, locations: [0, 1])!
    c.drawRadialGradient(lit, startCenter: heartAt, startRadius: 0, endCenter: heartAt, endRadius: 420 * k, options: [.drawsAfterEndLocation])
    c.endTransparencyLayer()

    c.setBlendMode(.screen)
    // 心臓: 大きなにじみ → 芯
    let hr = 125 * k * (0.9 + 0.22 * e)
    radial(c, heartAt, 0, hr * 2.0, color(0.9, 0.02, 0.06, 0.10 * min(e, 1)), color(0.5, 0, 0, 0))
    c.setBlendMode(.normal)
    do {   // 素材の心臓の中心（約 512, 322）を左胸へ移し、そこを中心に縮める
        let srcC = CGPoint(x: figRect.minX + 512 * scale, y: figRect.minY + 322 * scale)
        let dstC = CGPoint(x: srcC.x + heartShiftSrc * scale, y: srcC.y)
        let r = CGRect(x: dstC.x - (srcC.x - figRect.minX) * heartScale, y: dstC.y - (srcC.y - figRect.minY) * heartScale,
                       width: figRect.width * heartScale, height: figRect.height * heartScale)
        drawUp(c, heartImg, r)
    }
    c.restoreGState()   // カメラ

    // 周辺減光（ビネット）
    let maxR = hypot(Double(W), Double(H)) / 2
    let center = CGPoint(x: Double(W) / 2, y: heartPos.y)
    let vg = CGGradient(colorsSpace: cs, colors: [color(0, 0, 0, 0), color(0, 0, 0, 0), color(0, 0, 0, 0.9)] as CFArray,
                        locations: [0, 0.35, 1])!
    c.drawRadialGradient(vg, startCenter: center, startRadius: 0, endCenter: center, endRadius: maxR * 1.05,
                         options: [.drawsAfterEndLocation])

    // 粒子
    let tile = grainTiles[frame % grainTiles.count]
    let ts = 512.0 * max(1, k * 1.0)
    var yy = -Double(frame * 37 % 512) * k
    while yy < Double(H) { var xx = -Double(frame * 91 % 512) * k
        while xx < Double(W) { c.draw(tile, in: CGRect(x: xx, y: yy, width: ts, height: ts)); xx += ts }
        yy += ts }
    c.restoreGState()
}

// ---- 確認用コマ
if let dir = stillsDir {
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    for (name, t) in [("00_rest", 0.6), ("01_lub", 0.055), ("02_dub", 0.26), ("03_frame3", 0.45), ("04_sweep", 1.9)] {
        let c = makeCtx(W, H)
        draw(c, t: t, frame: Int(t * 30))
        // セーフエリア（黄）と実際に見える範囲（水色）
        c.saveGState(); c.translateBy(x: 0, y: Double(H)); c.scaleBy(x: 1, y: -1)
        c.setLineWidth(4 * k)
        c.setStrokeColor(color(1, 0.9, 0, 0.8)); c.stroke(CGRect(x: 836 * k, y: 765 * k, width: 2168 * k, height: 1030 * k))
        c.setStrokeColor(color(0, 0.8, 1, 0.8)); c.stroke(CGRect(x: 0.27 * Double(W), y: 0.17 * Double(H), width: 0.46 * Double(W), height: 0.45 * Double(H)))
        c.restoreGState()
        let rep = NSBitmapImageRep(cgImage: c.makeImage()!)
        try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
    }
    print("stills -> \(dir)")
    exit(0)
}

// ---- 書き出し
let url = URL(fileURLWithPath: outPath)
try? FileManager.default.removeItem(at: url)
let useHEVC = W * H > 4096 * 2304 || ProcessInfo.processInfo.environment["HEVC"] == "1"
let writer = try! AVAssetWriter(outputURL: url, fileType: outPath.hasSuffix(".mov") ? .mov : .mp4)
var comp: [String: Any] = [AVVideoAverageBitRateKey: Int(Double(W * H) * 4.0),
                           AVVideoExpectedSourceFrameRateKey: fps, AVVideoMaxKeyFrameIntervalKey: fps]
if !useHEVC { comp[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel }
let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
    AVVideoCodecKey: useHEVC ? AVVideoCodecType.hevc : AVVideoCodecType.h264,
    AVVideoWidthKey: W, AVVideoHeightKey: H,
    AVVideoColorPropertiesKey: [AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                                AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2],
    AVVideoCompressionPropertiesKey: comp])
input.expectsMediaDataInRealTime = false
let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
    kCVPixelBufferWidthKey as String: W, kCVPixelBufferHeightKey as String: H])
writer.add(input)
guard writer.startWriting() else { print("startWriting failed:", writer.error as Any); exit(1) }
writer.startSession(atSourceTime: .zero)
for f in 0..<frameCount {
    while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.005) }
    var pb: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
    CVPixelBufferLockBaseAddress(pb!, [])
    let c = CGContext(data: CVPixelBufferGetBaseAddress(pb!), width: W, height: H, bitsPerComponent: 8,
                      bytesPerRow: CVPixelBufferGetBytesPerRow(pb!), space: cs,
                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
    draw(c, t: Double(f) / Double(fps), frame: f)
    CVPixelBufferUnlockBaseAddress(pb!, [])
    if !adaptor.append(pb!, withPresentationTime: CMTime(value: CMTimeValue(f), timescale: CMTimeScale(fps))) {
        print("append failed:", writer.error as Any); exit(1)
    }
    if f % 30 == 0 { print("frame \(f)/\(frameCount)") }
}
input.markAsFinished()
let sem = DispatchSemaphore(value: 0)
writer.finishWriting { sem.signal() }
sem.wait()
print(writer.status == .completed ? "done -> \(outPath) (\(useHEVC ? "HEVC" : "H.264"))" : "failed: \(String(describing: writer.error))")
