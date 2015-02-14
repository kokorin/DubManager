package ru.kokorin.util {
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.logging.Log;

public class LogUtil {
    public static function getLogger(object:Object):ILogger {
        const category:String = getQualifiedClassName(object).replace("::", ".");
        return Log.getLogger(category);
    }
}
}
