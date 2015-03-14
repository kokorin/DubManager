package ru.kokorin.dubmanager.component.anime {
import org.spicefactory.lib.collection.Map;

import ru.kokorin.component.SelectPM;
import ru.kokorin.dubmanager.domain.Anime;
import ru.kokorin.dubmanager.domain.Title;

public class AnimeSelectPM extends SelectPM {
    private const matchMap:Map = new Map();

    override public function set filterText(value:String):void {
        super.filterText = value;
        matchMap.removeAll();
    }

    override protected function filterFunction(item:Object):Boolean {
        if (!filterWords || filterWords.length == 0) {
            return true;
        }
        const anime:Anime = item as Anime;
        if (!anime) {
            return true;
        }

        const match:Number = getMatchWeight(anime, filterWords, matchMap);
        return match > 0;
    }

    override protected function compareFunction(item1:Object, item2:Object, fields:Array = null):int {
        const anime1:Anime = item1 as Anime;
        const anime2:Anime = item2 as Anime;
        var match1:Number = 0;
        var match2:Number = 0;

        if (filterWords) {
            if (anime1) {
                match1 = getMatchWeight(anime1, filterWords, matchMap);
            }
            if (anime2) {
                match2 = getMatchWeight(anime2, filterWords, matchMap);
            }
        }

        if (match1 > match2) {
            return -1;
        }
        if (match1 == match2) {
            return 0;
        }
        return 1;
    }

    private static function getMatchWeight(anime:Anime, words:Array, map:Map):Number {
        var result:Number = 0;

        if (!map.containsKey(anime.id)) {
            if (anime.titles) {
                for each (var title:Title in anime.titles) {
                    if (!title.text) {
                        continue;
                    }
                    var text:String = title.text.toLowerCase();

                    for each (var word:String in words) {
                        if (text.indexOf(word) != -1) {
                            result++;
                        }
                    }
                }
                result = result/anime.titles.length;
            }

            map.put(anime.id, result);
        } else {
            result = map.get(anime.id);
        }

        return result;
    }

}
}
