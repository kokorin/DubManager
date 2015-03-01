package ru.kokorin.component {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import org.apache.flex.collections.VectorCollection;

[Event(name="open", type="flash.events.Event")]
[Event(name="close", type="flash.events.Event")]
[Event(name="select", type="ru.kokorin.component.SelectEvent")]
public class SelectPM extends EventDispatcher {
    private var _isOpen:Boolean;
    private var _items:VectorCollection;
    private var _filterText:String;
    private var updateFilterTimeout:uint = 0;

    public function SelectPM() {
    }

    [Bindable("itemsChange")]
    public final function get items():VectorCollection {
        return _items;
    }

    protected final function setItems(value:VectorCollection):void {
        if (_items) {
            _items.filterFunction = null;
        }
        _items = value;
        if (_items) {
            _items.filterFunction = filterItem;
        }

        updateFilterLater();
        dispatchEvent(new Event("itemsChange"));
    }

    [Bindable("open")]
    [Bindable("close")]
    public function get isOpen():Boolean {
        return _isOpen;
    }

    public function open():void {
        if (!_isOpen) {
            _isOpen = true;
            dispatchEvent(new Event(Event.OPEN));
        }
    }

    public function close():void {
        if (_isOpen) {
            _isOpen = false;
            dispatchEvent(new Event(Event.CLOSE));
        }
        filterText = null;
    }

    [Bindable]
    public function get filterText():String {
        return _filterText;
    }

    public function set filterText(value:String):void {
        _filterText = value;
        updateFilterLater();
    }

    private function updateFilterLater():void {
        if (updateFilterTimeout) {
            clearTimeout(updateFilterTimeout);
        }
        updateFilterTimeout = setTimeout(updateFilterNow, 1000);
    }

    private function updateFilterNow():void {
        updateFilterTimeout = 0;
        if (items) {
            items.refresh();
        }
    }

    protected function filterItem(item:Object):Boolean {
        return true;
    }

    public function select(item:Object):void {
        const event:SelectEvent = new SelectEvent(SelectEvent.SELECT);
        event.item = item;
        dispatchEvent(event);
        close();
    }
}
}
