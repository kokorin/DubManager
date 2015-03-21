package ru.kokorin.dubmanager.xml {
import org.spicefactory.lib.collection.Map;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;

import ru.kokorin.astream.converter.Converter;
import ru.kokorin.dubmanager.domain.EpNo;
import ru.kokorin.dubmanager.domain.EpisodeType;

public class EpNoConverter implements Converter {
    private const types:Map = new Map();
    private static const ZERO_CODE:Number = "0".charCodeAt(0);
    private static const NINE_CODE:Number = "9".charCodeAt(0);

    public function EpNoConverter() {
        const typeInfo:ClassInfo = ClassInfo.forClass(EpisodeType);

        for each (var property:Property in typeInfo.getStaticProperties()) {
            var type:EpisodeType = property.getValue(null) as EpisodeType;
            if (type) {
                types.put(type.prefix, type);
            }
        }
    }

    public function fromString(string:String):Object {
        const result:EpNo = new EpNo();

        var prefix:String = null;
        var code:Number = string.charCodeAt(0);
        if (code >= ZERO_CODE && code <= NINE_CODE) {
            prefix = "";
        } else {
            prefix = string.charAt(0);
            string = string.substring(1);
        }

        result.type = types.get(prefix) as EpisodeType;
        result.number = parseInt(string);

        return result;
    }

    public function toString(value:Object):String {
        var result:String = null;
        const epno:EpNo = value as EpNo;
        if (epno) {
            if (epno.type) {
                result = epno.type.prefix + epno.number;
            } else {
                result = String(epno.number);
            }
        }
        return result;
    }
}
}
