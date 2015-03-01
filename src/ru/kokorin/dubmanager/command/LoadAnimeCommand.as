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

    public function execute(event:AnimeEvent):void {
        var anime:Anime = event.anime;

        var date:Date = new Date();
        date.date -= 7;
        const weekAgoTime:Number = date.time;
        const updateTime:Number = anime.update ? anime.update.time : 0;
        const animeEndTime:Number = anime.endDate ? anime.endDate.time : Number.POSITIVE_INFINITY;

        //If anime was updated BEFORE its endDate AND it was updated more than week ago
        if (animeEndTime > updateTime && updateTime < weekAgoTime) {
            LOGGER.debug("XML data is possibly obsolete");
            anime = null;
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
        xmlString = XmlUtil.replaceXmlNamespace(xmlString);
        const anime:Anime = aStream.fromXML(XML(xmlString)) as Anime;
        anime.update = new Date();

        //TODO deep supplement of original object

        callback(anime);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        callback(new Error(event.text, event.errorID));
    }
}
}
