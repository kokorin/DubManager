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

import org.spicefactory.lib.reflect.ClassInfo;

import ru.kokorin.astream.converter.Converter;
import ru.kokorin.astream.converter.EnumConverter;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.domain.TitleType;
import ru.kokorin.util.XmlUtil;

public class LoadAnimeTitlesCommand extends BaseCommand {
    public var callback:Function;
    private var xmlFile:File;

    public function execute(event:Event):void {
        xmlFile = File.applicationStorageDirectory.resolvePath("anime-titles.xml");
        const weekAgo:Date = new Date();
        weekAgo.date -= 7;

        if (xmlFile.exists && xmlFile.modificationDate.time > weekAgo.time &&
                xmlFile.creationDate.time > weekAgo.time)
        {
            const result:Vector.<Anime> = loadFromXmlFile();
            callback(result);
            return;
        }

        const loader:URLLoader = new URLLoader();
        const request:URLRequest = new URLRequest("http://anidb.net/api/anime-titles.xml.gz");
        LOGGER.debug("Loading from {0}", request.url);

        loader.addEventListener(Event.COMPLETE, onLoadComplete);
        loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        loader.load(request);
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

        const result:Vector.<Anime> = parseAnimeTitles(xmlString);
        callback(result);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        const result:Vector.<Anime> = loadFromXmlFile();
        callback(result);
    }

    private function loadFromXmlFile():Vector.<Anime> {
        LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
        const fileStream:FileStream = new FileStream();
        fileStream.open(xmlFile, FileMode.READ);
        var xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
        fileStream.close();
        LOGGER.debug("XML-file loaded");

        const result:Vector.<Anime> = parseAnimeTitles(xmlString);
        return result;
    }

    private function parseAnimeTitles(xmlString:String):Vector.<Anime> {
        const result:Vector.<Anime> = new Vector.<Anime>();

        try {
            //TODO use xml namespace
            xmlString = XmlUtil.replaceXmlNamespace(xmlString);
            LOGGER.debug("XML simplified");

            const xml:XML = new XML(xmlString);
            LOGGER.debug("DOM XML constructed");

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

