package lib.component
{
	import lib.utils._;
	
	import spark.events.TextOperationEvent;

	public class NumberInTimeField extends NumberField
	{
		public function NumberInTimeField()
		{
			super();
			fractionalDigits = 2;
			decimalSeparator = ':';
		}
		
		override protected function beforePersistNumber(input:Number):Number{
			if(input){
				var inputString:String = input.toFixed(fractionalDigits);
				var decimalText:String = '0'+inputString.substring(inputString.indexOf('.'),inputString.length);
				var integer:Number = parseInt(inputString.substring(0,inputString.indexOf('.')));
				var number:Number = Math.round(parseFloat(decimalText) * 100);
				if(number >= 60){
					number = number - 60;
					++integer;
				}
				return parseFloat(integer+'.'+_.pad('00',number.toFixed(0))); 
			}
			return input;
		}
	}
}