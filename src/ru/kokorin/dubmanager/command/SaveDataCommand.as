package ru.kokorin.dubmanager.command {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.event.AnimeEvent;

public class SaveDataCommand extends BaseCommand {
    public var aStream:AStream;
    public var callback:Function;

    public function execute(event:AnimeEvent):void {
        try {
            LOGGER.debug("Saving {0} items", event.animeList.length);
            const xml:XML = aStream.toXML(event.animeList);
            const xmlFile:File = File.applicationStorageDirectory.resolvePath("data.xml");
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.WRITE);
            fileStream.writeUTFBytes(xml.toXMLString());
            fileStream.close();
            LOGGER.debug("File size {0}", xmlFile.size);
            callback(true);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
            callback(error);
        }
    }
}
}
