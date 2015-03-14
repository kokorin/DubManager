package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

/**
 * @see http://wiki.anidb.net/w/Anime_Type
 */
public class AnimeType extends Enum {
    public static const MOVIE:AnimeType = new AnimeType("Movie");
    public static const OVA:AnimeType = new AnimeType("OVA");
    public static const TV_SERIES:AnimeType = new AnimeType("TV Series");
    public static const TV_SPECIAL:AnimeType = new AnimeType("TV Special");
    public static const WEB:AnimeType = new AnimeType("Web");
    public static const MUSIC_VIDEO:AnimeType = new AnimeType("Music Video");
    public static const OTHER:AnimeType = new AnimeType("Other");
    public static const UNKNOWN:AnimeType = new AnimeType("unknown");

    public function AnimeType(name:String) {
        super(name);
    }
}
}
