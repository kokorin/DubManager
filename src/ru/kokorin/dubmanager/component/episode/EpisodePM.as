package ru.kokorin.dubmanager.component.episode {
import ru.kokorin.component.EditPM;
import ru.kokorin.dubmanager.domain.Episode;

public class EpisodePM extends EditPM {
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
