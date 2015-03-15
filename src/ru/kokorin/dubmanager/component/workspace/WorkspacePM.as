package ru.kokorin.dubmanager.component.workspace {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Data;
import ru.kokorin.dubmanager.event.AnimeEvent;

[Event(name="updateList", type="ru.kokorin.dubmanager.event.AnimeEvent")]
[Event(name="saveData", type="ru.kokorin.dubmanager.event.AnimeEvent")]
[Event(name="loadAnime", type="ru.kokorin.dubmanager.event.AnimeEvent")]
[Event(name="loadTitles", type="ru.kokorin.dubmanager.event.AnimeEvent")]
public class WorkspacePM extends EventDispatcher {
    [Bindable]
    public var data:Data;
    [Bindable]
    public var isLoadingAnime:Boolean;
    [Bindable]
    public var isLoadingAnimeTitles:Boolean;

    private var loadAnimeCallback:Function;
    private var loadAnimeTitlesCallback:Function;

    public function onLoadDataResult(result:Data, event:Event):void {
        if (!result) {
            result = new Data();
        }
        if (!result.animeList) {
            result.animeList = new ArrayCollection();
        }
        data = result;
        setTimeout(updateAnimeList, 5000);
    }

    public function saveAnime(anime:Object, original:Object):void {
        const index:int = data.animeList.getItemIndex(original);
        if (index == -1) {
            data.animeList.addItem(anime);
        } else {
            data.animeList.setItemAt(anime, index);
        }
        saveData();
    }

    public function removeAnime(toRemove:Vector.<Object>):void {
        for each (var anime:Anime in toRemove) {
            const index:int = data.animeList.getItemIndex(anime);
            if (index != -1) {
                data.animeList.removeItemAt(index);
            }
        }
        saveData();
    }

    public function loadAnime(anime:Anime, callback:Function):void {
        loadAnimeCallback = callback;

        const event:AnimeEvent = new AnimeEvent(AnimeEvent.LOAD_ANIME);
        event.anime = anime;
        dispatchEvent(event);
    }

    public function onLoadAnimeResult(anime:Anime, event:Event):void {
        if (loadAnimeCallback != null) {
            loadAnimeCallback(anime);
            loadAnimeCallback = null;
        }
    }

    public function loadAnimeTitles(callback:Function):void {
        loadAnimeTitlesCallback = callback;
        const event:AnimeEvent = new AnimeEvent(AnimeEvent.LOAD_TITLES);
        dispatchEvent(event);
    }

    public function onLoadAnimeTitlesResult(animeTitles:ArrayCollection, event:Event):void {
        if (loadAnimeTitlesCallback != null) {
            loadAnimeTitlesCallback(animeTitles);
            loadAnimeTitlesCallback = null;
        }
    }

    private function saveData():void {
        const event:AnimeEvent = new AnimeEvent(AnimeEvent.SAVE_DATA);
        event.data = data;
        dispatchEvent(event);
    }

    private function updateAnimeList():void {
        const event:AnimeEvent = new AnimeEvent(AnimeEvent.UPDATE_LIST);
        event.data = data;
        dispatchEvent(event);
    }
}
}
