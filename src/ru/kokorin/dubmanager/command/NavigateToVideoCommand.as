package ru.kokorin.dubmanager.command {
import flash.net.URLRequest;
import flash.net.navigateToURL;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;

public class NavigateToVideoCommand {
    public function execute(event:AnimeEvent):void {
        const anime:Anime = event.anime;

        if (anime && anime.videoURL) {
            var urlReq:URLRequest = new URLRequest(anime.videoURL);
            navigateToURL(urlReq, "_blank");
        }
    }
}
}
