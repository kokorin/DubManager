package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

/**
 * @see http://wiki.anidb.net/w/Content:Episodes#Episode_Names_.28English.29
 * @see http://wiki.anidb.net/w/UDP_API_Definition#EPISODE:_Retrieve_Episode_Data
 */

public class EpisodeType extends Enum {
    private var _code:int;
    private var _prefix:String;

    public static const REGULAR:EpisodeType = new EpisodeType("Regular", 1, "");
    public static const SPECIAL:EpisodeType = new EpisodeType("Special", 2, "S");
    public static const CREDIT:EpisodeType = new EpisodeType("Credit", 3, "C");
    public static const TRAILER:EpisodeType = new EpisodeType("Trailer", 4, "T");
    public static const PARODY:EpisodeType = new EpisodeType("Parody", 5, "P");
    public static const OTHER:EpisodeType = new EpisodeType("Other", 6, "O");


    public function EpisodeType(name:String, code:int, prefix:String) {
        super(name);
        _code = code;
        _prefix = prefix;
    }

    public function get code():int {
        return _code;
    }

    public function get prefix():String {
        return _prefix;
    }
}
}
