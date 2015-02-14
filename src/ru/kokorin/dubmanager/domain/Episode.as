package ru.kokorin.dubmanager.domain {
[Bindable]
[AStreamAlias("Episode")]
public class Episode {
    public var id:Number;
    public var number:Number = 0;
    public var status:EpisodeStatus = EpisodeStatus.NOT_STARTED;
    public var date:Date;
}
}