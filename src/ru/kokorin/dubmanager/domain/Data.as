package ru.kokorin.dubmanager.domain {
import mx.collections.ArrayCollection;

[AStreamAlias("data")]
[Bindable]
public class Data {
    [AStreamImplicit("anime")]
    [ArrayElementType("ru.kokorin.dubmanager.domain.Anime")]
    public var animeList:ArrayCollection;

    public function Data() {
    }
}
}
