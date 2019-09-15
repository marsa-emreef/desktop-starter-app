package lib.utils.label_function
{
	import flashx.textLayout.events.ModelChange;
	
	import lib.utils._;
	import lib.utils.date.DateUtils;
	import lib.utils.date.FormatType;
	
	import mx.collections.IList;
	import mx.controls.Label;
	import mx.utils.ObjectUtil;
	
	import spark.components.gridClasses.GridColumn;
	import spark.formatters.NumberFormatter;
	
	public class LFGrid
	{
		public function LFGrid()
		{
		}
		
		public static function indexNumber(item:Object, column:GridColumn):String{
			var dataProvider:IList = _.getProperty(column,'grid.dataGrid.dataProvider');
			if(dataProvider){
				return ''+(dataProvider.getItemIndex(item) + 1);	
			}
			return '';
		}
		
		public static function combine(...functions):Function{
			return function _combinedFunction(item:Object, column:GridColumn):*{
				var param:String = column.dataField;
				var tmp:Object = _.toJson(item);
				if(param in item){
					tmp[param] = item[param];	
				}
				tmp = _.reduce(functions,function(current:*,next:Function,index:Number,source:Array):*{
					current[param] = next(current,column);
					return current;
				},tmp);
				return tmp[param];
			}	
		}
		
		public static function toUpperCase(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				return item[column.dataField].toString().toUpperCase();	
			}
			return '';
		}
		
		public static function stringToDateTime(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				var dateString:String = item[column.dataField].toString();
				return DateUtils.formatDD_MMM_YYYY_HH_MM(dateString);
			}
			return '';
		}
		
		public static function stringToDate(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				var dateString:String = item[column.dataField].toString();
				return DateUtils.formatDD_MMM_YYYY(dateString);
			}
			return '';
		}
		
		public static function mapOnEmpty(emptyValue:String):Function{
			return function stringToDate(item:Object, column:GridColumn):String{
				if(item && column && column.dataField && item[column.dataField]){
					return item[column.dataField];
				}
				if(item && column && column.dataField && item[column.dataField] == 0){
					return item[column.dataField];
				}
				return emptyValue;
			}
		}
		
		public static function replace(toBeReplaced:String,replacer:String):Function{
			return function text(item:Object, column:GridColumn):String{
				if(item && column && column.dataField && item[column.dataField]){
					var value:String = item[column.dataField];
					return  value.split(toBeReplaced).join(replacer);
				}
				return '';
			}
		}
		
		
		
		public static function stringToTime(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				var dateString:String = item[column.dataField].toString();
				return DateUtils.formatHH_MM(dateString);
			}
			return '';
		}
		
		public static function dataFields(dataFieldsChain:String):Function{
			var dataFields:Array = dataFieldsChain.split('.');
			return function _combinedFunction(item:Object, column:GridColumn):String{
				var result:Object = item;
				for each (var dataField:String in dataFields) 
				{
					result = result && dataField in result && result[dataField] ?  result[dataField] : null;
				}
				return result;
			}
		}
		
		public static function numberFormat(fractionalDigits:Number = 0):Function{
			var nf:NumberFormatter = new NumberFormatter();
			nf.fractionalDigits = fractionalDigits;
			return function _combinedFunction(item:Object, column:GridColumn):String{
				if(column.dataField in item){
					return nf.format(item[column.dataField]);	
				}
				return null;
			}
		}
		
		
		
		/*
		* templateFormatter eg : ({name}) {rank.label}
		* eg : ({itemCode.label@length=6@align=right@pad=0}) {itemCode.value}
		*/
		public static function template(dataFieldsChain:String):Function{
			var templateFunction:Function = LF.template(dataFieldsChain);
			return function _combinedFunction(item:Object, column:GridColumn):String{
				return templateFunction.apply(column,[item]);
			}
		}
		
		public static function minutesToHoursMinutesFormat(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				return DateUtils.diffToHoursMinutesFromMS(item[column.dataField]);	
			}
			return '';
		}
		
		public static function findSimilarItem(arrayOrCollection:*,matchingProperty:String):Function{
			var source:Array = _.toArray(arrayOrCollection);
			return function _findSimilarItem(item:Object, column:GridColumn):*{
				if(item && matchingProperty){
					var itemValue:* = item[column.dataField];
					var result:* = _.filterFirst(source,function(sourceItem:*):Boolean{
						return sourceItem && itemValue && sourceItem[matchingProperty].toString() == itemValue.toString();
					});
					return result;
				}
				return null;
			}
		}
		
		public static function stringify(item:Object, column:GridColumn):String{
			if(item && column && column.dataField && item[column.dataField]){
				return JSON.stringify(item[column.dataField]).split(',').join('');
			}
			return '';
		}
		
		
	}
}