package ru.kokorin.component {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.collections.IList;
import mx.collections.ListCollectionView;

import org.apache.flex.collections.VectorCollection;

[Event(name="open", type="flash.events.Event")]
[Event(name="close", type="flash.events.Event")]
[Event(name="select", type="ru.kokorin.component.SelectEvent")]
public class SelectPM extends EventDispatcher {
    private var _items:ListCollectionView;
    private var _filterText:String;
    private var updateFilterTimeout:uint = 0;

    public function SelectPM() {
    }

    [Bindable("itemsChange")]
    public final function get items():IList {
        return _items;
    }

    [Bindable("open")]
    [Bindable("close")]
    public function get isOpen():Boolean {
        return items != null;
    }

    public function open(items:Object):void {
        if (_items) {
            _items.filterFunction = null;
        }

        var collection:ListCollectionView = items as ListCollectionView;
        if (!collection) {
            var array:Array = items as Array;
            if (!array) {
                var list:IList = items as IList;
                if (list) {
                    array = list.toArray();
                }
            }
            if (array) {
                collection = new ArrayCollection(array);
            } else if (items) {
                collection = new VectorCollection(items);
            }

        }
        _items = collection;
        if (_items) {
            _items.filterFunction = filterItem;
        }

        updateFilterLater();
        dispatchEvent(new Event("itemsChange"));
        dispatchEvent(new Event(Event.OPEN));
    }

    public function close():void {
        if (_items) {
            _items.filterFunction = null;
        }
        _items = null;
        filterText = null;
        dispatchEvent(new Event(Event.CLOSE));
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
        if (_items) {
            _items.refresh();
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
