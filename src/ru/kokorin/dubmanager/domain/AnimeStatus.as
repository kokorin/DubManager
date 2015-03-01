package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class AnimeStatus extends Enum {
    public static const NOT_STARTED:AnimeStatus = new AnimeStatus("NOT_STARTED");
    public static const IN_PROCESS:AnimeStatus = new AnimeStatus("IN_PROCESS");
    public static const COMPLETE:AnimeStatus = new AnimeStatus("COMPLETE");

    public static const statuses:Array = [NOT_STARTED, IN_PROCESS, COMPLETE];

    function AnimeStatus(name:String) {
        super(name);
    }
}
}