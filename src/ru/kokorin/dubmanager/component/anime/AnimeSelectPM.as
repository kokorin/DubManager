package ru.kokorin.dubmanager.component.anime {
import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.apache.flex.collections.VectorCollection;

import ru.kokorin.component.SelectPM;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.event.AnimeEvent;

[Event(name="loadTitles", type="ru.kokorin.dubmanager.event.AnimeEvent")]
public class AnimeSelectPM extends SelectPM {
    private var freeDataTimeout:uint = 0;

    override public function open():void {
        super.open();
        if (items == null) {
            loadTitles();
        }
        if (freeDataTimeout) {
            clearTimeout(freeDataTimeout);
            freeDataTimeout = 0;
        }
    }

    override public function close():void {
        super.close();
        if (freeDataTimeout == 0) {
            freeDataTimeout = setTimeout(freeDataNow, 60 * 1000);
        }
    }

    private function freeDataNow():void {
        freeDataTimeout = 0;
        setItems(null);
    }

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

    private function loadTitles():void {
        const event:AnimeEvent = new AnimeEvent(AnimeEvent.LOAD_TITLES);
        dispatchEvent(event);
    }

    public function onLoadTitlesResult(result:Vector.<Anime>, event:Event):void {
        setItems(new VectorCollection(result));
    }
}
}
