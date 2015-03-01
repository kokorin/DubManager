package ru.kokorin.dubmanager.domain {
[Bindable]
[AStreamAlias("episode")]
public class Episode {
    [AStreamAsAttribute]
    [AStreamAlias("id")]
    [AStreamOrder(10)]
    public var id:Number;

    [AStreamAsAttribute]
    [AStreamAlias("update")]
    [AStreamOrder(10)]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    public var update:Date;

    [AStreamAlias("epno")]
    [AStreamOrder(10)]
    public var number:String;

    [AStreamAlias("airdate")]
    [AStreamOrder(20)]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    public var airDate:Date;

    [AStreamImplicit(itemName="title")]
    [AStreamOrder(30)]
    public var titles:Vector.<Title>;

    //-----Dub related data-------
    [AStreamAlias("Status")]
    [AStreamOrder(20)]
    public var status:EpisodeStatus = EpisodeStatus.NOT_STARTED;

    //Force include
    [ArrayElementType("ru.kokorin.astream.converter.DateConverter")]
    public function Episode() {
    }
}
}