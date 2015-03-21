package ru.kokorin.util {
public class PropertyUtil {

    public static function getProperty(item:Object, columnOrString:Object):Object {
        var dataPath:String = columnOrString as String;
        if (!dataPath) {
            const column:Object = columnOrString;
            if (column && column.hasOwnProperty("dataField")) {
                dataPath = String(column["dataField"]);
            }
        }

        if (dataPath) {
            for each(var property:String in dataPath.split(".")) {
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
