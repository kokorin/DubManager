package ru.kokorin.component {
import flash.events.Event;

public class EditEvent extends Event {
    public static const SAVE:String = "save";

    public var item:Object;
    public var original:Object;

    public function EditEvent(type:String) {
        super(type);
    }
}
}
