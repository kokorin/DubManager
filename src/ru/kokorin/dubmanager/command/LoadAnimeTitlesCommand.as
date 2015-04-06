package ru.kokorin.dubmanager.command {
import avmplus.getQualifiedClassName;

import com.probertson.utils.GZIPBytesEncoder;

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
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

    //TODO keep result of previous execution for some time
    public function execute(event:Event):void {
        xmlFile = File.applicationStorageDirectory.resolvePath("anime-titles.xml");

        if (xmlFile.exists && xmlFile.size > 10) {
            LOGGER.debug("{0} creationDate:{1}, modificationDate:{2}, ", xmlFile.url, xmlFile.creationDate, xmlFile.modificationDate);
            const weekAgo:Date = new Date();
            weekAgo.date -= 7;

            if (xmlFile.modificationDate.time > weekAgo.time ||
                    xmlFile.creationDate.time > weekAgo.time) {
                const result:ArrayCollection = loadFromFile(xmlFile);
                callback(result);
                return;
            }
        } else {
            LOGGER.warn("File does not exist: {0}", xmlFile.url);
        }

        //It seems that on MacOS downloaded gzipped content is not decompressed automatically
        const loader:URLLoader = new URLLoader();
        loader.dataFormat = URLLoaderDataFormat.BINARY;
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
        LOGGER.info("Load complete: loaded {0} bytes, type {1}", loader.bytesLoaded, getQualifiedClassName(loader.data));

        var xmlString:String = null;
        var bytes:ByteArray = loader.data as ByteArray;
        if (bytes) {
            try {
                //Trying to decompress
                const gzEncoder:GZIPBytesEncoder = new GZIPBytesEncoder();
                bytes = gzEncoder.uncompressToByteArray(bytes);
                xmlString = String(bytes);
            } catch (error:Error) {
                LOGGER.warn("Failed to decompress: {0}", error.getStackTrace());
            }
        }
        if (!xmlString) {
            xmlString = String(loader.data);
        }

        try {
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.WRITE);
            fileStream.writeUTFBytes(xmlString);
            fileStream.close();
            LOGGER.info("Data written to file: {0}", xmlFile.url);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }

        const result:ArrayCollection = loadFromString(xmlString);
        callback(result);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        const result:ArrayCollection = loadFromFile(xmlFile);
        callback(result);
    }

    private static function loadFromFile(xmlFile:File):ArrayCollection {
        try {
            if (xmlFile.exists) {
                LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);

                const fileStream:FileStream = new FileStream();
                fileStream.open(xmlFile, FileMode.READ);
                const xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                fileStream.close();

                LOGGER.debug("XML-file loaded");
                return loadFromString(xmlString);
            }
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }
        return null;
    }

    private static function loadFromString(xmlString:String):ArrayCollection {
        const result:Array = new Array();

        try {
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

                    //in anime-titles.xml synonym (TitleType.SYNONYM) is shortened as syn
                    var type:String = String(titleXML.@type);
                    if (type == "syn") {
                        title.type = TitleType.SYNONYM;
                    } else {
                        title.type = typeConverter.fromString(type) as TitleType;
                    }
                    anime.titles.push(title);
                }
                result.push(anime);
            }
            LOGGER.debug("result.length {0}", result.length);
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }

        return new ArrayCollection(result);
    }
}
}

