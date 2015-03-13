package ru.kokorin.util {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.core.mx_internal;
import mx.logging.targets.LineFormattedTarget;

use namespace mx_internal;

public class FileTarget extends LineFormattedTarget {
    private var stream:FileStream;
    private var closeTimeout:uint = 0;

    public function FileTarget() {
        super();
    }

    override mx_internal function internalLog(message:String):void {
        if (!stream) {
            stream = new FileStream();
            const file:File = File.applicationStorageDirectory.resolvePath("log.txt")
            if (file.exists && file.size > 1000*1000) {
                file.deleteFile();
            }
            stream.open(file, FileMode.APPEND);
        }

        stream.writeUTFBytes(message);
        stream.writeUTFBytes("\n");

        if (closeTimeout != 0) {
            clearTimeout(closeTimeout);
        }
        setTimeout(closeStream, 10*1000);
    }

    private function closeStream():void {
        if (stream) {
            stream.close();
            stream = null;
        }
        closeTimeout = 0;
    }
}
}
