package ru.kokorin.dubmanager.component.episode {
import ru.kokorin.component.BasePM;
import ru.kokorin.dubmanager.domain.Episode;

public class EpisodePM extends BasePM {
    public function EpisodePM() {
        super(Episode);
    }

    [Bindable(event="open")]
    [Bindable(event="close")]
    public function get episode():Episode {
        return item as Episode;
    }
}
}
