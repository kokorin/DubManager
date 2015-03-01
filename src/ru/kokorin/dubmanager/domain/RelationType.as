package ru.kokorin.dubmanager.domain {
import as3.lang.Enum;

public class RelationType extends Enum {
    public static const SEQUEL:RelationType = new RelationType("Sequel");
    public static const PREQUEL:RelationType = new RelationType("Prequel");
    public static const SUMMARY:RelationType = new RelationType("Summary");
    public static const ALTERNATIVE_SETTING:RelationType = new RelationType("Alternative Setting");
    public static const CHARACTER:RelationType = new RelationType("Character");
    public static const SIDE_STORY:RelationType = new RelationType("Side Story");
    public static const OTHER:RelationType = new RelationType("Other");

    public function RelationType(name:String) {
        super(name);
    }
}
}
