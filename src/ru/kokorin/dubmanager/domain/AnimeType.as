package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class AnimeType extends Enum {
    public static const TV_SERIES:AnimeType = new AnimeType("TV Series");
    public static const OVA:AnimeType = new AnimeType("OVA");
    public static const MOVIE:AnimeType = new AnimeType("Movie");
    public static const WEB:AnimeType = new AnimeType("Web");

    public static const types:Array = [TV_SERIES, OVA, MOVIE, WEB];

    public function AnimeType(name:String) {
        super(name);
    }
}
}
