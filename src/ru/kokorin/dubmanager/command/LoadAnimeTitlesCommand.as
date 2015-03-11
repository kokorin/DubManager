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

import mx.logging.ILogger;

import org.spicefactory.lib.reflect.ClassInfo;

import ru.kokorin.astream.converter.Converter;
import ru.kokorin.astream.converter.EnumConverter;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.domain.TitleType;
import ru.kokorin.util.LogUtil;
import ru.kokorin.util.XmlUtil;

public class LoadAnimeTitlesCommand {
    public var callback:Function;
    private var xmlFile:File;

    private static const LOGGER:ILogger = LogUtil.getLogger(LoadAnimeTitlesCommand);

    public function execute(event:Event):void {
        xmlFile = File.applicationStorageDirectory.resolvePath("anime-titles.xml");
        const weekAgo:Date = new Date();
        weekAgo.date -= 7;

        if (xmlFile.exists && xmlFile.size > 10 &&
                xmlFile.modificationDate.time > weekAgo.time &&
                xmlFile.creationDate.time > weekAgo.time) {
            const result:Vector.<Anime> = loadFromFile(xmlFile);
            callback(result);
            return;
        }

        const loader:URLLoader = new URLLoader();
        const request:URLRequest = new URLRequest("http://anidb.net/api/anime-titles.xml.gz");
        LOGGER.debug("Loading from {0}", request.url);

        //TODO add progress event dispatching
        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        loader.load(request);
    }

    private function onLoadComplete(event:Event):void {
        const loader:URLLoader = event.target as URLLoader;
        LOGGER.info("Load complete: {0} bytes", loader.bytesLoaded);
        const xmlString:String = String(loader.data);

        try {
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.WRITE);
            fileStream.writeUTFBytes(xmlString);
            fileStream.close();
            LOGGER.info("Data written to file: {0}", xmlFile.url);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }

        const result:Vector.<Anime> = loadFromString(xmlString);
        callback(result);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        const result:Vector.<Anime> = loadFromFile(xmlFile);
        callback(result);
    }

    private static function loadFromFile(xmlFile:File):Vector.<Anime> {
        try {
            if (xmlFile.exists) {
                LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
                const fileStream:FileStream = new FileStream();
                fileStream.open(xmlFile, FileMode.READ);
                var xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                fileStream.close();
                LOGGER.debug("XML-file loaded");
                return loadFromString(xmlString);
            }
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }
        return null;
    }

    private static function loadFromString(xmlString:String):Vector.<Anime> {
        const result:Vector.<Anime> = new Vector.<Anime>();

        try {
            //TODO use xml namespace
            xmlString = XmlUtil.replaceXmlNamespace(xmlString);
            LOGGER.debug("XML simplified");

            const xml:XML = new XML(xmlString);
            LOGGER.debug("DOM XML constructed");

            //TODO TitleType.SYN in anime-titles.xml is TitleType.SYNONYM in anime.xml
            const typeConverter:Converter = new EnumConverter(ClassInfo.forClass(TitleType));

            //Manual parsing is up to 5 times faster
            for each (var animeXML:XML in xml.anime) {
                var anime:Anime = new Anime();
                anime.id = parseInt(String(animeXML.@aid));
                anime.titles = new Vector.<Title>();
                for each (var titleXML:XML in animeXML.title) {
                    var title:Title = new Title();
                    title.text = String(titleXML.text());
                    title.lang = String(titleXML.xml_lang);
                    title.type = typeConverter.fromString(String(titleXML.@type)) as TitleType;
                    anime.titles.push(title);
                }
                result.push(anime);
            }
            LOGGER.debug("result.length {0}", result.length);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }

        return result;
    }
}
}

