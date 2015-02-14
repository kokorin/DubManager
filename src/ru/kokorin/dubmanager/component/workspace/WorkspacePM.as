package ru.kokorin.dubmanager.component.workspace {
import flash.events.Event;
import flash.events.EventDispatcher;

import org.apache.flex.collections.VectorCollection;

import ru.kokorin.dubmanager.domain.Serial;
import ru.kokorin.dubmanager.event.SerialEvent;

[Event(name="save", type="ru.kokorin.dubmanager.event.SerialEvent")]
public class WorkspacePM extends EventDispatcher {
    [Bindable]
    public var serials:VectorCollection = new VectorCollection(new Vector.<Serial>());

    public function onLoadResult(result:Vector.<Serial>, event:Event):void {
        serials = new VectorCollection(result);
    }

    public function saveSerial(serial:Object, original:Object):void {
        const index:int = serials.getItemIndex(original);
        if (index == -1) {
            serials.addItem(serial);
        } else {
            serials.setItemAt(serial, index);
        }
        save();
    }

    public function removeSerial(episode:Object):void {
        const index:int = serials.getItemIndex(episode);
        if (index == -1) {
            serials.removeItemAt(index);
        }
        save();
    }

    private function save():void {
        const event:SerialEvent = new SerialEvent(SerialEvent.SAVE);
        event.serials = serials.source as Vector.<Serial>;
        dispatchEvent(event);
    }
}
}
