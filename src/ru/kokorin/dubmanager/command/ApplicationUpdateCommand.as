package ru.kokorin.dubmanager.command {
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * Command analyzes github repository and downloads the latest update available
 * @see https://developer.github.com/v3/repos/releases/
 * @see https://api.github.com/repos/kokorin/AStream/releases
 */
public class ApplicationUpdateCommand extends BaseCommand {
    public var callback:Function;
    private var currentVersion:String;

    public function execute(event:Event):void {
        LOGGER.debug("Updating application...")

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
        const releases:Array = JSON.parse(String(data)) as Array;

        var updateWeight:int = getVersionWeight(currentVersion);
        var updateUrl:String = null;
        var updateVersion:String = null;
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
            //TODO implement downloading of update
        }
    }

    private static function getVersionWeight(version:String):int {
        const nums:Array = version.split(".").map(parseInt);
        while (nums.length < 3) {
            nums.unshift(0);
        }
        return nums[0]*1000000 + nums[1]*1000 + nums[2];
    }

}
}
