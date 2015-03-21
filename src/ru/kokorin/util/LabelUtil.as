package ru.kokorin.util {
import avmplus.getQualifiedClassName;

import mx.resources.ResourceManager;

import ru.kokorin.dubmanager.domain.ITitled;
import ru.kokorin.dubmanager.domain.Title;
import ru.kokorin.dubmanager.domain.TitleType;
import ru.kokorin.util.PropertyUtil;

public class LabelUtil {
    //TODO data binding will not update label function on locale change
    public static function getTitle(item:Object, column:Object = null):String {
        item = PropertyUtil.getProperty(item, column);

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
        item = PropertyUtil.getProperty(item, column);
        if (item) {
            const propertyName:String = String(item).replace(/ /g, "_");
            const clazzName:String = getQualifiedClassName(item).split("::").pop();

            result = ResourceManager.getInstance().getString(clazzName, propertyName);
        }
        if (!result) {
            result = String(item);
        }
        return result;
    }
}
}
