package lib.component.status
{
	
	import lib.component.status.status_30;
	import lib.component.status.status_31;
	import lib.component.status.status_38;
	import lib.component.status.status_39;
	import lib.component.status.status_41;
	import lib.component.status.status_42;
	import lib.component.status.status_43;
	
	import spark.components.Image;
	import spark.components.supportClasses.SkinnableComponent;
	import flash.events.Event;
	
	[Event(name="statusIdChange", type="flash.events.Event")]
	public class StatusImage extends SkinnableComponent
	{
		
		private var _statusId:String;
		
		[SkinPart(required="true")]
		public var img:Image;
		
		public function StatusImage()
		{
			super();
			setStyle('skinClass',StatusImageSkin);
		}
		
		[Bindable(event="statusIdChange")]
		public function get statusId():String
		{
			return _statusId;
		}

		public function set statusId(value:String):void
		{
			if( _statusId !== value)
			{
				_statusId = value;
				if(img){
					img.source = getStatus(value);
				}
				dispatchEvent(new Event("statusIdChange"));	
			}
		}

		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		}
		
		override protected function partAdded(partName:String, instance:Object) : void
		{
			super.partAdded(partName, instance);
			if(instance == img){
				if(_statusId){
					img.source = getStatus(_statusId);
				}
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object) : void
		{
			super.partRemoved(partName, instance);
		}
		
		public function getStatus(id:*):Class{
			if(id == 30){
				return status_30;
			}
			if(id == 31){
				return status_31;
			}
			if(id == 38){
				return status_38;
			}
			if(id == 39){
				return status_39;
			}
			if(id == 41){
				return status_41;
			}
			if(id == 42){
				return status_42;
			}
			if(id == 43){
				return status_43;
			}
			return null;
		}
		
	}
}