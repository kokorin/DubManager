package ru.kokorin.dubmanager.domain {
[AStreamMapper("ru.kokorin.astream.mapper.TextNodeMapper", params="name")]
public class RelatedAnime {
    public var aid:Number
    public var type:RelationType;
    public var name:String;
}
}
