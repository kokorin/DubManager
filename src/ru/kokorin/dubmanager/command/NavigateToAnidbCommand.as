package ru.kokorin.dubmanager.command {
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.logging.ILogger;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.LogUtil;

public class NavigateToAnidbCommand {
    private static const LOGGER:ILogger = LogUtil.getLogger(NavigateToAnidbCommand);

    public function execute(event:AnimeEvent):void {
        const anime:Anime = event.anime;
        LOGGER.debug("Anime: {0}", anime);

        if (anime && anime.id && !isNaN(anime.id)) {
            var url:String = "http://anidb.net/perl-bin/animedb.pl?show=anime&aid=" + anime.id;
            LOGGER.debug("Navigating to: {0}", url);
            var urlReq:URLRequest = new URLRequest(url);
            navigateToURL(urlReq, "_blank");
        }
    }
}
}
