package ru.kokorin.util {
import mx.utils.ObjectUtil;

import ru.kokorin.dubmanager.domain.EpisodeType;

public class CompareUtil {
    public static function byTitle(item1:Object, item2:Object, columnOrString:Object = null):int {
        const title1:String = LabelUtil.getTitle(item1, columnOrString);
        const title2:String = LabelUtil.getTitle(item2, columnOrString);

        return ObjectUtil.stringCompare(title1, title2);
    }

    public static function byEpisodeType(item1:Object, item2:Object, columnOrString:Object = null):int {
        const type1:EpisodeType = PropertyUtil.getProperty(item1, columnOrString) as EpisodeType;
        const type2:EpisodeType = PropertyUtil.getProperty(item2, columnOrString) as EpisodeType;

        const code1:int = type1 ? type1.code : 0;
        const code2:int = type2 ? type2.code : 0;

        return ObjectUtil.numericCompare(code1, code2);
    }
}
}
