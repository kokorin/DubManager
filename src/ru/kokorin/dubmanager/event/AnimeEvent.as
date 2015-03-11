package ru.kokorin.dubmanager.event {
import flash.events.Event;

import ru.kokorin.dubmanager.domain.Anime;

public class AnimeEvent extends Event {
    public static const LOAD_TITLES:String = "loadTitles";
    public static const UPDATE_LIST:String = "updateList";
    public static const LOAD_ANIME:String = "loadAnime";

    public static const SAVE_DATA:String = "saveData";
    public static const LOAD_DATA:String = "loadData";

    public var anime:Anime;
    public var animeList:Vector.<Anime>;

    public function AnimeEvent(type:String) {
        super(type);
    }
}
}
