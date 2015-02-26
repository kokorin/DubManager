package ru.kokorin.util {
import avmplus.getQualifiedClassName;

import mx.resources.ResourceManager;

public class LabelUtil {
    //TODO data binding will not update label function on locale change
    public static function getEnumLabelFunction(enumClazz:Class):Function {
        const clazzName:String = getQualifiedClassName(enumClazz).split("::").pop();

        const result:Function = function (item:Object, column:Object = null):String {
            if (column && column.hasOwnProperty("dataField")) {
                item = getProperty(item, column["dataField"]);
            }
            return ResourceManager.getInstance().getString(clazzName, String(item));
        };

        return result;
    }

    public static function getProperty(item:Object, dataField:String):Object {
        if (dataField) {
            for each(var property:String in dataField.split(".")) {
                if (!item || !item.hasOwnProperty(property)) {
                    break;
                }
                item = item[property];
            }
        }
        return item;
    }
}
}
