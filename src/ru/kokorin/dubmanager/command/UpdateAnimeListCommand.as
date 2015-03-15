package ru.kokorin.dubmanager.command {
import mx.collections.ArrayCollection;
import mx.logging.ILogger;

import org.spicefactory.lib.collection.Map;
import org.spicefactory.lib.command.builder.CommandGroupBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.AnimeStatus;
import ru.kokorin.dubmanager.domain.Episode;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.LogUtil;

public class UpdateAnimeListCommand {
    public var callback:Function;
    public var aStream:AStream;

    private var animeList:ArrayCollection;

    private static const LOGGER:ILogger = LogUtil.getLogger(UpdateAnimeListCommand);
    private static const ANIME_CLASS_INFO:ClassInfo = ClassInfo.forClass(Anime);

    public function execute(event:AnimeEvent):void {
        const commandBuilder:CommandGroupBuilder = Commands.asSequence();

        animeList = event.data.animeList;
        const toUpdate:Array = new Array();
        for each (var anime:Anime in animeList) {
            if (isNaN(anime.id) || anime.status == AnimeStatus.COMPLETE) {
                continue;
            }
            var loadCommand:Object = Commands.create(LoadAnimeCommand).
                    data(aStream).
                    data(anime.id).
                    result(onEveryResult).
                    build();
            commandBuilder.add(loadCommand);

            toUpdate.push(anime.id);
        }

        if (toUpdate.length == 0) {
            LOGGER.warn("Nothing to update");
            callback();
            return;
        }

        LOGGER.debug("Scheduling for update: [{0}]", toUpdate);

        commandBuilder.skipErrors().skipCancellations().
                lastResult(onLastResult).
                execute();
    }

    private function onEveryResult(anime:Anime):void {
        if (!anime) {
            LOGGER.warn("Failed to get Anime!");
            return;
        }
        LOGGER.debug("Loaded {0}", anime.id);
        for each (var original:Anime in animeList) {
            if (original.id == anime.id) {
                anime.episodes = mergeEpisodes(original.episodes, anime.episodes);
                anime.status = original.status;

                for each (var property:Property in ANIME_CLASS_INFO.getProperties()) {
                    if (property.readable && property.writable) {
                        var value:Object = property.getValue(anime);
                        if (value != null && value != "") {
                            property.setValue(original, value);
                        }
                    }
                }
                LOGGER.debug("Updated {0}", anime.id);
                break;
            }
        }
    }

    private function onLastResult(data:Object):void {
        callback(true);
    }

    private static function mergeEpisodes(originals:ArrayCollection, episodes:ArrayCollection):ArrayCollection {
        if (!episodes) {
            episodes = new ArrayCollection();
        }

        //Map with episodes synchronized with anidb.net
        const originalMap:Map = new Map();
        //Map with episodes added by user himself
        const manualMap:Map = new Map();

        //Episodes whose id is NaN were added manually. Have to keep them.
        for each (var original:Episode in originals) {
            if (!isNaN(original.id)) {
                originalMap.put(original.id, original);
            } else {
                manualMap.put(original.number, original);
            }
        }

        for each (var episode:Episode in episodes) {
            if (originalMap.containsKey(episode.id)) {
                original = originalMap.get(episode.id) as Episode;
            } else if (manualMap.containsKey(episode.number)) {
                //If episode added by user and episode from anidb.net have the same number
                //we will keep anidb's one.
                original = manualMap.remove(episode.number) as Episode;
            }

            if (original) {
                episode.status = original.status;
            }
        }

        for each (original in manualMap.values) {
            episodes.addItem(original);
        }

        return episodes;
    }
}
}
