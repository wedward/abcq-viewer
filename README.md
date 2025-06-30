# ABCQ Viewer
A Build123d and CadQuery Viewer

![Screenshot 2025-06-18 193132](https://github.com/user-attachments/assets/9638ff2b-97c2-421b-8644-cc5739449e5f)
<br><br>
## Features
- Supports .GLTF, .STL, and .OBJ file formats. 
- Automatic file reload.
- Tranparent windows.
- Simple rotation animations.
<br><br>
## Languages
Backend:
- Either, C++ (Qt6) for speed and stability,
- Or, Python (PySide6) for easy hacking.

Frontend:
- Qt/QML Quick3D.

No other dependencies.
<br><br>
## Getting Started
**Windows 10 or higher (64-bit)**

For pre-compiled binaries, you can either:
- Use [ABCQ-Installer 0.1.1.exe](https://github.com/wedward/abcq-viewer/releases/download/v0.1.1/ABCQ-Installer-0.1.1.exe) -- This copies the contents of `ABCQ-0.1.1.zip` to your home folder. It also creates a Start Menu shortcut and uninstaller executable. 
- Or, manually copy the contents of [ABCQ-0.1.1.zip](https://github.com/wedward/abcq-viewer/releases/download/v0.1.1/ABCQ-0.1.1.zip) to your hard drive.

Optional:
- Add ABCQ to your user PATH.

<br><br>
## Hello Box
GLTF are files recommended when designing with parametric CAD tools like CadQuery and Build123d.
<br><br>
### CadQuery
Let's create a box to display in CadQuery:
```py
from cadquery import *
box = Workplane().box(1,1,1)
assy = Assembly().add(box, color=Color('aliceblue'))
assy.export("C:/Users/UsErNaMe/output.glb")
```
By default, ABCQ will *watch* for `.\output.glb` on your home directory. You can also select the file to watch in the explorer on the left.
<br><br>
### Build123d
Great, let's do the same in Build123d:
```py
from build123d import *
box = Box(1,1,1)
box.color = Color('cornsilk1')
export_gltf(box, "C:/Users/uSerNaMe/output.glb", binary=True)
```
The view in ABCQ should automatically update when `.\output.glb` is overwritten. Try increasing the delay if there are issues loading the file.
You can also open supported files from your computer's file browser or command shell.

<br><br>
## Hello Button
Almost any feature can easily be tweaked with ABCQ. Let's add a simple toolbar with directional view buttons to our viewer: <br><br>
Add the following to Line 22 in `C:\Users\uSeRnAmE\ABCQ\prototype\qml\Viewer.qml`:
```qml
    RowLayout{
        anchors.top: parent.top
        height: win.menuBar.height
        width: parent.width
        visible: win.viewMenus === true
        z: ma.z + 1
        spacing: 0

        ControlButton{
            Layout.fillHeight: true
            Layout.fillWidth: true
            onPressed: scene.top()
            text: "TOP"
            fontSize: win.main.fontL
        }
        ControlButton{
            Layout.fillHeight: true
            Layout.fillWidth: true
            onPressed: scene.bottom()
            text: "BOTTOM"
            fontSize: win.main.fontL
        }
    }
```
View your changes with prototype.py. <br>
Pressing Python > Launch prototype.py will:
- Create a virtual environment in the install directory
- Install PySide6 through pip
- Launch the prototype backend

![image](https://github.com/user-attachments/assets/5e4cf360-6c91-4aff-90aa-b4568a52e949) 
