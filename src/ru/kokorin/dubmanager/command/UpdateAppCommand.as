package ru.kokorin.dubmanager.command {
import com.adobe.serialization.json.JSON;

import flash.desktop.NativeApplication;
import flash.desktop.Updater;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;

import mx.events.CloseEvent;

import mx.resources.ResourceManager;

import spark.components.Alert;

/**
 * Command analyzes github repository and downloads the latest update available
 * @see https://developer.github.com/v3/repos/releases/
 * @see https://api.github.com/repos/kokorin/AStream/releases
 */
public class UpdateAppCommand extends BaseCommand {
    public var callback:Function;
    private var currentVersion:String;
    private var updateUrl:String;
    private var updateVersion:String;

    public function execute(event:Event):void {
        LOGGER.debug("Updating application...");

        const xml:XML = NativeApplication.nativeApplication.applicationDescriptor;
        const ns:Namespace = xml.namespace();
        currentVersion = String(xml.ns::versionNumber);
        LOGGER.debug("Current version: {0}", currentVersion);


        const urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, onLoadReleasesComplete);
        urlLoader.load(new URLRequest("https://api.github.com/repos/kokorin/DubManager/releases"));
    }

    private function onLoadReleasesComplete(event:Event):void {
        const data:Object = (event.target as URLLoader).data;
        //use JSON from as3corelib to support AIR 2.6
        const releases:Array = com.adobe.serialization.json.JSON.decode(String(data)) as Array;

        var updateWeight:int = getVersionWeight(currentVersion);
        for each (var release:Object in releases) {
            var releaseVersion:String = String(release.tag_name);
            var releaseWeight:int = getVersionWeight(releaseVersion);
            if (updateWeight < releaseWeight) {
                updateVersion = releaseVersion;
                updateWeight = releaseWeight;
                for each (var asset:Object in release.assets) {
                    //TODO handle case of multiple assets
                    updateUrl = String(asset.browser_download_url);
                    break;
                }
            }
        }

        if (updateUrl) {
            LOGGER.info("Update {0} found at {1}", updateVersion, updateUrl);
            var title:String = ResourceManager.getInstance().getString("component", "update.title");
            var question:String = ResourceManager.getInstance().getString("component", "update.question", [updateVersion]);
            Alert.show(question, title, Alert.YES | Alert.NO, null, onAlertClose);
            return;
        }
        callback(false);
    }

    private function onAlertClose(event:CloseEvent):void {
        if (event.detail != Alert.YES) {
            callback();
            return;
        }
        LOGGER.debug("Loading update");
        const urlLoader:URLLoader = new URLLoader();
        urlLoader.addEventListener(Event.COMPLETE, onLoadUpdateComplete);
        urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
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
            (new Updater()).update(installationFile, updateVersion);
        }
        callback(true);
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
