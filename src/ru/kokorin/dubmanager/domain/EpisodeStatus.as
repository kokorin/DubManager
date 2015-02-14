package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class EpisodeStatus extends Enum {
    public static const NOT_STARTED:EpisodeStatus = new EpisodeStatus("NOT_STARTED");
    public static const COMPLETE:EpisodeStatus = new EpisodeStatus("COMPLETE");

    public static const statuses:Array = [NOT_STARTED, COMPLETE];

    function EpisodeStatus(name:String) {
        super(name);
    }
}
}