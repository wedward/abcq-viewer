from PySide6.QtCore import QObject, QFileSystemWatcher, Signal, QTimer, Property
from PySide6.QtQml import  QmlNamedElement

QML_IMPORT_NAME = "RWatcher"
QML_IMPORT_MAJOR_VERSION = 1

@QmlNamedElement("RenderWatcher")
class RenderWatcher(QObject):

    reloadTriggered = Signal()
    reloadComplete = Signal()
    intervalChanged = Signal()
    watchPathChanged = Signal()
    listeningChanged = Signal()
    countingChanged = Signal()

    def __init__(self, parent=None,):
        super(RenderWatcher, self).__init__(parent)
        self._watcher = QFileSystemWatcher(self)
        self._timer = QTimer(self)
        self._timer.setInterval(50)
        self._timer.setSingleShot(True)
        self._watcher.fileChanged.connect(self.reloadTriggered)
        self._timer.timeout.connect(self.reloadComplete)
        self.pauseList = []
        self.isListening = True


    @Property(str, notify=watchPathChanged)
    def watchPath(self):
        if len( self._watcher.files() ) > 0 :
            return self._watcher.files()[0]
        else:
            return ""
    
    @watchPath.setter
    def watchPath(self, path):

        if len( self._watcher.files() ) > 0 :
            self._clearWatchlist()
        
        if len( path ) > 0:
            self._watcher.addPath(path) 
        self.watchPathChanged.emit()


    @Property(int, notify=intervalChanged)
    def interval(self):
        return self._timer.interval()
    
    @interval.setter
    def interval(self, msec):
        self._timer.setInterval(msec)
        self.intervalChanged.emit()
 

    @Property(bool, notify=listeningChanged)
    def listening(self):
        return self.isListening
    
    @listening.setter
    def listening(self, state):
        if state == False and self.isListening:
            self.pauseList = self._watcher.files()
            self._clearWatchlist()
        if state == True and len( self.pauseList ) > 0:
            self._watcher.addPaths(self.pauseList)
            self.pauseList=[]

        print(f"watch {self._watcher.files()} pause {self.pauseList}")

        self.isListening = len( self._watcher.files() ) > 0
        self.listeningChanged.emit()


    @Property(bool, notify=countingChanged)
    def counting(self):
        return self._timer.active()
    
    @counting.setter
    def counting(self, state):
        if state == True:
            self._timer.start()
        else:
            self._timer.stop()
        self.countingChanged.emit()

    def _clearWatchlist(self):
        if len( self._watcher.files() ) > 0:
            self._watcher.removePaths(self._watcher.files())
