package lib.utils
{
	import flash.events.Event;
	
	public class PromiseEvent extends PayloadEvent
	{
		private var promise:Promise;
		public function PromiseEvent(type:String,payload:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type,payload,bubbles,cancelable);
			promise = new Promise();
		}
		
		public function resolve(result:*=true):void{
			promise.resolve(result);
		}
		
		public function then(callback:Function):Promise{
			return promise.then(callback);
		}
	}
}