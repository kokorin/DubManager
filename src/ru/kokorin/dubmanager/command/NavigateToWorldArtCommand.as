package ru.kokorin.dubmanager.command {
import flash.net.URLRequest;
import flash.net.navigateToURL;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;

public class NavigateToWorldArtCommand {
    public function execute(event:AnimeEvent):void {
        const anime:Anime = event.anime;

        if (anime && anime.worldArtID && !isNaN(anime.worldArtID)) {
            var url:String = "http://www.world-art.ru/animation/animation.php?id=" + anime.worldArtID;
            var urlReq:URLRequest = new URLRequest(url);
            navigateToURL(urlReq, "_blank");
        }
    }
}
}
