package ru.kokorin.dubmanager.xml {
import ru.kokorin.astream.converter.Converter;

public class ErrorConverter implements Converter {
    public function ErrorConverter() {
    }

    public function fromString(string:String):Object {
        return new Error(string);
    }

    public function toString(value:Object):String {
        const error:Error = value as Error;
        if (error) {
            return String(error.message);
        }
        return null;
    }
}
}
