package ru.kokorin.dubmanager.command {
import flash.net.URLRequest;
import flash.net.navigateToURL;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;
import ru.kokorin.util.LabelUtil;

public class NavigateToWorldArtCommand {
    public function execute(event:AnimeEvent):void {
        const anime:Anime = event.anime;

        if (!anime) {
            return;
        }

        var url:String = null;
        if (anime.worldArtID && !isNaN(anime.worldArtID)) {
            url = "http://www.world-art.ru/animation/animation.php?id=" + anime.worldArtID;
        } else {
            var title:String = LabelUtil.getTitle(anime);
            title = title.replace(/[ \s]+/g, " ");
            title = encodeURIComponent(title);
            url = "http://www.world-art.ru/search.php?public_search=" + title + "&global_sector=animation";
        }

        if (url) {
            var urlReq:URLRequest = new URLRequest(url);
            navigateToURL(urlReq, "_blank");
        }
    }
}
}
