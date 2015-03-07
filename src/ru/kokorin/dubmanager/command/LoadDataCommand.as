package ru.kokorin.dubmanager.command {
import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

import mx.collections.ArrayCollection;
import mx.logging.ILogger;

import org.spicefactory.lib.reflect.ClassInfo;

import ru.kokorin.astream.AStream;
import ru.kokorin.astream.converter.DateConverter;
import ru.kokorin.astream.converter.EnumConverter;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.AnimeStatus;
import ru.kokorin.dubmanager.domain.AnimeType;
import ru.kokorin.dubmanager.domain.Episode;
import ru.kokorin.dubmanager.domain.EpisodeStatus;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.domain.TitleType;
import ru.kokorin.util.LogUtil;

public class LoadDataCommand {
    public var aStream:AStream;

    private static const LOGGER:ILogger = LogUtil.getLogger(LoadDataCommand);

    public function execute(event:Event):Vector.<Anime> {
        var result:Vector.<Anime>;
        try {
            result = loadData();
            if (!result) {
                result = deprecated_load_from_xml();
            }
            if (!result) {
                result = deprecated_load_from_db();
            }
        } catch (error:Error) {
            LOGGER.error(error.getStackTrace());
        }
        return result;
    }

    private function loadData():Vector.<Anime> {
        var result:Vector.<Anime> = null;

        const xmlFile:File = File.applicationStorageDirectory.resolvePath("data.xml");
        if (xmlFile.exists) {
            LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.READ);
            const xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            const xml:XML = new XML(xmlString);

            result = aStream.fromXML(xml) as Vector.<Anime>;
        }

        return result;
    }

    [Deprecated(since="0.4.0", message="will be removed in 0.4.0 release")]
    private function deprecated_load_from_xml():Vector.<Anime> {
        var result:Vector.<Anime> = null;

        const xmlFile:File = File.applicationStorageDirectory.resolvePath("serials.xml");
        if (xmlFile.exists) {
            result = new Vector.<Anime>();
            LOGGER.debug("Loading from XML-file: {0}", xmlFile.nativePath);
            const fileStream:FileStream = new FileStream();
            fileStream.open(xmlFile, FileMode.READ);
            const xmlString:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
            fileStream.close();
            const xml:XML = new XML(xmlString);

            const animeStatusParser:EnumConverter = new EnumConverter(ClassInfo.forClass(AnimeStatus));
            const episodeStatusParser:EnumConverter = new EnumConverter(ClassInfo.forClass(EpisodeStatus));
            const dateParser:DateConverter = new DateConverter();

            for each (var serialXML:XML in xml.Serial) {
                var anime:Anime = new Anime();
                anime.titles = new Vector.<Title>();
                var title:Title = new Title();
                title.type = TitleType.MAIN;
                title.text = String(serialXML.child("name"));
                anime.titles.push(title);

                const type:String = String(serialXML.type);
                if (type == "SERIAL") {
                    anime.type = AnimeType.TV_SERIES;
                } else if (type == "OVA") {
                    anime.type = AnimeType.OVA;
                } else if (type == "FILM") {
                    anime.type = AnimeType.MOVIE;
                }
                anime.status = animeStatusParser.fromString(String(serialXML.status)) as AnimeStatus;
                anime.episodeCount = parseInt(String(serialXML.episodesCount));
                anime.videoURL = String(serialXML.videoURL);
                anime.subtitleURL = String(serialXML.subtitleURL);
                anime.timingBy = String(serialXML.timingBy);
                anime.soundBy = String(serialXML.soundBy);
                anime.integrationBy = String(serialXML.integrationBy);
                anime.comment = String(serialXML.comment);

                for each (var episodeXML:XML in serialXML.episodes.Episode) {
                    var episode:Episode = new Episode();
                    episode.number = String(episodeXML.number);
                    episode.status = episodeStatusParser.fromString(String(episodeXML.status)) as EpisodeStatus;
                    episode.airDate = dateParser.fromString(String(episodeXML.date)) as Date;

                    if (!anime.episodes) {
                        anime.episodes = new ArrayCollection();
                    }
                    anime.episodes.addItem(episode);
                }

                result.push(anime);
            }
        }

        return result;
    }

    private static const SELECT_ALL_ITEMS:String = "SELECT * FROM DubItem";
    private static const SELECT_SUBITEMS_FOR_ITEM:String = "SELECT * FROM DubSubItem WHERE dubItemID = :dubItemID";

    [Deprecated(since="0.4.0", message="will be removed in 0.4.0 release")]
    private function deprecated_load_from_db():Vector.<Anime> {
        var result:Vector.<Anime> = null;

        const dbFile:File = File.applicationStorageDirectory.resolvePath("dub-manager.db");
        if (dbFile.exists) {
            LOGGER.debug("Loading from DB-file: {0}", dbFile.nativePath);
            const conn:SQLConnection = new SQLConnection();
            conn.open(dbFile);

            const itemsStm:SQLStatement = new SQLStatement();
            itemsStm.sqlConnection = conn;
            itemsStm.text = SELECT_ALL_ITEMS;
            itemsStm.execute();

            const items:Array = itemsStm.getResult().data;

            for each(var item:Object in items) {
                var anime:Anime = db_parseAnime(item);
                if (!result) {
                    result = new Vector.<Anime>();
                }
                result.push(anime);

                var subItemsStm:SQLStatement = new SQLStatement();
                subItemsStm.sqlConnection = conn;
                subItemsStm.text = SELECT_SUBITEMS_FOR_ITEM;
                subItemsStm.parameters[":dubItemID"] = item.id;
                subItemsStm.execute();
                var subitems:Array = subItemsStm.getResult().data;

                for each(var subitem:Object in subitems) {
                    if (!anime.episodes) {
                        anime.episodes = new ArrayCollection();
                    }
                    anime.episodes.addItem(db_parseEpisode(subitem));
                }
            }
        }

        return result;
    }

    [Deprecated(since="0.4.0", message="will be removed in 0.4.0 release")]
    private static function db_parseAnime(item:Object):Anime {
        const result:Anime = new Anime();

        result.titles = new Vector.<Title>();
        var title:Title = new Title();
        title.type = TitleType.MAIN;
        title.text = String(item.name);
        result.titles.push(title);

        const type:String = String(item.type);
        if (type == "Сериал") {
            result.type = AnimeType.TV_SERIES;
        } else if (type == "OVA") {
            result.type = AnimeType.OVA;
        } else if (type == "Фильм") {
            result.type = AnimeType.MOVIE;
        }

        const status:String = String(item.status);
        if (status == "notStarted") {
            result.status = AnimeStatus.NOT_STARTED;
        } else if (status == "started") {
            result.status = AnimeStatus.IN_PROCESS;
        } else if (status == "finished") {
            result.status = AnimeStatus.COMPLETE;
        }

        result.episodeCount = Number(item.totalSubItems);
        result.videoURL = String(item.videoURL);
        result.subtitleURL = String(item.subtitleURL);
        result.timingBy = String(item.timingBy);
        result.soundBy = String(item.soundBy);
        result.integrationBy = String(item.integrationBy);
        result.comment = String(item.comment);

        return result;
    }

    [Deprecated(since="0.4.0", message="will be removed in 0.4.0 release")]
    private static function db_parseEpisode(item:Object):Episode {
        const result:Episode = new Episode();

        result.number = String(item.number);

        const status:String = String(item.status);
        if (status == "notStarted") {
            result.status = EpisodeStatus.NOT_STARTED;
        } else if (status == "finished") {
            result.status = EpisodeStatus.COMPLETE;
        }

        result.airDate = item.date as Date;

        return result;
    }
}
}
