package ru.kokorin.util {
import avmplus.getQualifiedClassName;

import mx.resources.ResourceManager;

import ru.kokorin.dubmanager.domain.ITitled;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.domain.TitleType;

public class LabelUtil {
    //TODO data binding will not update label function on locale change
    public static function getTitle(item:Object, column:Object = null):String {
        item = getProperty(item, column);

        const titled:ITitled = item as ITitled;
        const titles:Vector.<Title> = titled ? titled.titles : item as Vector.<Title>;

        if (!titles || !titles.length) {
            return "";
        }

        for each (var title:Title in titles) {
            if (title.type == TitleType.MAIN) {
                return title.text;
            }
        }

        for each (title in titles) {
            if (title.type == TitleType.OFFICIAL && title.lang == "en") {
                return title.text;
            }
        }

        for each (title in titles) {
            if (title.lang == "en") {
                return title.text;
            }
        }

        return (titles[0] as Title).text;
    }

    public static function getEnumLabel(item:Object, column:Object = null):String {
        var result:String = "";
        item = getProperty(item, column);
        if (item) {
            const propertyName:String = String(item).replace(/ /g, "_");
            const clazzName:String = getQualifiedClassName(item).split("::").pop();

            result = ResourceManager.getInstance().getString(clazzName, propertyName);
        }
        return result;
    }

    private static function getProperty(item:Object, column:Object):Object {
        if (column && column.hasOwnProperty("dataField")) {
            const dataField:String = String(column["dataField"]);
            if (dataField) {
                for each(var property:String in dataField.split(".")) {
                    if (!item || !item.hasOwnProperty(property)) {
                        break;
                    }
                    item = item[property];
                }
            }
        }
        return item;
    }
}
}
