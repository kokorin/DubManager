package ru.kokorin.dubmanager.domain {
[Bindable]
[AStreamAlias("Episode")]
public class Episode {
    [AStreamOrder(10)]
    public var number:Number = 0;
    [AStreamOrder(20)]
    public var status:EpisodeStatus = EpisodeStatus.NOT_STARTED;
    [AStreamOrder(30)]
    public var date:Date;
}
}