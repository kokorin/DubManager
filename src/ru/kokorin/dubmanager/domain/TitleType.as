package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class TitleType extends Enum {
    public static const SHORT:TitleType = new TitleType("short");
    public static const OFFICIAL:TitleType = new TitleType("official");
    public static const SYNONYM:TitleType = new TitleType("synonym");
    public static const MAIN:TitleType = new TitleType("main");

    public function TitleType(name:String) {
        super(name);
    }
}
}
