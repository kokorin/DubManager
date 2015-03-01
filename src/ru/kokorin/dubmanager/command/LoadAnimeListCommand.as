package ru.kokorin.dubmanager.command {
import org.spicefactory.lib.command.builder.CommandGroupBuilder;
import org.spicefactory.lib.command.builder.Commands;

import ru.kokorin.astream.AStream;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;

public class LoadAnimeListCommand extends BaseCommand {
    public var callback:Function;
    public var aStream:AStream;

    public function execute(event:AnimeEvent):void {
        const result:Vector.<Anime> = new Vector.<Anime>();

        const commandBuilder:CommandGroupBuilder = Commands.asSequence().data(aStream);

        for each (var anime:Anime in event.animeList) {
            var fakeEvent:AnimeEvent = new AnimeEvent(AnimeEvent.LOAD);
            fakeEvent.anime = anime;
            commandBuilder.data(fakeEvent).create(LoadAnimeCommand);
        }

        commandBuilder.skipErrors().skipCancellations().
                allResults(function (anime:Anime):void {
                    result.push(anime);
                }).
                lastResult(function ():void {
                    callback(result);
                }).
                build().execute();
    }
}
}
