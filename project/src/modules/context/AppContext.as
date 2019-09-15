package modules.context
{
	import flash.events.Event;
	
	import lib.page.dialog.DialogPanelBase;
	import lib.page.notification.NotificationContainer;
	import lib.utils.ColorCoding;
	import lib.utils.Fetch;
	import lib.utils.Promise;
	import lib.utils._;
	import lib.utils.date.DateUtils;
	
	import modules.config.database.model.Catalog;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Group;
	
	[Event(name="appReady", type="flash.events.Event")]
	[Bindable]
	public class AppContext extends Group
	{
		public var local:Fetch;
		
		// information about the aircraft
		public var notificationContainer:NotificationContainer;
		
		public var appCompilationDate:Date;
		
		/**
		 * This is an indication whether the application is locked
		 */
		public var isLocked:Boolean = true;
		
		public static var CACHE:String = 'CACHE';
		public static var NO_CACHE:String = 'NO_CACHE';
		public var debugger:Boolean;
		public var loggedInUser:String;// catalog.users[0].userName
		public var userIsLoggedIn:Boolean;
		
		public function AppContext()
		{
			super();
			addEventListener(PropertyChangeEvent.PROPERTY_CHANGE,onPropertyChange);
		}
		
		protected function onPropertyChange(event:PropertyChangeEvent):void
		{
			if(event.property == 'loggedInUser'){
				userIsLoggedIn = _.isNotEmpty(loggedInUser); 
			}
		}
		
		/**
		 * query : Query used to fetch data
		 * cache : CACHE / NO_CACHE
		 */
		public function query(query:String,cache:String='CACHE'):Promise
		{
			return local.fetch('/query',{query:query,cache:cache});
		}
		
		public function save(path:String, json:Object,commitTransaction:Boolean = false):Promise
		{
			return local.fetch('/save',{path:path,data:json,add:false}).then(function(res:*):*{
				if(commitTransaction){
					return commit();
				}
				return res;
			});
		}
		
		public function add(path:String, json:Object,commitTransaction:Boolean = false):Promise
		{
			return local.fetch('/save',{path:path,data:json,add:true}).then(function(res:*):*{
				if(commitTransaction){
					return commit();
				}
				return res;
			});
		}
		
		public function saveDb(catalog:Object):Promise{
			return local.fetch('/saveDb',catalog).then(function(res:*):*{
				return res;
			});
		}
		
		/**
		 * Commit purge will immediately purge the data and remove all the backups
		 */
		public function commit():Promise
		{
			return local.fetch('/commit',{});
		}
		
		public function showNotification(text:String):void{
			notificationContainer.showNotification(text);
		}
		
		public function showError(text:String,closeAutomatically:Boolean=false):void{
			notificationContainer.showNotification(text,ColorCoding.RED,closeAutomatically);
		}
		
		public function showConfirmation(text:String,options:uint):Promise{
			return notificationContainer.showConfirmation(text,options);
		}
		
		public function showDialog(dialog:DialogPanelBase):Promise{
			return notificationContainer.showDialog(dialog);
		}
		
		public function restartApp():void
		{
			local.fetch('browser',{func:'reload',param:[]}).then(function(res:*):void{});
		}
		
		public function ready():void
		{
			dispatchEvent(new Event('appReady'));
		}
		
	}
}