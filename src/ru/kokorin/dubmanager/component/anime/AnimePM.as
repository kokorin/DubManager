package ru.kokorin.dubmanager.component.anime {
import mx.collections.ArrayCollection;

import ru.kokorin.component.EditPM;
import ru.kokorin.dubmanager.domain.Anime;

public class AnimePM extends EditPM {
    public function AnimePM() {
        super(Anime);
    }

    [Bindable(event="open")]
    [Bindable(event="close")]
    public function get anime():Anime {
        return item as Anime;
    }

    public function saveEpisode(episode:Object, original:Object):void {
        if (!anime.episodes) {
            anime.episodes = new ArrayCollection();
        }

        const index:int = anime.episodes.getItemIndex(original);
        if (index == -1) {
            anime.episodes.addItem(episode);
        } else {
            anime.episodes.setItemAt(episode, index);
        }
    }

    public function removeEpisode(episode:Object):void {
        if (!anime.episodes) {
            return;
        }

        const index:int = anime.episodes.getItemIndex(episode);
        if (index != -1) {
            anime.episodes.removeItemAt(index);
        }
    }
}
}
