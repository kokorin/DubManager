package ru.kokorin.component {
import flash.events.Event;

public class SelectEvent extends Event {
    public static const SELECT:String = "select";

    public var item:Object;

    public function SelectEvent(type:String) {
        super(type);
    }
}
}
