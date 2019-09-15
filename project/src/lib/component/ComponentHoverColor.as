package lib.component
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.core.UIComponent;
	import mx.events.PropertyChangeEvent;
	

	[Bindable]
	public class ComponentHoverColor extends EventDispatcher
	{
		public var component:UIComponent;
		public var isRollOver:Boolean;
		public var originalColor:uint;
		
		[Inspectable(format="color")]
		public var color:uint;
		
		public function ComponentHoverColor()
		{
			
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropChange);
		}
		
		protected function onPropChange(event:PropertyChangeEvent):void
		{
			if(event.property == 'component'){
				if(event.oldValue){
					(event.oldValue as UIComponent).removeEventListener(MouseEvent.ROLL_OVER,onRollOver);
					(event.oldValue as UIComponent).removeEventListener(MouseEvent.ROLL_OUT,onRollOut);
				}
				if(event.newValue){
					(event.newValue as UIComponent).addEventListener(MouseEvent.ROLL_OVER,onRollOver);
					(event.newValue as UIComponent).addEventListener(MouseEvent.ROLL_OUT,onRollOut);
				}
			}
		}		
		
		private function onRollOut(event:Event):void
		{
			isRollOver = false;
			component.setStyle('color',originalColor);
		}
		
		private function onRollOver(event:Event):void
		{
			isRollOver = true;
			originalColor = component.getStyle('color');
			component.setStyle('color',color);
		}
		
	}
}