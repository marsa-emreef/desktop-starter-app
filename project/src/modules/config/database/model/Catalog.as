package modules.config.database.model
{
	import lib.utils._;

	public class Catalog
	{
		[Inspectable(arrayType="modules.config.database.model.User")]
		public var users:Array; // array of
		
		public function Catalog(json:Object = null)
		{
			_.copyProps(json,this,function():void{
				users = _.map(json.user,function(item:*):User{
					return new User(item);
				});
			});
		}
	}
}