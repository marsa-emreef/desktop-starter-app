package lib.utils
{
	public class Debounce
	{
		public function Debounce()
		{
		}
		import flash.events.TimerEvent;
		import flash.utils.Timer;
		import flash.utils.getTimer;
		
		public static function create(callback:Function,delayInMilisecond:Number = 300,thisArgs:Object=null):Function{
			var timer:Timer;
			var listener:Function;
			return function callbackCallerClosure(...args):void{
				if(timer){
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER_COMPLETE,listener);
				}
				timer = new Timer(delayInMilisecond,1);
				listener = function(event:TimerEvent):void
				{
					callback.apply(thisArgs,args);				
				};
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,listener);
				timer.start();
			}
		}
	}
}