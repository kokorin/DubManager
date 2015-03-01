package ru.kokorin.dubmanager.domain {

[Bindable]
[AStreamAlias("title")]
[AStreamMapper(mapperType="ru.kokorin.astream.mapper.TextNodeMapper", params="text")]
public class Title {
    [AStreamOrder(10)]
    public var type:TitleType;

    [AStreamAlias("xml_lang")]
    [AStreamOrder(20)]
    public var lang:String;

    public var text:String;

    //Force include TextNodeMapper
    [ArrayElementType("ru.kokorin.astream.mapper.TextNodeMapper")]
    public function Title() {
    }
}
}
