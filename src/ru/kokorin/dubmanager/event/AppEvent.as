package ru.kokorin.dubmanager.event {
import flash.events.Event;

public class AppEvent extends Event {
    public static const UPDATE:String = "update";

    public function AppEvent(type:String) {
        super(type);
    }
}
}
