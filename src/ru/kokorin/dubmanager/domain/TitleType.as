package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class TitleType extends Enum {
    public static const SHORT:TitleType = new TitleType("short");
    public static const OFFICIAL:TitleType = new TitleType("official");
    public static const SYN:TitleType = new TitleType("syn");
    public static const SYNONYM:TitleType = new TitleType("synonym");
    public static const MAIN:TitleType = new TitleType("main");

    public static const types:Array = [SHORT, OFFICIAL, SYN, SYNONYM, MAIN];

    public function TitleType(name:String) {
        super(name);
    }
}
}
