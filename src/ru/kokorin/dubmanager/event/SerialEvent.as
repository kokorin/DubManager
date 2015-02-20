package ru.kokorin.dubmanager.event {
import flash.events.Event;

import ru.kokorin.dubmanager.domain.Serial;

public class SerialEvent extends Event {
    public static const SAVE:String = "save";
    public static const LOAD:String = "load";

    public var serials:Vector.<Serial>;

    public function SerialEvent(type:String) {
        super(type);
    }
}
}
