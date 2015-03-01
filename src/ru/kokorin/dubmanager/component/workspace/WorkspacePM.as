package ru.kokorin.dubmanager.component.workspace {
import flash.events.Event;
import flash.events.EventDispatcher;

import org.apache.flex.collections.VectorCollection;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.event.AnimeEvent;

[Event(name="saveData", type="ru.kokorin.dubmanager.event.AnimeEvent")]
public class WorkspacePM extends EventDispatcher {
    [Bindable]
    public var animeList:VectorCollection;

    public function onLoadResult(result:Vector.<Anime>, event:Event):void {
        if (!result) {
            result = new Vector.<Anime>();
        }
        animeList = new VectorCollection(result);
    }

    public function saveAnime(anime:Object, original:Object):void {
        const index:int = animeList.getItemIndex(original);
        if (index == -1) {
            animeList.addItem(anime);
        } else {
            animeList.setItemAt(anime, index);
        }
        saveData();
    }

    public function removeAnime(anime:Object):void {
        const index:int = animeList.getItemIndex(anime);
        if (index != -1) {
            animeList.removeItemAt(index);
        }
        saveData();
    }

    private function saveData():void {
        const event:AnimeEvent = new AnimeEvent(AnimeEvent.SAVE_DATA);
        event.animeList = animeList.source as Vector.<Anime>;
        dispatchEvent(event);
    }
}
}
