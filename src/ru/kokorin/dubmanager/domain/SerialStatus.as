package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class SerialStatus extends Enum {
    public static const NOT_STARTED:SerialStatus = new SerialStatus("NOT_STARTED");
    public static const IN_PROCESS:SerialStatus = new SerialStatus("IN_PROCESS");
    public static const COMPLETE:SerialStatus = new SerialStatus("COMPLETE");

    public static const statuses:Array = [NOT_STARTED, IN_PROCESS, COMPLETE];

    function SerialStatus(name:String) {
        super(name);
    }
}
}