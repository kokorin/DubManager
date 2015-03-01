package ru.kokorin.dubmanager.command {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLRequest;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.util.XmlUtil;

public class LoadAnimeTitlesCommand extends BaseCommand {
    public var callback:Function;
    public var aStream:AStream;
    private var xmlFile:File;

    public function execute(event:Event):void {
        xmlFile = File.applicationStorageDirectory.resolvePath("anime-titles.xml");
        const weekAgo:Date = new Date();
        weekAgo.date -= 7;

        if (!xmlFile.exists ||
                xmlFile.modificationDate.time < weekAgo.time ||
                xmlFile.creationDate.time < weekAgo.time)
        {
            const loader:URLLoader = new URLLoader();
            const request:URLRequest = new URLRequest("http://anidb.net/api/anime-titles.xml.gz");
            LOGGER.debug("Loading from {0}", request.url);

            loader.addEventListener(Event.COMPLETE, onLoadComplete);
            loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
            loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

            loader.load(request);
        } else {
            LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.READ);
            var xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            LOGGER.debug("XML-file loaded");
            parseAnimeTitles(xmlString);
        }
    }

    private function onLoadComplete(event:Event):void {
        const loader:URLLoader = event.target as URLLoader;
        LOGGER.info("Load complete: {0} bytes", loader.bytesLoaded);
        const xmlString:String = String(loader.data);

        const fileStream:FileStream = new FileStream();
        fileStream.open(xmlFile, FileMode.WRITE);
        fileStream.writeUTFBytes(xmlString);
        fileStream.close();
        LOGGER.info("Data written to file: {0}", xmlFile.url);

        parseAnimeTitles(xmlString);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        callback(new Error(event.text, event.errorID));
    }

    private function parseAnimeTitles(xmlString:String):void {
        try {
            var result:Vector.<Anime>;

            xmlString = XmlUtil.replaceXmlNamespace(xmlString);
            LOGGER.debug("XML simplified");

            const xml:XML = new XML(xmlString);
            LOGGER.debug("DOM XML constructed");

            const data:Object = aStream.fromXML(xml);
            result = data as Vector.<Anime>;
            LOGGER.info("Parsed {0} elements", result.length);

            callback(result);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
            callback(error);
        }
    }
}
}
