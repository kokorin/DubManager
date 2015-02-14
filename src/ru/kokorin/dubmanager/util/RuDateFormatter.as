package ru.kokorin.dubmanager.util
{
	import mx.formatters.IFormatter;
	
	public class RuDateFormatter implements IFormatter
	{
		private static const DAYS:Array = ["Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"];
		private static const MONTHS:Array = ["января", "февраля", "мартф", "апреля", "мая", "июня", "июля", "августф", "сентября", "окртября", "ноября", "декабря"];
		
		public function RuDateFormatter(){
		}
		
		public function format(value:Object):String{
			var d:Date = value as Date;
			if(d){
				return DAYS[d.day] + ", " + d.date + "."+(d.month+1)+"." + d.fullYear;
			}
			return "";
		}
	}
}