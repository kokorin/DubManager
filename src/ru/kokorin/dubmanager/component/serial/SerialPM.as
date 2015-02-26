package ru.kokorin.dubmanager.component.serial {
import mx.collections.ArrayCollection;

import ru.kokorin.component.BasePM;
import ru.kokorin.dubmanager.domain.Serial;

public class SerialPM extends BasePM {
    public function SerialPM() {
        super(Serial);
    }

    [Bindable(event="open")]
    [Bindable(event="close")]
    public function get serial():Serial {
        return item as Serial;
    }

    public function saveEpisode(episode:Object, original:Object):void {
        if (!serial.episodes) {
            serial.episodes = new ArrayCollection();
        }

        const index:int = serial.episodes.getItemIndex(original);
        if (index == -1) {
            serial.episodes.addItem(episode);
        } else {
            serial.episodes.setItemAt(episode, index);
        }
    }

    public function removeEpisode(episode:Object):void {
        if (!serial.episodes) {
            return;
        }

        const index:int = serial.episodes.getItemIndex(episode);
        if (index != -1) {
            serial.episodes.removeItemAt(index);
        }
    }
}
}
