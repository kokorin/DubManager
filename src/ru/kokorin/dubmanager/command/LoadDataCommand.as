package ru.kokorin.dubmanager.command {
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.logging.ILogger;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Data;
import ru.kokorin.util.LogUtil;

public class LoadDataCommand {
    public var aStream:AStream;

    private static const LOGGER:ILogger = LogUtil.getLogger(LoadDataCommand);

    public function execute(event:Event):Data {
        var result:Data = null;
        try {
            const xmlFile:File = File.applicationStorageDirectory.resolvePath("data.xml");
            if (xmlFile.exists && xmlFile.size > 10) {
                LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
                const fileStream:FileStream = new FileStream();
                fileStream.open(xmlFile, FileMode.READ);
                const xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                fileStream.close();
                const xml:XML = new XML(xmlString);

                result = aStream.fromXML(xml) as Data;
            }
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }

        if (!result) {
            result = new Data();
        }
        return result;
    }
}
}
