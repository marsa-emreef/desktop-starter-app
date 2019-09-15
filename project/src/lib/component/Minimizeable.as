package lib.component
{
	
	import flash.events.Event;
	
	import spark.components.SkinnableContainer;
	
	
	[Event(name="minimizeChange", type="flash.events.Event")]
	public class Minimizeable extends SkinnableContainer
	{
		private var _isMinimize:Boolean;
		
		[Bindable]
		public var title:String;
		
		private var _direction:String;//left , up
		
		public function Minimizeable()
		{
			super();
			direction = 'up';
			updateCollapse();
		}
		
		
		[Bindable(event="directionChange")]
		[Inspectable(enumeration="left,up")]
		public function get direction():String
		{
			return _direction;
		}

		public function set direction(value:String):void
		{
			if( _direction !== value)
			{
				_direction = value;
				dispatchEvent(new Event("directionChange"));
				updateCollapse();
			}
		}

		private function updateCollapse():void
		{
			var collapseUp:Boolean = direction == 'up';
			if(isMinimize){
				
				width = collapseUp ? NaN : 27;
				height = collapseUp ? 27  : NaN;
				percentWidth = collapseUp ? 100 : NaN;
				percentHeight = collapseUp ? NaN : 100;	
			}else{
				width = NaN;
				height = NaN;
				percentHeight = 100;
				percentWidth = 100;
			}
			
		}
		
		[Bindable(event="minimizeChange")]
		public function get isMinimize():Boolean
		{
			return _isMinimize;
		}

		public function set isMinimize(value:Boolean):void
		{
			if( _isMinimize !== value)
			{
				_isMinimize = value;
				dispatchEvent(new Event("minimizeChange"));
				invalidateSkinState();
				updateCollapse();
			}
		}

		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function toggle():void{
			isMinimize = !isMinimize;
		}
		
		override protected function getCurrentSkinState():String{
			return isMinimize ? 'minimize' : 'normal';
		}
	}
}