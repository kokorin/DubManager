package ru.kokorin.util {
import flash.events.MouseEvent;

import mx.core.IDataRenderer;
import mx.core.IUIComponent;

public class RendererUtil {
    public static function onRenderer(event:MouseEvent, callback:Function):void {
        var renderer:IDataRenderer = null;

        var component:IUIComponent = event.target as IUIComponent;
        while (component && !renderer) {
            renderer = component as IDataRenderer;
            if (component != event.currentTarget) {
                component = component.parent as IUIComponent;
            } else {
                component = null;
            }
        }

        if (renderer != null && renderer.data != null && callback != null) {
            callback(event, renderer.data);
        }
    }
}
}
