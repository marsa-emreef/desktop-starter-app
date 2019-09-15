package modules.config.database.model
{
	import lib.utils._;

	public class User
	{
		public var userName:String;
		public var password:String;
		public var ts:Number;
		public var isAdmin:Boolean;
		public function User(json:*)
		{
			_.copyProps(json,this,function():void{
			});
		}
	}
}