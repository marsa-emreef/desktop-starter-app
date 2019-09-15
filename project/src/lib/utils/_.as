package lib.utils
{
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.describeType;
	
	import lib.utils.encryption.crypto.hash.MD5;
	import lib.utils.encryption.crypto.symmetric.AESKey;
	import lib.utils.encryption.crypto.symmetric.CBCMode;
	import lib.utils.encryption.crypto.symmetric.NullPad;
	import lib.utils.encryption.crypto.symmetric.PKCS5;
	import lib.utils.encryption.util.Base64;
	import lib.utils.encryption.util.Hex;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.utils.StringUtil;
	
	import spark.collections.Sort;
	import spark.collections.SortField;
	
	public class _
	{
		public function _()
		{
		}
		
		
		public static function map(arrayOrCollection:*,callback:Function):Array{
			var source:Array = toArray(arrayOrCollection);
			var result:Array = [];
			if(source != null && callback != null){
				source = source == null ? [] : source;
				for (var i:int = 0; i < source.length; i++) 
				{
					result.push(callback(source[i]));
				}
			}
			return result;
		}
		
		public static function toArray(arrayOrCollection:*):Array
		{
			if(arrayOrCollection is ArrayList){
				return (arrayOrCollection as ArrayList).source;
			}
			if(arrayOrCollection is ArrayCollection){
				return (arrayOrCollection as ArrayCollection).source;
			}
			if(arrayOrCollection is Array){
				return arrayOrCollection
			}
			return [];
		}
		
		/**
		 * 
		 * function callback(currentItem:any,nextItem:any,index:Number,array:Array):any
		 * 
		 */
		public static function reduce(arrayOrCollection:*,callback:Function,initialState:*):*{
			var array:Array = toArray(arrayOrCollection);
			if(array != null && callback != null){
				for (var i:int = 0; i < array.length; i++) 
				{
					var item:* = array[i];
					try{
						initialState = callback(initialState,item,i,array);
					}catch(err:Error){
						trace(err);
					}
				}
			}
			return initialState;
		};
		
		public static function filter(arrayOrCollection:*,callback:Function):Array{
			var source:Array = toArray(arrayOrCollection);
			var result:Array = [];
			if(source != null && callback != null){
				for (var i:int = 0; i < source.length; i++) 
				{
					if(callback(source[i])){
						result.push(source[i]);
					}
				}
			}
			return result;
		}
		
		public static function filterFirst(arrayOrCollection:*,callback:Function):*{
			var source:Array = toArray(arrayOrCollection);
			source = source == null ? [] : source;
			for (var i:int = 0; i < source.length; i++) 
			{
				if(callback(source[i])){
					return source[i];
				}
			}
			return null;
		}
		
		public static function filterFirstByParameter(arrayOrCollection:*,item:Object,parameter:String,returnNull:Boolean=true):*{
			if(item == null || arrayOrCollection == null){
				return null;
			}
			var source:Array = toArray(arrayOrCollection);
			for (var i:int = 0; i < source.length; i++) 
			{
				var sourceItem:* = source[i];
				if(parameter in sourceItem && sourceItem[parameter] != null && 
					parameter in item && item[parameter] != null &&
					sourceItem[parameter].toString() == item[parameter].toString()){
					return source[i];
				}
			}
			if(returnNull){
				return null;
			}
			return item;
		}
		
		/**
		 * 
		 * function callback(item:any):void
		 * 
		 */
		public static function forEach(arrayOrCollection:*, callback:Function):void
		{
			var array:Array = toArray(arrayOrCollection);
			if(array != null && callback != null){
				for (var i:int = 0; i < array.length; i++) 
				{
					callback(array[i]);
				}	
			}
		}
		
		public static function toCamelCase(json:*):*{
			if(json is Number){
				return json;
			}else if(json is Boolean){
				return json;
			}else if(json is Array){
				return _.map(json,function(item:*):*{
					return toCamelCase(item);
				});
			}else if(json is String){
				return json;
			}else if(json is Object){
				var result:Object = {};
				for (var param:String in json){
					var camelCaseParam:String = param.charAt(0).toLowerCase()+param.substr(1,param.length);
					var value:* = json[param];
					result[camelCaseParam] = toCamelCase(value);
				}
				return result;
			}else{
				return json;
			}
		}
		
		private static function defaultCopy(param:String,json:Object,model:Object,mirror:Object):*{
			try{
				if(param in mirror){
					if(_.isNotEmpty(json[param])){
						if(mirror[param] == '*'){
							// kalau mirrornya anonymous dan ternyata ada nilai dari json[param] maka kita rekomendasikan untuk di update Typenya
							model[param] = json[param];
							if(json[param]){
								if(typeOfValue(json[param]) == 'object' && _.isEmptyObject(json[param])){
									// ignore this
								}else{
									trace("REFACTOR WARNING : We have value here for "+mirror._name+"::"+param+" : Please consider to use this type "+typeof json[param]+" : "+json[param]);
								}
							}
						}else if (mirror[param] == typeOfValue(json[param]) && typeOfValue(json[param]) !== 'array' ){
							// kalau tipe mirror dan tipe json sama maka kita update langsung saja
							model[param] = json[param];		
						}else if(['string','boolean','number'].indexOf(typeOfValue(json[param])) >= 0){
							// kalau tipe jsonnya berupa array, string,boolean, number, tapi di tipe json bukan, maka kita kasih rekomendasri buat samain tipenya
							trace("REFACTOR WARNING : Invalid Type expected type is "+typeOfValue(json[param])+" instead of "+mirror[param]+" in : "+mirror._name+"::"+param);
						}else if(model[param] == null || model[param] == undefined){
							trace("REFACTOR WARNING : Attribute "+mirror._name+"::"+param+"<"+mirror[param]+"> is still empty, did you forgot to create the object in preMapping");
						}
					}
				}
			}catch(error:Error){
				trace("Unable to copy "+param+" "+error.message);
			}
		}
		
		private static function isolate(func:Function):Function{
			return function run(...args):*{
				try{
					return func.apply(null,args);
				}catch(error:Error){
					trace(error);
				}
				return null;
			}
		}
		
		public static function copyProps(json:Object,model:Object,preMapping:Function):*{
			if(json != null){
				preMapping();
				var sourceType:XML=describeType(model);
				var mirrorModel:Object = {
					_name : sourceType.@name.toString()
				};
				for each (var v:XML in sourceType..variable) {
					mirrorModel[v.@name.toString()] = v.@type.toString().toLowerCase();
				}
				for each (var a:XML in sourceType..accessor) {
					mirrorModel[a.@name.toString()] = a.@type.toString().toLowerCase();
				}
				for (var param:String in json){
					var paramIsAvailableInModel:Boolean = param in model;
					if(paramIsAvailableInModel){
						defaultCopy(param,json,model,mirrorModel);
					}else if(typeOfValue(json[param]) != '*'){
						trace("Attribute "+param+"<"+typeOfValue(json[param])+"> is not available in the "+mirrorModel._name);
						trace("Probably new attribute introduce from server ?");
					}
				}
			}
			return model;
		}
		
		public static function typeOfValue(val:*):String{
			if(val is Array){
				return 'array';
			}
			if(val is String){
				return 'string';
			}
			if(val is Number){
				return 'number';
			}
			if(val is Boolean){
				return 'boolean';
			}
			if(val is Object){
				return 'object';
			}
			return '*';
		}
		
		public static function toJson(object:*):*{
			var type:String = typeOfValue(object);
			if(['string','number','boolean'].indexOf(type)>=0){
				return object;
			}
			
			if(type == 'array'){
				var arrayResult:Array = [];
				for each (var arrayItem:Object in object) 
				{
					arrayResult.push(toJson(arrayItem));
				}
				return arrayResult;
			}
			
			if(type == 'object'){
				var result:Object = {};
				var sourceType:XML =  describeType(object);
				for each (var v:XML in sourceType..variable) {
					var param:String = v.@name.toString();
					result[param] = toJson(object[param]);	
				}
				for each (var a:XML in sourceType..accessor) {
					var param_:String = a.@name.toString();
					result[param_] = toJson(object[param_]);	
				}
				return result;
			}
			return object;
		}
		
		
		
		public static function pad(padding:String,text:*,padOn:String='left'):String{
			if(!(text is String)){
				text = ''+text;
			}
			if(text && padding && text.length<padding.length){
				if(padOn == 'left'){
					return padding.substr(0,padding.length-text.length)+text;	
				}
				return text+padding.substr(0,padding.length-text.length);
			}
			return text;
		}
		
//		public static function and(...args):Boolean{
//			for each (var i:* in args) 
//			{
//				if(!i){
//					return false;
//				}
//			}
//			return true;
//		}
//		
//		public static function or(...args):Boolean{
//			for each (var i:* in args) 
//			{
//				if(i){
//					return true;
//				}
//			}
//			return false;
//		}
		
		public static function deflat(array:Array, noOfMember:int):Array
		{
			var result:Array = [];
			var group:Array = null;
			
			array.forEach(function(item : *,index:Number,source:Array):void{
				if((index % noOfMember == 0)){
					group = [];
					result.push(group);
				}
				group.push(item);
			});
			return result;
		}
		
		public static function getProperty(item:Object, ...dataFieldsChains:Array):*
		{
			var dataFields:Array = _.flat(_.map(dataFieldsChains,function(dataFieldChain:String):*{
				return dataFieldChain.split('.');
			}));
			var result:Object = item;
			for each (var dataField:String in dataFields) 
			{
				result = result && dataField in result ?  result[dataField] : null;
			}
			return result;
		}
		
		public static function flat(array:Array):Array
		{
			return _.reduce(array,function(result:Array,item:*,index:Number,source:Array):*{
				return result.concat(item);
			},[]);
		}
		
		/**
		 * sortArrayCollection(arrayCollection,'label')
		 * sortArrayCollection(arrayCollection,'label','name','age')
		 * sortArrayCollection(arrayCollection,['label','asc'],['label','desc'],'age')
		 */
		public static function sortArrayCollection(ac:ArrayCollection,...condition):ArrayCollection{
			var sort:Sort = new Sort();
			var fields:Array = [];
			_.forEach(condition,function (item:*):void{
				if(item is String){
					var sortField:SortField = new SortField(item);
					fields.push(sortField);
				}
				if(item is Array){
					var sf:SortField = new SortField(item[0],item[1]=='desc');
					fields.push(sf);
				}
			});
			sort.fields = fields;
			ac.sort = sort;
			ac.refresh();
			return ac;
		}
		
		/**
		 * toArrayCollection(array,'label')
		 * toArrayCollection(arrayCollection,'label','name','age')
		 * toArrayCollection(arrayCollection,['label','asc'],['label','desc'],'age')
		 */
		public static function toArrayCollection(ac:Array,...condition):ArrayCollection{
			var param:Array = [new ArrayCollection(ac)];
			param = param.concat(condition);
			return sortArrayCollection.apply(null,param);
		}
		
		public static function isEmpty(text:*):Boolean{
			
			if(text === null){
				return true;
			}
			
			if(text === ''){
				return true;
			}
			return false;
		}
		
		public static function isNotEmpty(text:*):Boolean{
			return !isEmpty(text);
		}
		
		public static function isEmptyProp(item:Object,property:String):Boolean{
			return isEmpty(_.getProperty(item,property));
		}
		
		public static function isNotEmptyProp(item:Object,property:String):Boolean{
			return !isEmptyProp(item,property);
		}
		
		public static function getCompilationDate(swf:ByteArray):Date{
			swf.endian = Endian.LITTLE_ENDIAN;
			swf.position = 3 + 1 + 4 + (Math.ceil(((swf[8] >> 3) * 4 - 3) / 8) + 1) + 2 + 2;
			while(swf.position != swf.length){
				var tagHeader:uint = swf.readUnsignedShort();
				if(tagHeader >> 6 == 41){
					swf.position += 4 + 4 + 1 + 1 + 4 + 4;
					var milli:Number = swf.readUnsignedInt();
					var date:Date = new Date();
					date.setTime(milli + swf.readUnsignedInt() * 4294967296);
					return date;
				}else{
					swf.position += (tagHeader & 63) != 63 ? (tagHeader & 63) : swf.readUnsignedInt() + 4;
				}
			}
			throw new Error("No ProductInfo tag exists");
		}
		
		public static function formatSoftwareVersion(version:String):Date{
			if(version &&  version.length > 0){
				var year:Number = parseInt(version.substr(0,4));
				var month:Number = parseInt(version.substr(4,2)) - 1;
				var day:Number = parseInt(version.substr(6,2));
				var hour:Number = parseInt(version.substr(9,2));
				var minute:Number = parseInt(version.substr(11,2));
				var date:Date = new Date(year,month,day,hour,minute);
				return date;
			}
			return null;
		}
		
		public static function isEmptyObject(object:Object):Boolean{
			for(var param:String in object){
				if(object[param]){
					return false;
				}
			}
			return true;
		}
		
		
		public static function contains(arrayOrCollection:*,...values):Boolean{
			var array:Array = _.toArray(arrayOrCollection);
			for each (var val:* in values) 
			{
				if(array.indexOf(val) >= 0){
					return true;
				}
			}
			return false;
		}
		
		public static function containsAll(arrayOrCollection:*,...values):Boolean{
			var array:Array = _.toArray(arrayOrCollection);
			for each (var val:* in values) 
			{
				if(array.indexOf(val) < 0){
					return false;
				}
			}
			return true;
		}
	}
}