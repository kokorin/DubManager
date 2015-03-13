package ru.kokorin.dubmanager.command {
import mx.logging.ILogger;

import org.spicefactory.lib.collection.Map;
import org.spicefactory.lib.command.builder.CommandGroupBuilder;
import org.spicefactory.lib.command.builder.Commands;
import org.spicefactory.lib.command.data.CommandData;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.AnimeStatus;
import ru.kokorin.dubmanager.domain.Episode;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.LogUtil;

public class UpdateAnimeListCommand {
    public var callback:Function;
    public var aStream:AStream;

    private var animeList:Vector.<Anime>;
    private var animeUpdated:Boolean = false;

    private static const LOGGER:ILogger = LogUtil.getLogger(UpdateAnimeListCommand);

    public function execute(event:AnimeEvent):void {
        const commandBuilder:CommandGroupBuilder = Commands.asSequence();

        animeList = event.animeList;
        const toUpdate:Array = new Array();
        for each (var anime:Anime in animeList) {
            if (isNaN(anime.id) || anime.status == AnimeStatus.COMPLETE) {
                continue;
            }
            commandBuilder.add(new LoadAnimeCommand(aStream, anime.id));
            toUpdate.push(anime.id);
        }

        if (toUpdate.length == 0) {
            LOGGER.warn("Nothing to update");
            callback();
            return;
        }

        LOGGER.debug("Scheduling for update: [{0}]", toUpdate);

        commandBuilder.skipErrors().skipCancellations().
                allResults(onEveryResult).
                lastResult(onLastResult).
                execute();
    }

    private function onEveryResult(commandData:CommandData):void {
        const anime:Anime = commandData.getObject(Anime) as Anime;
        if (!anime) {
            return;
        }
        for each (var original:Anime in animeList) {
            if (original.id == anime.id) {
                var episodes:Map = new Map();

                for each (var episode:Episode in original.episodes) {
                    episodes.put(episode.id, episode);
                }

                var originalEpisodesLength:int = original.episodes ? original.episodes.length : 0;
                var animeEpisodesLength:int = anime.episodes ? anime.episodes.length : 0;
                var episodeUpdated:Boolean = originalEpisodesLength != animeEpisodesLength;

                for each (episode in anime.episodes) {
                    var originalEp:Episode = episodes.get(episode.id);
                    if (originalEp) {
                        var episodeUpdate:uint = episode.update ? episode.update.time : 0;
                        var originalEpUpdate:uint = originalEp.update ? originalEp.update.time : 0;

                        if (episodeUpdate > originalEpUpdate) {
                            episode.status = originalEp.status;
                            episodeUpdated = true;
                        }
                    } else {
                        episodeUpdated = true;
                    }
                }

                //TODO need better mechanism
                if (episodeUpdated) {
                    LOGGER.debug("Update found for: {0}", anime.id);
                    original.episodes = anime.episodes;
                    animeUpdated = true;
                }

                original.type = anime.type;
                original.episodeCount = anime.episodeCount;
                original.startDate = anime.startDate;
                original.endDate = anime.endDate;
                original.titles = anime.titles;
                original.relatedAnimeList = anime.relatedAnimeList;
                original.description = anime.description;
                original.picture = anime.picture;
                original.episodes = anime.episodes;

                break;
            }
        }
    }

    private function onLastResult(data:Object):void {
        callback(animeUpdated);
    }
}
}
