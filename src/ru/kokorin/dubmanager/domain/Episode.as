package ru.kokorin.dubmanager.domain {
[Bindable]
[AStreamAlias("episode")]
public class Episode implements ITitled{
    [AStreamAsAttribute]
    [AStreamAlias("id")]
    [AStreamOrder(10)]
    public var id:Number;

    [AStreamAsAttribute]
    [AStreamAlias("update")]
    [AStreamOrder(10)]
    [AStreamConverter("ru.kokorin.astream.converter.DateConverter", params="yyyy-MM-dd")]
    public var update:Date;

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

    private var _epno:EpNo;

    //Force include
    [ArrayElementType("ru.kokorin.astream.converter.DateConverter")]
    [ArrayElementType("ru.kokorin.dubmanager.xml.EpNoConverter")]
    public function Episode() {
    }

    /**
     * @private
     */
    [AStreamAlias("epno")]
    [AStreamOrder(10)]
    [AStreamConverter("ru.kokorin.dubmanager.xml.EpNoConverter")]
    public function get epno():EpNo {
        if (!_epno) {
            _epno = new EpNo();
        }
        return _epno;
    }

    public function set epno(value:EpNo):void {
        if (!value) {
            value = new EpNo();
        }
        _epno = value;
    }

    [AStreamOmitField]
    public function get type():EpisodeType {
        return epno.type;
    }

    public function set type(value:EpisodeType):void {
        epno.type = value;
    }


    [AStreamOmitField]
    public function get number():int {
        return epno.number;
    }

    public function set number(value:int):void {
        epno.number = value;
    }
}
}