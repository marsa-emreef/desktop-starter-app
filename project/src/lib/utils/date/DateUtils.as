package lib.utils.date
{
	
	import lib.utils._;
	
	import mx.olap.aggregators.MinAggregator;
	
	import spark.formatters.DateTimeFormatter;
	
	public class DateUtils
	{
		public function DateUtils()
		{
			
		}
		
		/**
		 * constant variable storing total number of milisecond in a hour
		 */
		private static const MILISECOND_IN_A_HOUR:Number=3600000;
		private static const MILISECOND_IN_A_MINUTE:Number=60000;
		/**
		 * Constant variable storing total number of milisecond in a day.
		 */
		private static const ONE_DAY_TIME:Number=MILISECOND_IN_A_HOUR * 24;
		private static const ONE_HOUR_TIME:Number=MILISECOND_IN_A_MINUTE * 60;
		private static const ONE_MINUTE_TIME:Number=MILISECOND_IN_A_MINUTE;
		
		private static var formatter_ddMMMyyyy:DateTimeFormatter=new DateTimeFormatter();
		formatter_ddMMMyyyy.dateTimePattern="dd-MMM-yyyy";
		
		private static var formatter_ddMMMyyyyHHmm:DateTimeFormatter=new DateTimeFormatter();
		formatter_ddMMMyyyyHHmm.dateTimePattern="dd-MMM-yyyy HH:mm";
		
		private static var formatter_HHmm:DateTimeFormatter=new DateTimeFormatter();
		formatter_HHmm.dateTimePattern="HH:mm";
		
		private static var formatter_HHmmss:DateTimeFormatter=new DateTimeFormatter();
		formatter_HHmmss.dateTimePattern="HH:mm:ss";
		
		private static var formatter_ddMMMyyyyTHHmm:DateTimeFormatter=new DateTimeFormatter();
		formatter_ddMMMyyyyTHHmm.dateTimePattern="dd-MMM-yyyyTHH:mm";
	
		public static function formatDD_MMM_YYYY(dateOrString:*):String{
			if(dateOrString == null){
				return '';
			}
			var date:Date = dateOrString is Date ? dateOrString : toDate(dateOrString);
			return formatter_ddMMMyyyy.format(date).toUpperCase();
		}
		
		public static function formatHH_MM(dateOrString:*):String{
			if(dateOrString == null){
				return '';
			}
			var date:Date = dateOrString is Date ? dateOrString : toDate(dateOrString);
			return formatter_HHmm.format(date).toUpperCase();
		}
		
		public static function formatHH_MM_SS(dateOrString:*):String{
			if(dateOrString == null){
				return '';
			}
			var date:Date = dateOrString is Date ? dateOrString : toDate(dateOrString);
			return formatter_HHmmss.format(date).toUpperCase();
		}
		
		
		
		public static function formatDD_MMM_YYYY_HH_MM(dateOrString:*):String{
			if(dateOrString == null){
				return '';
			}
			var date:Date = dateOrString is Date ? dateOrString : toDate(dateOrString);
			return formatter_ddMMMyyyyHHmm.format(date).toUpperCase();
		}
		
		
		public static function toDate(dateString:*):Date {
			if(dateString is Date){
				return dateString;
			}
			if(dateString is String && dateString != null && dateString.length > 0){
				var year:Number=parseInt(dateString.substr(0, 4));
				var month:Number=parseInt(dateString.substr(5, 2)) - 1;
				var date:Number=parseInt(dateString.substr(8, 2));
				var hours:Number=parseInt(dateString.substr(11, 2));
				var minutes:Number=parseInt(dateString.substr(14, 2));
				var seconds:Number=parseInt(dateString.substr(17, 2));
				return new Date(year, month, date, hours, minutes, seconds);	
			}
			return null; 
		}
		
		public static function toString(date:Date):String {
			if(date != null){
				var text:String = date.fullYear+'-'+(_.pad('00',(date.month+1).toString()))+'-'+_.pad('00',(date.date).toString())+'T'+ _.pad('00',(date.hours).toString())+':'+_.pad('00',(date.minutes).toString())+':'+_.pad('00',(date.seconds).toString()); 
				return text;
					
			}
			return null;
		}
		
		public static function dateAdd(datepart:DatePart, number:Number, dateOrString:*):Date
		{
			var date:Date = toDate(dateOrString);
			
			var returnDate:Date = null;
			
			if(date == null || isNaN(number)){
				return null;
			}
				
			switch(datepart)
			{
				case DatePart.YEAR:
				{
					returnDate = new Date(date.fullYear + number,date.month, date.date, date.hours, date.minutes);
					break;
				}
				case DatePart.MONTH:
				{
					returnDate = new Date(date.fullYear ,date.month + number, date.date, date.hours, date.minutes);
					break;
				}	
				case DatePart.DAY:
				{
					returnDate = new Date(date.fullYear ,date.month , date.date + number, date.hours, date.minutes);
					break;
				}	
				case DatePart.HOUR:
				{
					returnDate = new Date(date.fullYear ,date.month , date.date, date.hours + number, date.minutes);
					break;
				}
				case DatePart.MINUTE:
				{
					returnDate = new Date(date.fullYear ,date.month , date.date, date.hours, date.minutes + number);
					break;
				}	
				case DatePart.SECOND:
				{
					returnDate = new Date(date.fullYear ,date.month , date.date , date.hours, date.minutes, date.seconds + number);
					break;
				}
				default:
				{
					return returnDate;
				}
			}
			return returnDate;
		}
		
		/**
		 * Function to find the difference between dateTime, and convert the result in TAMMS format.
		 * @param dateFrom instance of starting date time.
		 * @param dateTo instance of ending date time
		 * @return the difference in tamms format.
		 *
		 */
		public static function diffToTamms(dateFrom:*, dateTo:*):Number {
			dateFrom = toDate(dateFrom);
			dateTo = toDate(dateTo);
			var timeInMinutes:Number = diffToMinutes(dateFrom,dateTo);
			if (!isNaN(timeInMinutes)) {
				var hourPart:Number = Math.floor(timeInMinutes/60);
				var minPart:Number =  (timeInMinutes - (hourPart*60));
				var timeInTamms:Number = hourPart + (Math.ceil(minPart /6)) / 10;
				return timeInTamms;
			}
			return NaN;
		}
		
		public static function diffToHoursMinutes(dateFrom:*, dateTo:*):String{
			dateFrom = toDate(dateFrom);
			dateTo = toDate(dateTo);
			if (dateFrom && dateTo) {
				return diffToHoursMinutesFromMS(Math.round((dateTo.time - dateFrom.time) / ONE_MINUTE_TIME));
			}
			return null;
		}
		
		public static function diffToHoursMinutesFromMS(diff:Number):String{
			var diffInMS:Number = diff * ONE_MINUTE_TIME;
			var minutes:Number = Math.round((diffInMS % ONE_HOUR_TIME) / ONE_MINUTE_TIME);
			var hours:Number =  Math.floor(diffInMS / ONE_HOUR_TIME);
			return hours+':'+_.pad('00',minutes.toString());
		}
		
		public static function diffFromHoursMinutesToMS(diff:String):Number{
			var diffs:Array = diff.split(':');
			var hours:Number = parseInt(diffs[0]);
			var minutes:Number = diffs.length > 1 ? parseInt(diffs[1]) : 0;
			return (hours * 60)  + minutes;
		}
		
		public static function diffToDays(dateFrom:*, dateTo:*):Number {
			dateFrom = toDate(dateFrom);
			var tmpDateTo:Date = toDate(dateTo);
			dateTo = new Date(tmpDateTo.fullYear,tmpDateTo.month,tmpDateTo.date,24,59,59,0);
			if (dateFrom && dateTo) {
				var dateDiffTime:Number=dateTo.time - dateFrom.time;
				var difference:Number=dateDiffTime / ONE_DAY_TIME;
				difference = Math.floor(difference);
				return difference;
			}
			return NaN;
		}
		
		public static function diffToHours(dateFrom:*, dateTo:*):Number {
			dateFrom = toDate(dateFrom);
			dateTo = toDate(dateTo);
			if (dateFrom && dateTo) {
				var dateDiffTime:Number=dateTo.time - dateFrom.time;
				var difference:Number=dateDiffTime / ONE_HOUR_TIME;
				difference=Math.round(difference);
				return difference;
			}
			return NaN;
		}
		public static function diffToMinutes(dateFrom:*, dateTo:*):Number {
			dateFrom = toDate(dateFrom);
			dateTo = toDate(dateTo);
			if (dateFrom && dateTo) {
				var dateDiffTime:Number=dateTo.time - dateFrom.time;
				var difference:Number=dateDiffTime / ONE_MINUTE_TIME;
				difference=Math.round(difference);
				return difference;
			}
			return NaN;
		}
		
		public static function combineDateTime(date:Date,time:Date):Date{
			if(date && time){
				return new Date(date.fullYear,date.month,date.date,time.hours,time.minutes,time.seconds);
			}
			return null;
		}
		
		public static function before(dateBefore:*,dateAfter:*):Boolean{
			dateBefore= toDate(dateBefore);
			dateAfter = toDate(dateAfter);
			return dateBefore < dateAfter;
		}
		
		public static function after(dateAfter:*,dateBefore:*):Boolean{
			dateBefore= toDate(dateBefore);
			dateAfter = toDate(dateAfter);
			return dateBefore < dateAfter;
		}
		
		public static function isOverlap(begin:Date,end:Date,beginTwo:Date,endTwo:Date):Boolean{
			begin= toDate(begin);
			end = toDate(end);
			
			beginTwo= toDate(beginTwo);
			endTwo = toDate(endTwo);
			
			if(begin <= beginTwo && beginTwo <= end){
				return true;
			}
			if(begin <= endTwo && endTwo <= end){
				return true;
			}
			if(beginTwo <= begin && begin <= endTwo){
				return true;
			}
			if(beginTwo <= end && end <= endTwo){
				return true;
			}
			return false;
		}
	}
}