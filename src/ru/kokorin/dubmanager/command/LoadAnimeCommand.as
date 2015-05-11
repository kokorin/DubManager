package ru.kokorin.dubmanager.command {
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.collections.Sort;
import mx.collections.SortField;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.AnimeStatus;
import ru.kokorin.dubmanager.domain.Episode;
import ru.kokorin.dubmanager.domain.EpisodeStatus;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.CompareUtil;
import ru.kokorin.util.XmlUtil;

public class LoadAnimeCommand extends UrlCommand {
    public var aStream:AStream;

    private var animeId:Number;
    private var xmlFile:File;


    public function LoadAnimeCommand(aStream:AStream = null, animeId:Number = NaN) {
        super(null);
        this.aStream = aStream;
        this.animeId = animeId;
    }

    public function execute(event:AnimeEvent = null):void {
        if (event && event.anime) {
            animeId = event.anime.id;
        }
        xmlFile = File.applicationStorageDirectory.resolvePath("anime/" + animeId + ".xml");

        if (xmlFile.exists && xmlFile.size > 50) {
            var update:Date = new Date();
            update.date -= 3;

            LOGGER.debug("creationDate: {0}, modificationDate: {1}", xmlFile.creationDate, xmlFile.modificationDate);
            if (xmlFile.modificationDate.time > update.time ||
                    xmlFile.creationDate.time > update.time) {
                LOGGER.debug("Loading data from file: {0}", xmlFile.url);
                load(xmlFile.url);
                return;
            }
            LOGGER.debug("XML data is possibly obsolete");
        } else {
            LOGGER.debug("File does not exist: {0}", xmlFile.url);
        }

        const data:URLVariables = new URLVariables();
        data.client = "dubmanager";
        data.clientver = 1;
        data.protover = 1;
        data.request = "anime";
        data.aid = animeId;

        load("http://api.anidb.net:9001/httpapi", URLRequestMethod.GET, data);
    }


    override protected function handleResult(data:Object):Object {
        var xmlString:String = String(data);

        xmlString = XmlUtil.replaceXmlNamespace(xmlString);
        const result:Object = aStream.fromXML(XML(xmlString));

        const anime:Anime = result as Anime;
        if (anime) {
            if (!xmlFile.parent.exists) {
                xmlFile.parent.createDirectory();
            }

            try {
                const fileStream:FileStream = new FileStream();
                fileStream.open(xmlFile, FileMode.WRITE);
                fileStream.writeUTFBytes(xmlString);
                fileStream.close();
                LOGGER.info("Data written to file: {0}", xmlFile.url);
            } catch (error:Error) {
                LOGGER.warn(error.getStackTrace());
            }

            anime.status = AnimeStatus.NOT_STARTED;
            if (anime.episodes) {
                for each (var episode:Episode in anime.episodes) {
                    episode.status = EpisodeStatus.NOT_STARTED;
                }

                const typeField:SortField = new SortField("type");
                typeField.compareFunction = function(item1:Object, item2:Object):int {
                    return CompareUtil.byEpisodeType(item1, item2, typeField.name);
                }

                const numberField:SortField = new SortField("number", false, false, true);

                const sort:Sort = new Sort();
                sort.fields = [typeField, numberField];
                anime.episodes.sort = sort;
                anime.episodes.refresh();
            }
        }

        return result;
    }
}
}
