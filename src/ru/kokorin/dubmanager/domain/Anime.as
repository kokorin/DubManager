package ru.kokorin.dubmanager.domain {
import mx.collections.ArrayCollection;

[Bindable]
[AStreamAlias("anime")]
public class Anime {
    [AStreamAsAttribute]
    [AStreamAlias("aid")]
    public var id:Number;

    [AStreamAlias("type")]
    [AStreamOrder(10)]
    public var type:AnimeType;

    [AStreamAlias("episodecount")]
    [AStreamOrder(20)]
    public var episodeCount:int;

    [AStreamAlias("startdate")]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    [AStreamOrder(30)]
    public var startDate:Date;

    [AStreamAlias("enddate")]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    [AStreamOrder(40)]
    public var endDate:Date;

    //----Dub field-----
    [AStreamAlias("update")]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    [AStreamOrder(45)]
    public var update:Date;

    [AStreamAlias("titles")]
    [AStreamOrder(50)]
    public var titles:Vector.<Title>;

    [AStreamAlias("relatedanime")]
    [AStreamOrder(60)]
    [AStreamMapper("ru.kokorin.dubmanager.xml.RelatedAnimeCollectionMapper", params="anime")]
    [ArrayElementType("ru.kokorin.dubmanager.domain.RelatedAnime")]
    public var relatedAnimeList:ArrayCollection;

    [AStreamAlias("description")]
    [AStreamOrder(70)]
    public var description:String;

    [AStreamAlias("picture")]
    [AStreamOrder(80)]
    public var picture:String;

    [AStreamAlias("episodes")]
    [AStreamOrder(90)]
    [ArrayElementType("ru.kokorin.dubmanager.domain.Episode")]
    public var episodes:ArrayCollection;

    //------Dub related data--------
    [AStreamAlias("Status")]
    [AStreamOrder(1001)]
    public var status:AnimeStatus = AnimeStatus.NOT_STARTED;

    [AStreamAlias("VideoURL")]
    [AStreamOrder(1020)]
    public var videoURL:String = "";

    [AStreamAlias("SubtitleURL")]
    [AStreamOrder(1030)]
    public var subtitleURL:String = "";

    [AStreamAlias("TimingURL")]
    [AStreamOrder(1040)]
    public var timingBy:String = "";

    [AStreamAlias("SoundBy")]
    [AStreamOrder(1050)]
    public var soundBy:String = "";

    [AStreamAlias("IntegrationBy")]
    [AStreamOrder(1060)]
    public var integrationBy:String = "";

    [AStreamAlias("Comment")]
    [AStreamOrder(1070)]
    public var comment:String = "";

    //Force include
    [ArrayElementType("ru.kokorin.astream.converter.DateConverter")]
    [ArrayElementType("ru.kokorin.dubmanager.xml.RelatedAnimeCollectionMapper")]
    public function Anime() {
    }
}
}
