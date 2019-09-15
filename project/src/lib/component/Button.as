package lib.component
{
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import lib.component.skins.ButtonSkin;
	
	import mx.core.EventPriority;
	
	import spark.components.Button;
	
	public class Button extends spark.components.Button
	{
		private var _delay:Number = 3000;
		private var timer:Timer = new Timer(delay,0);
		
		public var internallyDisabled:Boolean;
		public function Button()
		{
			super();
			internallyDisabled=false;
			timer.addEventListener(TimerEvent.TIMER,onTimerFire);
			addEventListener(MouseEvent.CLICK,onMouseClicked,false,EventPriority.BINDING);
			enabled = true;
		}

		public function get delay():Number
		{
			return _delay;
		}

		/**
		 * Delay timer to prevent double clicking, default value is 3000
		 */
		public function set delay(value:Number):void
		{
			_delay = value;
			timer.delay = _delay;
		}
		
		protected function onTimerFire(event:TimerEvent):void
		{
			timer.stop();
			internallyDisabled = false;
			alpha = 1;
		}
		
		protected function onMouseClicked(event:MouseEvent):void
		{
			if(!internallyDisabled){
				internallyDisabled = true;
				alpha = 0.5;
				timer.start();	
			}else{
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
			}
				
		}
	}
}