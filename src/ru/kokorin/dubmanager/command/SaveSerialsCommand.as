package ru.kokorin.dubmanager.command {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.event.SerialEvent;

public class SaveSerialsCommand extends BaseCommand {
    public var aStream:AStream;

    public function execute(event:SerialEvent):void {
        const xml:XML = aStream.toXML(event.serials);
        const xmlFile:File = File.applicationStorageDirectory.resolvePath("serials.xml");
        const fileStream:FileStream = new FileStream();
        fileStream.open(xmlFile, FileMode.WRITE);
        fileStream.writeUTFBytes(xml.toXMLString());
        fileStream.close();
    }
}
}
