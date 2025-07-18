# ABCQ Viewer
A Build123d and CadQuery Viewer

![Screenshot 2025-06-18 193132](https://github.com/user-attachments/assets/9638ff2b-97c2-421b-8644-cc5739449e5f)
<br><br>
## Features
- Supports .GLTF, .STL, .OBJ, and .BREP (experimental) file formats. 
- Automatic file reload.
- Tranparent windows.
- Simple rotation animations.
<br><br>

## Getting Started
**Windows 10 or higher (64-bit)**

Use the portable binaries:
- Copy the contents of [ABCQ-0.2.2-portable.zip](https://github.com/wedward/abcq-viewer/releases/download/v0.2.2/ABCQ-Viewer-0.2.2-portable.zip) to your hard drive.
- Launch `abcq.exe`

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


