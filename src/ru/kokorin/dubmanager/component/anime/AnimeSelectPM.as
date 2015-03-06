package ru.kokorin.dubmanager.component.anime {
import ru.kokorin.component.SelectPM;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Title;

public class AnimeSelectPM extends SelectPM {

    override protected function filterItem(item:Object):Boolean {
        if (!filterText || filterText.length == 0) {
            return true;
        }
        const lowercaseFilter:String = filterText.toLowerCase();
        const anime:Anime = item as Anime;
        if (!anime) {
            return true;
        }
        for each (var title:Title in anime.titles) {
            if (title.text && title.text.toLowerCase().indexOf(lowercaseFilter) != -1) {
                return true;
            }
        }
        return false;
    }

}
}
