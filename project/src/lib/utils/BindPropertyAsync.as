package lib.utils
{
	import flash.events.Event;

	public class BindPropertyAsync extends BindProperty
	{
		public function BindPropertyAsync()
		{
			super();
		}
		
		override public function set value(val:*):void{
			if(val is Promise){
				val.then(onPromise);	
			}else{
				super.value = val;	
			}
			 
		}
		
		private function onPromise(res:*):void{
			super.value = res;
		}
		
	}
}