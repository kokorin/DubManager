package ru.kokorin.dubmanager.domain {
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

[Bindable]
[AStreamAlias("Serial")]
public class Serial extends EventDispatcher {
    [AStreamOrder(10)]
    public var name:String = "";
    [AStreamOrder(20)]
    public var type:SerialType;
    [AStreamOrder(30)]
    public var status:SerialStatus = SerialStatus.NOT_STARTED;
    [AStreamOrder(40)]
    public var episodesCount:Number = 0;
    [AStreamOrder(50)]
    public var videoURL:String = "";
    [AStreamOrder(60)]
    public var subtitleURL:String = "";
    [AStreamOrder(70)]
    public var timingBy:String = "";
    [AStreamOrder(80)]
    public var soundBy:String = "";
    [AStreamOrder(90)]
    public var integrationBy:String = "";
    [AStreamOrder(100)]
    public var comment:String = "";
    [AStreamOrder(110)]
    [ArrayElementType("ru.kokorin.dubmanager.domain.Episode")]
    public var episodes:ArrayCollection;
}
}