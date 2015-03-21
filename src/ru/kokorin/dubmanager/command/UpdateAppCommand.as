package ru.kokorin.dubmanager.command {
import com.adobe.serialization.json.JSON;

import flash.desktop.NativeApplication;
import flash.desktop.Updater;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import mx.events.CloseEvent;
import mx.logging.ILogger;

import mx.resources.ResourceManager;

import ru.kokorin.util.LogUtil;

import spark.components.Alert;

/**
 * Command analyzes github repository and downloads the latest update available
 * @see https://developer.github.com/v3/repos/releases/
 * @see https://api.github.com/repos/kokorin/AStream/releases
 */
public class UpdateAppCommand {
    public var callback:Function;

    private var updateUrl:String;
    private var updateVersion:String;
    private var loadReleasesInterval:uint = 0;

    private static const CURRENT_VERSION:String = getCurrentVersion();

    private static const LOGGER:ILogger = LogUtil.getLogger(UpdateAppCommand);


    public function execute(event:Event):void {
        LOGGER.debug("Current version: {0}", CURRENT_VERSION);

        if (!Updater.isSupported) {
            LOGGER.warn("Updater is NOT supported! Canceling update!");
            callback();
            return;
        }

        LOGGER.debug("Updating application...");

        loadReleasesInterval = setInterval(loadReleases, 60*60*1000);
        loadReleases();
    }

    private function loadReleases():void {
        const urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, onLoadReleasesComplete);
        urlLoader.load(new URLRequest("https://api.github.com/repos/kokorin/DubManager/releases"));
    }

    private function onLoadReleasesComplete(event:Event):void {
        const urlLoader:URLLoader = event.target as URLLoader;
        urlLoader.removeEventListener(Event.COMPLETE, onLoadReleasesComplete);

        const data:Object = urlLoader.data;
        //use JSON from as3corelib to support AIR 2.6
        const releases:Array = com.adobe.serialization.json.JSON.decode(String(data)) as Array;

        var updateWeight:int = getVersionWeight(CURRENT_VERSION);
        var newUrl:String = null;
        var newVersion:String = null;

        for each (var release:Object in releases) {
            var releaseVersion:String = String(release.tag_name);
            var releaseWeight:int = getVersionWeight(releaseVersion);
            if (updateWeight < releaseWeight) {
                newVersion = releaseVersion;
                updateWeight = releaseWeight;
                for each (var asset:Object in release.assets) {
                    //how to handle case of multiple assets?
                    newUrl = String(asset.browser_download_url);
                    break;
                }
            }
        }

        const ask:Boolean = !this.updateUrl && newUrl;

        this.updateUrl = newUrl;
        this.updateVersion = newVersion;

        if (ask) {
            askUpdate();
        }
    }

    private function askUpdate():void {
        if (!updateUrl || !updateVersion) {
            return;
        }

        LOGGER.info("Asking to update to {0} : {1}", updateVersion, updateUrl);
        var title:String = ResourceManager.getInstance().getString("component", "update.title");
        var question:String = ResourceManager.getInstance().getString("component", "update.question", [updateVersion]);
        Alert.show(question, title, Alert.YES | Alert.NO | Alert.CANCEL, null, onAnswer);

    }

    private function onAnswer(event:CloseEvent):void {
        if (event.detail == Alert.NO) {
            LOGGER.debug("Answer: NO");
            setTimeout(askUpdate, 15*60*1000);
            return;
        }

        if (loadReleasesInterval) {
            clearInterval(loadReleasesInterval);
            loadReleasesInterval = 0;
        }

        if (event.detail == Alert.CANCEL) {
            LOGGER.debug("Answer: CANCEL");
            callback();
            return;
        }

        LOGGER.debug("Answer: YES. Loading update");
        const urlLoader:URLLoader = new URLLoader();
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

        urlLoader.addEventListener(Event.COMPLETE, onLoadUpdateComplete);
        urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadUpdateComplete);
        urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadUpdateComplete);

        urlLoader.load(new URLRequest(updateUrl));
    }

    private function onLoadUpdateComplete(event:Event):void {
        const data:Object = (event.target as URLLoader).data;
        const installationFile:File = File.createTempDirectory().resolvePath("DubManager.air");

        const stream:FileStream = new FileStream();
        stream.open(installationFile, FileMode.WRITE);
        stream.writeBytes(data as ByteArray);
        stream.close();

        if (Updater.isSupported) {
            const updater:Updater = new Updater();
            updater.update(installationFile, updateVersion);
        }
        callback(true);
    }

    private function onLoadUpdateError(event:ErrorEvent):void {
        LOGGER.error("Load error: {0}: {1}", event.errorID, event.text);
        callback(new Error(event.text, event.errorID));
    }

    private static function getCurrentVersion():String {
        const xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
        const ns:Namespace = xml.namespace();
        return String(xml.ns::versionNumber);
    }

    private static function getVersionWeight(version:String):int {
        const strings:Array = version.split(".");
        const weights:Array = new Array();
        for each (var str:String in strings) {
            weights.push(parseInt(str));
        }
        while (weights.length < 3) {
            weights.unshift(0);
        }
        return weights[0]*1000000 + weights[1]*1000 + weights[2];
    }

}
}
