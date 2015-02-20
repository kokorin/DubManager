package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class SerialType extends Enum {
    public static const SERIAL:SerialType = new SerialType("SERIAL");
    public static const OVA:SerialType = new SerialType("OVA");
    public static const FILM:SerialType = new SerialType("FILM");

    public static const types:Array = [SERIAL, OVA, FILM];

    public function SerialType(name:String) {
        super(name);
    }
}
}
