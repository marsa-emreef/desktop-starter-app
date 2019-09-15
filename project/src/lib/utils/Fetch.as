package lib.utils
{
	
	import lib.utils.encryption.Encryption;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.InvokeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.UIDUtil;
	
	[Bindable]
	public class Fetch
	{
		public var serverAddress:String;
		public var encrypt:Boolean;
		public var timeout:Number = 10;
		public function Fetch(serverAddress:String=null,encrypt:Boolean=false)
		{
			if(serverAddress){
				this.serverAddress = serverAddress;	
			}
			if(encrypt){
				this.encrypt = encrypt;	
			}
			
		}
		
		public function fetch(path:String,json:Object,action:String = 'POST'):Promise{
			
			return new Promise(function(resolve:Function):void{
				var pathSuffix:String=(path.indexOf("?") >= 0) ? "&" : "?";
				var service:HTTPService = new HTTPService();
				service.showBusyCursor = false;
				service.contentType="application/json";
				service.resultFormat="text";
				service.requestTimeout = timeout;
				service.url=serverAddress + (path.substr(0, 1) == "/" ? path : "/" + path);
				service.url+=(pathSuffix + "_uid=" + UIDUtil.createUID());
				service.method=action;
				var request:String = json!=null ? JSON.stringify(json) : null;
				if(encrypt){
					request = Encryption.encryptData(request).toString();
				}
				service.addEventListener(ResultEvent.RESULT,onResult);
				service.addEventListener(FaultEvent.FAULT, onFault);
				var token:AsyncToken = service.send(request);
				token.path = path;
				token.json = json;
				token.resolve = resolve;
				token.action = action;
				token.service = service;
			});
		}
		
		
		protected function onFault(event:FaultEvent):void
		{
			
			var token:AsyncToken = event.token;
			var action:String = token.action;
			var path:String = token.path;
			var json:Object = token.json;
			var resolve:Function = token.resolve;
			var service:HTTPService = token.service;
			
			resolve({
				requestPath : path,
				requestBody : json,
				errorCode: event.statusCode,
				errorCodes : null,
				errorMessage : event.message && event.message.body ? event.message.body : null,	
				innerExceptionMessage : null,
				result : null,
				stackTrace : null,
				success : false
			});
			service.removeEventListener(ResultEvent.RESULT,onResult);
			service.removeEventListener(FaultEvent.FAULT, onFault);
		}
		
		protected function onResult(event:ResultEvent):void
		{
			var token:AsyncToken = event.token;
			var path:String = token.path;
			var json:Object = token.json;
			var resolve:Function = token.resolve;
			var service:HTTPService = token.service;
			
			var data:Object = JSON.parse(event.result.toString());
			var result:Object = _.toCamelCase(data);
			result.requestPath = path;
			result.requestBody = json;
			resolve(result);
			service.removeEventListener(ResultEvent.RESULT,onResult);
			service.removeEventListener(FaultEvent.FAULT, onFault);
		}
	}
}