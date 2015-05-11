package ru.kokorin.dubmanager.command {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.utils.getQualifiedClassName;

import mx.logging.ILogger;
import mx.utils.URLUtil;

import ru.kokorin.util.LogUtil;

public class UrlCommand {
    public var callback:Function;
    private var rootUrl:String;

    protected const LOGGER:ILogger = LogUtil.getLogger(this);

    public function UrlCommand(rootUrl:String) {
        this.rootUrl = rootUrl;
    }

    public function load(url:String, method:String = URLRequestMethod.GET, data:Object = null,
                         awaitsBinary:Boolean = false):void {
        url = URLUtil.getFullURL(rootUrl, url);
        const urlRequest:URLRequest = createRequest(url, method, data);
        const urlLoader:URLLoader = new URLLoader();
        if (awaitsBinary) {
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
        }
        urlLoader.addEventListener(Event.COMPLETE, onLoadResult);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
        urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadError);

        LOGGER.info("loading from: {0}", url);
        urlLoader.load(urlRequest);
    }

    protected function createRequest(url:String, method:String, data:Object):URLRequest {
        const result:URLRequest = new URLRequest(url);
        result.method = method;
        result.data = data;
        return result;
    }

    private function onLoadResult(event:Event):void {
        const urlLoader:URLLoader = event.target as URLLoader;
        const result:Object = handleResult(urlLoader.data);
        LOGGER.info("Loaded {0} {1} bytes", getQualifiedClassName(result), urlLoader.bytesLoaded);
        callback(result);
    }

    private function onLoadError(event:ErrorEvent):void {
        LOGGER.error(event.text);
        const error:Error = handleError(event);
        callback(error);
    }

    protected function handleResult(data:Object):Object {
        return data;
    }

    protected function handleError(event:ErrorEvent):Error {
        return new Error(event.text, event.errorID);
    }
}
}
