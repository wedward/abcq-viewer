import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ABCQ


import QtQuick3D
import QtQuick3D.Helpers
import QtQuick3D.AssetUtils


import Qt.labs.platform
import QtCore

pragma ComponentBehavior: Bound
Item {
    id: root
    property string filePath
    property ApplicationWindow win
    property alias scn: scene
    signal ready()


    Rectangle{
        anchors.fill: parent
        z: -1
        color: "gray"
        opacity: win.opac
        visible: win.opac > 0
    }

    function zoom(amount, camState){

    }

    MouseArea {
        id: ma
        hoverEnabled: true
        z: 1000
        property real lastY
        property real lastX
        property bool lc: false

        property bool resume: false

        anchors.fill: parent

        onPressed: (mouse) => {
            // just in case it doesn't clear after resize
            win.winResizing = false

            lastY = mouse.y
            lastX = mouse.x

            resume = scene.updateAnim()

            if (mouse.buttons === Qt.LeftButton) lc = true

            if ((mouse.modifiers & Qt.AltModifier) && (mouse.modifiers & Qt.ControlModifier)) {
                win.startSystemMove()
            }
        }


        onPositionChanged: (mouse) => {


            if (lc ){
                var dx =  ( mouse.x - lastX ) * (Math.PI/180) /4
                var dy =  ( mouse.y - lastY ) * (Math.PI/180) /4
                if  (!mouse.modifiers ) {
                var qh, qv, qr
                    dx = -dx
                    qh = Qt.quaternion( Math.cos(dx/2), 0, 0, Math.sin(dx/2) )
                    qv = Qt.quaternion( Math.cos(dy/2), Math.sin(dy/2), 0, 0 )
                    qr = qh.times(qv)
                    scene.rot = qr.times( scene.rot )
                }

                else if  (mouse.modifiers & Qt.ControlModifier) {
                    dx = -dx
                    qh = Qt.quaternion( Math.cos(dx/2), 0, 0, Math.sin(dx/2) )
                    qv = Qt.quaternion( Math.cos(dy/2), 0, Math.sin(dy/2), 0 )
                    qr = qh.times(qv)
                    scene.rot= qr.times( scene.rot )
                }
                else if (mouse.modifiers & Qt.AltModifier) {
                    scene.camx = scene.camx - dx*200
                    scene.camy = scene.camy - dy*200
                }

                lastY = mouse.y
                lastX = mouse.x

            }


        }
        onReleased: {
            lc = false

            if (resume) {
                resume = false
                scene.startAnim()
            }
        }
        onCanceled: {
            lc = false
            // anim.start()
        }

        onWheel: (wheel) => {

            scene.mag +=  wheel.angleDelta.y/1000 * scene.mag

        }
    }

    function setQuality(qual=0){
        switch(qual){
            case 0:


            break;

        }
    }


    View3D{
        // property var live: layer.live

        id: v3d
        anchors.fill: parent
        camera: camOrtho
        importScene: scene
        z: 200
        environment: ExtendedSceneEnvironment {
            id: env
            fxaaEnabled: true
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.VeryHigh
            colorAdjustmentsEnabled: false
            ditheringEnabled: true
            temporalAAEnabled: true
            // specularAAEnabled: true
            backgroundMode: win.opac < 1 ? SceneEnvironment.Transparent : SceneEnvironment.Color
            clearColor: "gray"
            sharpnessAmount: 0.2



            depthOfFieldEnabled: false
            depthOfFieldFocusDistance: obj.longestDim * dofDist
            property real dofDist: 1.0
            onDofDistChanged: console.log(depthOfFieldFocusDistance)
            depthOfFieldBlurAmount: 4.0 * dofAmount
            property real dofAmount: 1.0
            depthOfFieldFocusRange: obj.longestDim/2 * dofRange
            property real dofRange: 1.0


        }
    }
    Node {
        visible: filePath.length > 0
        id: scene


        property alias rotx: obj.eulerRotation.x
        property alias roty: obj.eulerRotation.y
        property alias rotz: obj.eulerRotation.z
        property alias rot: obj.rotation
        property alias importScale: obj.importScale
        property alias zScale: obj.zScale
        property alias status: obj.status
        property alias longestDim: obj.longestDim

        property alias camOrtho: camOrtho

        property alias fov: camPer.fieldOfView
        property alias camPerY: camPer.y
        property alias camPer: camPer

        property alias lightRot: dLight.rotation
        property alias lightRot2: dLight2.rotation

        property alias lightBright: dLight.brightness
        property alias lightBright2: dLight2.brightness

        property alias lightSF: dLight.shadowFactor
        property alias lightSF2: dLight2.shadowFactor

        property alias dofRange: env.dofRange
        property alias dofAmount: env.dofAmount
        property alias dofEnabled: env.depthOfFieldEnabled
        property alias dofDist: env.dofDist


        property int shadowQual: Light.Hard
        property string shadowQualStr: shadowQual === Light.Hard ? "Hard" : "Soft"

        readonly property real defaultShadowBias: 5.0
        property real shadowBias: 5.0
        onShadowBiasChanged: shadowBias=Math.max(0.1,shadowBias)

        property alias activeCam: v3d.camera

        property bool normsOn : env.debugSettings.materialOverride === DebugSettings.Normals

        property real camx: 0
        property real camy: 0

        property real animSpeed: 1.0
        property string animAxis: "X"
        property real animDir: -1.0
        property bool animRunning: false




        // user set
        property real mag: 1.0

        // determined by window state
        property real stateMag: viewer.height / 480


        DirectionalLight {
            // visible: obj.ready
            id: dLight
            // ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
            brightness: 9
            eulerRotation.x: -90
            eulerRotation.y: 0

            shadowMapQuality: Light.ShadowMapQualityUltra
            softShadowQuality: scene.shadowQual
            castsShadow: true
            shadowFactor: 60
            shadowBias: scene.shadowBias
            shadowMapFar: camOrtho.clipFar

            //Note: PCF needs to be set in softShadowQuality for this property to have an effect.
            pcfFactor: 2.0

        }
        DirectionalLight {
            // visible: obj.ready
            id: dLight2
            // ambientColor: Qt.rgba(0.5, 0.5, 0.5, 1.0)
            brightness: 1
            eulerRotation.x: -90
            eulerRotation.y: 0

            shadowMapQuality: Light.ShadowMapQualityUltra
            softShadowQuality:  scene.shadowQual
            castsShadow: true
            shadowFactor: 60
            shadowBias: scene.shadowBias
            shadowMapFar: camOrtho.clipFar

            //Note: PCF needs to be set in softShadowQuality for this property to have an effect.
            pcfFactor: 2.0

        }

        Model{
            visible: !obj.ready
            // scale: obj.scale
            source: "#Cube"
            materials: [
                PrincipledMaterial {
                    baseColor: "#41cd52"
                    metalness: 0.0
                    roughness: 0.1
                    opacity: 1.0
                }
            ]

            // onVisibleChanged: {
            //     if (visible) {
            //         scene.startAnim()
            //     }
            //     else {
            //         scene.pauseAnim()
            //     }
            // }

            rotation: obj.rotation

            // Model{
            //     source: "#Cone"
            //     materials: [
            //         PrincipledMaterial {
            //             baseColor: "#41cd52"
            //             metalness: 0.0
            //             roughness: 0.4
            //             opacity: 1.0
            //         }
            //     ]
            //     x: 200

            // }

        }




        RuntimeLoader {
            id: obj

            property bool ready: status == RuntimeLoader.Success
            visible: true

            onReadyChanged: if (ready) root.ready()

            property real zScale: 1.0
            property real maxL: 1 //set onBoundsChanged
            // property real viewerSize: viewer.width //Math.min(viewer.width,viewer.height)
            property real importScale: 240 / maxL
            property real longestDim: maxL*scale.length()

            scale: Qt.vector3d(importScale*zScale, importScale*zScale, importScale*zScale, )

            source: root.filePath
            onBoundsChanged:{


                maxL = bounds.maximum.length()
            }


            onStatusChanged:  {
                if (status == RuntimeLoader.Success ){
                    console.log( ":) "+errorString )

                }
                else if (status == RuntimeLoader.Empty) {
                    console.log(":| " + errorString )
                }
                else {
                    console.log(":( " + errorString)
                }
            }



            SequentialAnimation{
                id: anim
                running: scene.animRunning
                loops: Animation.Infinite
                property quaternion q0
                property quaternion q1
                property quaternion q2
                property quaternion q3


                function getCurRot() {

                    // let q = obj.rotation
                    let angRad = 90 * Math.PI / 180
                    let sina = Math.sin(angRad/2)
                    let cosa = Math.cos(angRad/2) * scene.animDir

                    var x = 0, y = 0, z = 0

                    switch (scene.animAxis) {
                    case "X":
                        x = sina
                        break;
                    case "Y":
                        y = sina
                        break;
                    case "Z":
                        z = sina
                        break;
                    }

                    let qrot = Qt.quaternion( cosa, x, y, z )
                    q0 = obj.rotation
                    q1 = qrot.times(q0)
                    q2 = qrot.times(q1)
                    q3 = qrot.times(q2)


                }

                onStarted: getCurRot()
                QuaternionAnimation{target: obj; property: "rotation"; duration:2500*scene.animSpeed;from: anim.q0;to: anim.q1}
                QuaternionAnimation{target: obj; property: "rotation"; duration:2500*scene.animSpeed;from: anim.q1;to: anim.q2}
                QuaternionAnimation{target: obj; property: "rotation"; duration:2500*scene.animSpeed;from: anim.q2;to: anim.q3}
                QuaternionAnimation{target: obj; property: "rotation"; duration:2500*scene.animSpeed;from: anim.q3;to: anim.q0}
            }

        }

        OrthographicCamera {
            id: camOrtho
            y: 600+obj.longestDim
            x: scene.camx
            z: scene.camy
            eulerRotation.x: -90
            // frustumCullingEnabled: false

            clipFar: obj.longestDim * obj.longestDim
            clipNear: -clipFar

            horizontalMagnification: verticalMagnification
            verticalMagnification: scene.mag * scene.stateMag
            levelOfDetailBias: 0

        }

        PerspectiveCamera{
            id: camPer

            y: obj.longestDim*2
            x: scene.camx
            z: scene.camy

            // close enough 🤷
            fieldOfView: Math.min ( 35 / scene.mag , 179 )

            eulerRotation.x: -90
            frustumCullingEnabled: false
            clipFar: y*y

        }

        function increaseLightBright(amt=0.1, max=50, min=0){
            scene.lightBright = Math.max(min, Math.min(max, scene.lightBright+amt))
        }
        function increaseLightBright2(amt=0.1, max=50, min=0){
            scene.lightBright2 = Math.max(min, Math.min(max, scene.lightBright2+amt))
        }

        function resetZoom(){
            mag = 1.0
        }

        function resetZDist() {
            camPerY = longestDim * 2
        }


        function increaseAnimSpeed(amt=0.1, min=0.1){
            var resume = updateAnim()
            animSpeed = Math.max(min, animSpeed+amt )
            if (resume) startAnim()
        }
        function resetAnimSpeed(){
            animSpeed = 1.0
        }

        function changeAnimDir(){
            var resume = updateAnim()
            animDir *= -1
            if (resume) startAnim()
        }

        function changeAnimAxis(axis=null){
            var resume = updateAnim()
            if (axis !== null) animAxis = axis
            else if (animAxis === "X") animAxis = "Z"
            else if (animAxis === "Z") animAxis = "Y"
            else animAxis = "X"
            if (resume) startAnim()
        }

        function startAnim(){
            animRunning = true
        }

        function pauseAnim(){
            animRunning = false
        }

        function toggleAnim(){
            if (!animRunning) startAnim()
            else updateAnim()
        }

        function toggleShadowQual() {
            if (shadowQual === Light.Hard) shadowQual = Light.PCF64
            else shadowQual = Light.Hard
        }

        function resetLightPan() {
            dLight.eulerRotation.x = -90
            dLight.eulerRotation.y = 0
        }

        function resetLightPan2() {
            dLight2.eulerRotation.x = -90
            dLight2.eulerRotation.y = 0
        }

        function toggleNorms() {
            if (normsOn) {
                env.debugSettings.materialOverride = DebugSettings.None

            } else {
                env.debugSettings.materialOverride = DebugSettings.Normals
            }
        }

        function swapCam() {

            if (v3d.camera === camOrtho) {
                v3d.camera = camPer
            }
            else {
                v3d.camera = camOrtho
            }

        }

        function updateAnim(pause=true) {

            if (animRunning && pause){
                animRunning = false
                return true
            }
            else if (animRunning) {
                return true
            }

            return false
        }

        function top() {
            var resume = updateAnim()
            rotx = 0
            roty = 0
            rotz = 0
            if (resume) startAnim()
        }

        function bottom() {
            var resume = updateAnim()
            rotx = 0
            roty = 0
            rotz = 180
            if (resume) startAnim()

        }

        function right() {
            var resume = updateAnim()
            rotx = 0
            roty = -90
            rotz = -90*3
            if (resume) startAnim()


        }

        function left() {
            var resume = updateAnim()
            rotx = 0
            roty = 90
            rotz = 90*3
            if (resume) startAnim()


        }

        function front() {
            var resume = updateAnim()
            rotx = 90
            roty = 180
            rotz = 0
            if (resume) startAnim()

        }

        function back() {
            var resume = updateAnim()
            rotx = -90
            roty = 0
            rotz = 0
            if (resume) startAnim()

        }
        function resetShadowBias() {
            scene.shadowBias = scene.defaultShadowBias
        }

    }
}

