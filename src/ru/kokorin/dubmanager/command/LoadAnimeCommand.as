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
import flash.net.URLVariables;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.XmlUtil;

public class LoadAnimeCommand extends BaseCommand {
    public var callback:Function;
    public var aStream:AStream;

    private var xmlFile:File;

    public function execute(event:AnimeEvent):void {
        xmlFile = File.applicationStorageDirectory.resolvePath("anime/" + event.anime.id + ".xml");

        var anime:Anime = null;

        if (xmlFile.exists) {
            LOGGER.debug("Loading data from file: {0}", xmlFile.url);
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.READ);
            var xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();

            xmlString = XmlUtil.replaceXmlNamespace(xmlString);
            anime = aStream.fromXML(XML(xmlString)) as Anime;

            var date:Date = new Date();
            date.date -= 7;
            const weekAgoTime:Number = date.time;
            const fileChangeTime:Number = Math.max(xmlFile.creationDate.time, xmlFile.modificationDate.time);
            const animeEndTime:Number = anime.endDate ? anime.endDate.time : Number.POSITIVE_INFINITY;

            //If anime was updated BEFORE its endDate AND it was updated more than week ago
            if (animeEndTime > fileChangeTime && fileChangeTime < weekAgoTime) {
                LOGGER.debug("XML data is possibly obsolete");
                anime = null;
            }
        }

        if (anime != null) {
            callback(anime);
            return;
        }

        const loader:URLLoader = new URLLoader();
        const request:URLRequest = new URLRequest("http://api.anidb.net:9001/httpapi");
        const variables:URLVariables = new URLVariables();
        variables.client = "dubmanager";
        variables.clientver = 1;
        variables.protover = 1;
        variables.request = "anime";
        variables.aid = event.anime.id;
        request.data = variables;

        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        LOGGER.debug("Loading XML: {0}?{1}", request.url, variables);
        loader.load(request);
    }

    private function onLoadComplete(event:Event):void {
        const loader:URLLoader = event.target as URLLoader;
        LOGGER.info("Load complete: {0} bytes", loader.bytesLoaded);
        var xmlString:String = String(loader.data);

        if (!xmlFile.parent.exists) {
            xmlFile.parent.createDirectory();
        }

        const fileStream:FileStream = new FileStream();
        fileStream.open(xmlFile, FileMode.WRITE);
        fileStream.writeUTFBytes(xmlString);
        fileStream.close();
        LOGGER.info("Data written to file: {0}", xmlFile.url);

        xmlString = XmlUtil.replaceXmlNamespace(xmlString);
        const anime:Anime = aStream.fromXML(XML(xmlString)) as Anime;

        callback(anime);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        callback(new Error(event.text, event.errorID));
    }
}
}
