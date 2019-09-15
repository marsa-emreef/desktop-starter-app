package lib.component
{
	
	import flash.events.Event;
	
	import lib.utils.ListenOnEvent;
	import lib.utils.PromiseEvent;
	import lib.utils._;
	
	import mx.effects.AnimateProperty;
	import mx.events.EffectEvent;
	
	import spark.components.SkinnableContainer;
	
	[Event(name="beforeOpen", type="lib.utils.PromiseEvent")]
	[Event(name="afterOpen", type="flash.events.Event")]
	[Event(name="beforeClose", type="lib.utils.PromiseEvent")]
	[Event(name="afterClose", type="flash.events.Event")]
	[Event(name="displayContentChange", type="flash.events.Event")]
	[Event(name="clickedOutsideContent", type="flash.events.Event")]
	public class Slider extends SkinnableContainer
	{
		private var _displayContent:Boolean;
		[SkinPart(required="true")]
		public var closeAnimate:AnimateProperty;
		public function Slider()
		{
			super();
			setStyle('skinClass',SliderSkin);
			addEventListener('displayContentChange',onDisplayContentChange);
			percentWidth = 100;
			percentHeight = 100;
		}
		
		protected function onDisplayContentChange(event:Event):void
		{
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String{
			return displayContent ? 'show' : 'normal';
		}
		
		[Bindable(event="displayContentChange")]
		public function get displayContent():Boolean
		{
			return _displayContent;
		}

		public function set displayContent(value:Boolean):void
		{
			if( _displayContent !== value)
			{
				if(value){
					if(hasEventListener('beforeOpen')){
						var beforeOpenEvent:PromiseEvent = new PromiseEvent('beforeOpen');
						beforeOpenEvent.then(function():void{
							_displayContent = true;
							dispatchEvent(new Event("displayContentChange"));
						});
						dispatchEvent(beforeOpenEvent);
					}else{
						_displayContent = true;
						dispatchEvent(new Event("displayContentChange"));
					}
					
				}else{
					if(hasEventListener('beforeClose')){
						var beforeCloseEvent:PromiseEvent = new PromiseEvent('beforeClose');
						beforeCloseEvent.then(function():void{
							closeAnimate.play();
							ListenOnEvent.once(closeAnimate,EffectEvent.EFFECT_END,function(event:Event):void{
								dispatchEvent(new Event("afterClose"));
								_displayContent = false;
								dispatchEvent(new Event("displayContentChange"));
							});
						});
						dispatchEvent(beforeCloseEvent);
					}else{
						closeAnimate.play();
						ListenOnEvent.once(closeAnimate,EffectEvent.EFFECT_END,function(event:Event):void{
							dispatchEvent(new Event("afterClose"));
							_displayContent = false;
							dispatchEvent(new Event("displayContentChange"));
						});
					}
				}
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
		
	}
}