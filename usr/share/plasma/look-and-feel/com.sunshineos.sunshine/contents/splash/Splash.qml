// Sunshine OS start-up animation, the same one the website plays: the pixel-art logo builds up (intro sheet), the strip opens through
// its middle and "SUNSHINE OS" is written into it in pixel letters, a half circle of rays appears around the A, then the 10 s idle loop
// repeats until the session is ready. Ported from the page's script; the sheets are the page's own (images/intro-sheet.png, loop-sheet.png).
import QtQuick 2.15

Rectangle {
    id: root
    color: "#0b1020"
    property int stage
    property real t: 0                       // seconds since the splash appeared
    readonly property real t0: Date.now()
    readonly property int fps: 20
    readonly property int introFrames: 180
    readonly property int loopFrames: 200
    readonly property int cols: 12
    readonly property int cellPx: 80          // one frame in the sheets
    readonly property int cropX: 9
    readonly property int cropY: 3
    readonly property int gridW: 64           // logo cells shown
    readonly property int gridH: 76
    readonly property int mid: 32
    readonly property int band: 10
    readonly property real cutAt: 4.7
    readonly property real cutDur: 1.1
    readonly property real introDur: introFrames / fps
    readonly property int c: Math.max(3, Math.floor(Math.min(height * 0.62 / gridH, width * 0.5 / gridW)))   // screen pixels per logo cell
    readonly property var pal: ["#fff2b8", "#ffd25c", "#ffb12e", "#ffb12e", "#ff8a3a", "#ff8a3a", "#d9531e"]

    function ease(x) { x = Math.min(1, Math.max(0, x)); return x < 0.5 ? 4 * x * x * x : 1 - Math.pow(-2 * x + 2, 3) / 2 }
    readonly property int cutRows: Math.round(band * ease((t - cutAt) / cutDur))
    readonly property bool inIntro: t < introDur
    readonly property int frame: inIntro ? Math.min(introFrames - 1, Math.floor(t * fps)) : Math.floor((t - introDur) * fps) % loopFrames

    Timer {
        interval: 50; running: true; repeat: true
        onTriggered: root.t = (Date.now() - root.t0) / 1000
    }

    Item {
        id: logo
        width: root.gridW * root.c; height: root.gridH * root.c
        anchors.horizontalCenter: parent.horizontalCenter
        y: Math.round(parent.height * 0.47 - height / 2)

        Canvas {        // halo: nine pixel rays on a half circle, on the logo's cell grid
            id: halo
            x: -20 * root.c; y: -20 * root.c; width: 104 * root.c; height: 76 * root.c
            renderTarget: Canvas.Image
            readonly property var ang: [180, 157.5, 135, 112.5, 90, 67.5, 45, 22.5, 0]
            function out(x) { x = Math.min(1, Math.max(0, x)); return 1 - Math.pow(1 - x, 2.2) }
            onPaint: {
                var ctx = getContext("2d"), c = root.c, t = root.t
                ctx.clearRect(0, 0, width, height)
                if (t < 4.3) return
                var W = 104, H = 76, CX = 51, CY = 70, len = 7, r0 = 41
                var col = [root.pal[0], root.pal[1], root.pal[2], root.pal[4]]
                for (var i = 0; i < 9; i++) {
                    var d = Math.abs(i - 4), g = out((t - 4.5 - 0.16 * d) / 0.3)
                    if (g <= 0) continue
                    var tt = t - 4.5 - 1.9, off = tt > 0 ? Math.round(2 * Math.pow(Math.sin(Math.PI * (tt - 0.28 * d) / 3.2), 2)) : 0
                    var th = ang[i] * Math.PI / 180, dx = Math.cos(th), dy = -Math.sin(th), px = Math.sin(th), py = Math.cos(th), seen = {}
                    for (var s = 0; s <= len * g; s += 0.5) {
                        var hw = 1.05 * (1 - s / len) + 0.3, f = s / len
                        ctx.fillStyle = f < 0.35 ? col[2] : f < 0.7 ? col[1] : col[0]
                        for (var u = -hw; u <= hw; u += 0.5) {
                            var x = Math.floor(CX + dx * (r0 + off + s) + px * u), y = Math.floor(CY + dy * (r0 + off + s) + py * u), k = y * W + x
                            if (x < 0 || y < 0 || x >= W || y >= H || seen[k]) continue
                            seen[k] = 1; ctx.fillRect(x * c, y * c, c, c)
                        }
                    }
                }
            }
        }
        Image {
            id: intro
            visible: root.inIntro
            anchors.fill: parent
            source: "images/intro-sheet.png"
            smooth: false; mipmap: false; cache: true
            sourceClipRect: Qt.rect((root.frame % root.cols) * root.cellPx + root.cropX, Math.floor(root.frame / root.cols) * root.cellPx + root.cropY, root.gridW, root.gridH)
        }
        Image {
            id: loopImg
            visible: !root.inIntro
            anchors.fill: parent
            source: "images/loop-sheet.png"
            smooth: false; mipmap: false; cache: true
            sourceClipRect: Qt.rect((root.frame % root.cols) * root.cellPx + root.cropX, Math.floor(root.frame / root.cols) * root.cellPx + root.cropY, root.gridW, root.gridH)
        }
        Rectangle {     // the strip cut through the middle of the logo
            visible: root.cutRows > 0
            x: 0; width: parent.width
            height: root.cutRows * root.c
            y: Math.floor(root.mid - root.cutRows / 2) * root.c
            color: root.color
            Rectangle { width: parent.width; height: 1; color: "#ffb12e"; opacity: 0.7 }
            Rectangle { y: parent.height - 1; width: parent.width; height: 1; color: "#ffb12e"; opacity: 0.7 }
        }
        Canvas {        // "SUNSHINE OS" in 5x7 pixel letters, written into the strip
            id: word
            readonly property string text: "SUNSHINE OS"
            readonly property var glyph: ({
                S: [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
                U: ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
                N: ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
                H: ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
                I: ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "#####"],
                E: ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
                O: [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."]
            })
            readonly property int cols: text.length * 6 - 1
            readonly property int p: Math.max(3, Math.floor(logo.width * 0.94 / cols))
            width: cols * p; height: 7 * p
            x: Math.round((logo.width - width) / 2); y: Math.round(root.mid * root.c - height / 2)
            visible: root.t > 5.8
            property var cells: []
            function hash(i, j) { var h = (i * 374761393 + j * 668265263) ^ 0x5bd1e995; h = (h ^ (h >>> 13)) * 1274126177; return ((h ^ (h >>> 16)) >>> 0) / 4294967295 }
            Component.onCompleted: {
                var l = []
                for (var k = 0; k < text.length; k++) {
                    var g = glyph[text[k]]; if (!g) continue
                    for (var r = 0; r < 7; r++) for (var c = 0; c < 5; c++) if (g[r][c] === "#")
                        l.push({ c: k * 6 + c, r: r, d: (k * 6 + c) / cols * 0.85 + hash(k * 6 + c, r) * 0.5 })
                }
                cells = l
            }
            onPaint: {
                var ctx = getContext("2d"), t = root.t
                ctx.clearRect(0, 0, width, height)
                var sz = Math.max(2, Math.round(p * 0.8)), off = Math.round((p - sz) / 2)
                var band = [root.pal[0], root.pal[1], root.pal[2], root.pal[3], root.pal[4], root.pal[5], root.pal[6]]
                for (var i = 0; i < cells.length; i++) {
                    var q = cells[i], k = Math.min(1, Math.max(0, (t - 5.85 - q.d) / 0.4)); if (k <= 0) continue
                    k = Math.round(k * 3) / 3
                    ctx.globalAlpha = k; ctx.fillStyle = band[q.r]; ctx.fillRect(q.c * p + off, q.r * p + off, sz, sz)
                    var gl = k < 1 ? 0 : Math.max(0, Math.sin(t * 0.8 - q.c * 0.3) - 0.94) * 14
                    if (gl > 0.2) { ctx.globalAlpha = Math.min(0.55, gl * 0.5); ctx.fillStyle = "#f3e6d0"; ctx.fillRect(q.c * p + off, q.r * p + off, sz, sz) }
                }
                ctx.globalAlpha = 1
            }
        }
    }
    Timer { interval: 50; running: true; repeat: true; onTriggered: { halo.requestPaint(); if (word.visible) word.requestPaint() } }

    Rectangle {      // progress: orange to gold
        id: track
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom; anchors.bottomMargin: parent.height * 0.08
        width: Math.min(parent.width * 0.3, 420); height: 4; radius: 2; color: "#24202a"
        Rectangle {
            height: parent.height; radius: 2
            width: parent.width * Math.min(1, root.stage / 6)
            gradient: Gradient { orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#e87932" } GradientStop { position: 0.6; color: "#f5a442" } GradientStop { position: 1.0; color: "#ffd27a" } }
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
        }
    }
}
