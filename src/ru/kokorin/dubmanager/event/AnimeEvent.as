package ru.kokorin.dubmanager.event {
import flash.events.Event;

import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Data;

public class AnimeEvent extends Event {
    public static const LOAD_TITLES:String = "loadTitles";
    public static const UPDATE_LIST:String = "updateList";
    public static const LOAD_ANIME:String = "loadAnime";

    public static const SAVE_DATA:String = "saveData";
    public static const LOAD_DATA:String = "loadData";

    public static const NAVIGATE_TO_VIDEO:String = "navigateToVideo";
    public static const NAVIGATE_TO_SUBTITLE:String = "navigateToSubtitle";
    public static const NAVIGATE_TO_ANIDB:String = "navigateToAnidb";
    public static const NAVIGATE_TO_WORLD_ART:String = "navigateToWorldArt";

    public var anime:Anime;
    public var data:Data;

    public function AnimeEvent(type:String) {
        super(type);
    }
}
}
