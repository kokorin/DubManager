package ru.kokorin.util {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import mx.events.PropertyChangeEvent;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;

public class ChangeTracker extends EventDispatcher {
    private var _target:IEventDispatcher;
    private var _changed:Boolean = false;

    public function ChangeTracker() {
        super();
    }

    [Bindable]
    public function get target():IEventDispatcher {
        return _target;
    }

    public function set target(value:IEventDispatcher):void {
        if (_target) {
            for each(var property:Property in ClassInfo.forInstance(_target).getProperties()) {
                unwatchProperty(property.getValue(_target));
            }
            _target.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
        }

        _target = value;
        setChanged(false);

        if (_target) {
            for each(property in ClassInfo.forInstance(_target).getProperties()) {
                watchProperty(property.getValue(_target));
            }
            _target.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onPropertyChange);
        }
    }

    [Bindable(event="change")]
    public function get changed():Boolean {
        return _changed;
    }

    public function set changed(value:Boolean):void {
        _changed = value;
    }

    private function watchProperty(property:Object):void {
        var list:IList = property as IList;
        var dispatcher:IEventDispatcher = property as IEventDispatcher;
        if (list) {
            list.addEventListener(CollectionEvent.COLLECTION_CHANGE, onSubCollectionChange);
        } else if (dispatcher) {
            dispatcher.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onSubPropertyChange);
        }
    }
    private function unwatchProperty(property:Object):void {
        var list:IList = property as IList;
        var dispatcher:IEventDispatcher = property as IEventDispatcher;
        if (list) {
            list.removeEventListener(CollectionEvent.COLLECTION_CHANGE, onSubCollectionChange);
        } else if (dispatcher) {
            dispatcher.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, onSubPropertyChange);
        }
    }

    private function onPropertyChange(event:PropertyChangeEvent):void {
        unwatchProperty(event.oldValue);
        watchProperty(event.newValue);
        setChanged(true);
    }
    private function onSubPropertyChange(event:PropertyChangeEvent):void {
        setChanged(true);
    }

    private static const CHANGE_KINDS:Array = [CollectionEventKind.ADD, CollectionEventKind.MOVE,
        CollectionEventKind.REMOVE, CollectionEventKind.REPLACE, CollectionEventKind.UPDATE];
    private function onSubCollectionChange(event:CollectionEvent):void {
        if (CHANGE_KINDS.indexOf(event.kind) != -1) {
            setChanged(true);
        }
    }

    private function setChanged(value:Boolean):void {
        if (_changed == value) {
            return;
        }

        _changed = value;
        dispatchEvent(new Event(Event.CHANGE));
    }
}
}
