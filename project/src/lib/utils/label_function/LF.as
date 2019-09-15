package lib.utils.label_function
{
	import lib.utils._;
	
	public class LF
	{
		public function LF()
		{
		}
		
		/*
		* templateFormatter eg : ({name}) {rank.label}
		* eg : ({itemCode.label@length=6@align=right@pad=0}) {itemCode.value}
		*/
		public static function template(template:String):Function{
			var params:Array = _.filter(_.map(template.split('{'),function(i:String):*{ return i.split('}')[0]}),function(text:String):Boolean{
				if(text && text.length>0){
					return true;
				}
				return false;
			});
			return function templateFunction(item:Object):String{
				return _.reduce(params,function(output:String,param:String,index:Number,source:Array):*{
					// now we need to split
					return output.replace('{'+param+'}',dataFields(item,param));
				},template);
			}
		}
		
		/*
		* templateFormatter eg : rank.label@length=6@align=right@pad=0
		*/
		private static function dataFields(item:*,dataFieldsChainWithFormat:String):*{
			var result:Object = item;
			var fieldsChainWithFormatArray:Array = dataFieldsChainWithFormat.split('@');
			var dataFields:Array = [];
			var length:Number = -1;
			var align:String = 'left';
			var pad:String = ' ';
			fieldsChainWithFormatArray.forEach(function(item:String,index:Number,array:Array):void{
				if(index == 0){
					dataFields = item.split('.');		
				}else{
					if(item.indexOf('length')>=0){
						length = parseInt(item.split('=')[1]);
					}
					if(item.indexOf('align')>=0){
						align = item.split('=')[1];
					}
					if(item.indexOf('pad')>=0){
						pad = item.split('=')[1];
					}
				}
			});
			for each (var dataField:String in dataFields) 
			{
				result = result && dataField in result && result[dataField] ?  result[dataField] : '';
			}
			
			if(length > 0){
				var padText:String = '';
				for (var i:int = 0; i < length; i++) 
				{
					padText += pad;	
				}
				result = _.pad(padText,result.toString(),align);
			}
			return result;
		}
	}
}