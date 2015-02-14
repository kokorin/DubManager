package ru.kokorin.dubmanager.domain {
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;

[Bindable]
[AStreamAlias("Serial")]
public class Serial extends EventDispatcher {
    public var name:String = "";
    public var type:String;
    public var status:SerialStatus = SerialStatus.NOT_STARTED;
    public var episodes:ArrayCollection;
    public var episodesCount:Number = 0;
    public var videoURL:String = "";
    public var subtitleURL:String = "";
    public var timingBy:String = "";
    public var soundBy:String = "";
    public var integrationBy:String = "";
    public var comment:String = "";
}
}