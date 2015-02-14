package ru.kokorin.component {
import flash.events.Event;

public class SaveEvent extends Event{
    public static const SAVE:String = "save";

    public var item:Object;
    public var original:Object;

    public function SaveEvent(type:String) {
        super(type);
    }
}
}
