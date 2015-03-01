package ru.kokorin.dubmanager.xml {
import org.spicefactory.lib.reflect.ClassInfo;

import ru.kokorin.astream.mapper.BaseMapper;
import ru.kokorin.astream.mapper.Mapper;
import ru.kokorin.astream.ref.AStreamRef;
import ru.kokorin.astream.util.TypeUtil;
import ru.kokorin.dubmanager.domain.RelatedAnime;

public class RelatedAnimeCollectionMapper extends BaseMapper {
    private const relatedAnimeClassInfo:ClassInfo = ClassInfo.forClass(RelatedAnime);
    private var relatedAnimeTagName:String;
    private var relatedAnimeMapper:Mapper;

    public function RelatedAnimeCollectionMapper(classInfo:ClassInfo, relatedAnimeTagName:String) {
        super(classInfo);
        this.relatedAnimeTagName = relatedAnimeTagName;
    }

    override protected function fillXML(instance:Object, xml:XML, ref:AStreamRef):void {
        super.fillXML(instance, xml, ref);

        TypeUtil.forEachInCollection(instance,
                function (itemValue:Object, i:int, collection:Object):void {
                    const itemResult:XML = relatedAnimeMapper.toXML(itemValue, ref, relatedAnimeTagName);
                    xml.appendChild(itemResult);
                }
        );
    }

    override protected function fillObject(instance:Object, xml:XML, deref:AStreamRef):void {
        super.fillObject(instance, xml, deref);

        const items:Array = new Array();
        for each (var itemXML:XML in xml.elements()) {
            var itemValue:Object = relatedAnimeMapper.fromXML(itemXML, deref);
            items.push(itemValue);
        }
        TypeUtil.addToCollection(instance, items);
    }

    override public function reset():void {
        super.reset();
        relatedAnimeMapper = registry.getMapper(relatedAnimeClassInfo);
    }
}
}
