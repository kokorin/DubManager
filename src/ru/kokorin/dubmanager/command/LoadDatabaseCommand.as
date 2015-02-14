package ru.kokorin.dubmanager.command {
import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.filesystem.File;

import mx.collections.ArrayCollection;

import ru.kokorin.dubmanager.domain.Episode;
import ru.kokorin.dubmanager.domain.EpisodeStatus;
import ru.kokorin.dubmanager.domain.Serial;
import ru.kokorin.dubmanager.domain.SerialStatus;

/**
 * This command is needed only for backward compatibility. *
 */
public class LoadDatabaseCommand extends BaseCommand {
    private static const SELECT_ALL_ITEMS:String = "SELECT * FROM DubItem";
    private static const SELECT_SUBITEMS_FOR_ITEM:String = "SELECT * FROM DubSubItem WHERE dubItemID = :dubItemID";

    public function execute(event:Event):Vector.<Serial> {
        var result:Vector.<Serial>;
        try {
            const dbFile:File = File.applicationStorageDirectory.resolvePath("dub-manager.db");
            //if (dbFile.exists)
            const conn:SQLConnection = new SQLConnection();
            conn.open(dbFile);

            const itemsStm:SQLStatement = new SQLStatement();
            itemsStm.sqlConnection = conn;
            itemsStm.text = SELECT_ALL_ITEMS;
            itemsStm.execute();

            const items:Array = itemsStm.getResult().data;

            for each(var item:Object in items) {
                var serial:Serial = parseSerial(item);
                if (!result) {
                    result = new Vector.<Serial>();
                }
                result.push(serial);

                var subItemsStm:SQLStatement = new SQLStatement();
                subItemsStm.sqlConnection = conn;
                subItemsStm.text = SELECT_SUBITEMS_FOR_ITEM;
                subItemsStm.parameters[":dubItemID"] = item.id;
                subItemsStm.execute();
                var subitems:Array = subItemsStm.getResult().data;

                for each(var subitem:Object in subitems) {
                    if (!serial.episodes) {
                        serial.episodes = new ArrayCollection();
                    }
                    serial.episodes.addItem(parseEpisode(subitem));
                }
            }

        }
        return result;
    }

    private static function parseSerial(item:Object):Serial {
        const result:Serial = new Serial();

        result.name = String(item.name);
        result.type = String(item.type);

        const status:String = String(item.status);
        if (status == "notStarted") {
            result.status = SerialStatus.NOT_STARTED;
        } else if (status == "started") {
            result.status = SerialStatus.IN_PROCESS;
        } else if (status == "finished") {
            result.status = SerialStatus.COMPLETE;
        }

        result.episodesCount = Number(item.totalSubItems);
        result.videoURL = String(item.videoURL);
        result.subtitleURL = String(item.subtitleURL);
        result.timingBy = String(item.timingBy);
        result.soundBy = String(item.soundBy);
        result.integrationBy = String(item.integrationBy);
        result.comment = String(item.comment);

        return result;
    }

    private static function parseEpisode(item:Object):Episode {
        const result:Episode = new Episode();

        result.number = Number(item.number);

        const status:String = String(item.status);
        if (status == "notStarted") {
            result.status = EpisodeStatus.NOT_STARTED;
        } else if (status == "finished") {
            result.status = EpisodeStatus.COMPLETE;
        }

        result.date = item.date as Date;
        result.date = new Date(result.date);

        return result;
    }
}
}
