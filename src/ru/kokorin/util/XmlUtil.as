package ru.kokorin.util {
public class XmlUtil {
    public static function replaceXmlNamespace(xmlString:String):String {
        if (xmlString) {
            xmlString = xmlString.split(" xml:").join(" xml_");
            //xmlString = xmlString.replace(/ xml:/g, " xml_");
        }
        return xmlString;
    }
}
}
