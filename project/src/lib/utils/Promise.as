package lib.utils
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.System;
	
	import modules.context.AppContext;
	
	import mx.collections.ArrayList;
	import mx.core.UIComponent;
	
	import spark.components.Application;
	
	[Event(name="complete", type="flash.events.Event")]
	public class Promise extends EventDispatcher
	{
		private var _async:Function;
		private var _success:Function;
		private var _error:Function;
		private var state:String;
		private var value:*;
		private var resolveable:Resolveable;
		public static var root:UIComponent;
		public static var resolveDelay:Boolean = true;
		
		public function Promise(async:Function = null)
		{
			this.state = 'CREATED';
			this._async = async;
			this.resolveable = new Resolveable();
			this.resolveable.addEventListener("complete",onComplete);
		}
		
		public function resolve(result:*=true):void{
			resolveable.resolve(result);
		}
		
		public function then(success:*):Promise{
			if(!(success is Function)){
				var result:* = success;
				success = function(res:*):*{
					return result;
				};
			}
			_success = success;
			checkIfWeNeedToCallAsyncFunction();
			if(value is Promise){
				return value;
			}
			return new Promise(function(resolve:Function):void{
				if(state == 'COMPLETE'){
					resolve.call(this,value);
				}else{
					addEventListener('complete',function():void{
						resolve.call(this,value);
					});
				}
			});
		}
		
		
		private function checkIfWeNeedToCallAsyncFunction():void
		{
			if(state == 'CREATED' ){
				state = 'RUNNING';
				if(_async != null){
					_async.call(this,resolveable.resolve);	
				}
			}
		}
		
		public static function resolve(value:*=true):Promise{
			return new Promise(function(_resolve:Function):*{
				// warning dont use this it has problem in downloader
				if(root && resolveDelay){
					root.callLater(_resolve,[value]);
				}else{
					_resolve(value);	
				}
			});
		}
		
		protected function onComplete(event:Event):void
		{
			if(resolveable.resolveValue != null){
				state = 'COMPLETE';
				value = resolveable.resolveValue;
				if(resolveable.resolveValue is Promise){
					(resolveable.resolveValue as Promise).then(function(childResult:Object):void{
						value = childResult;
						var res:* = _success.call(this,this.value);
						if(res){
							value = res;
						}
					});
					dispatchEvent(new Event('complete'));
				}else if(_success != null){
					var res:* = _success.call(this,this.value);	
					if(res is Promise){
						res.then(function(_val:*):void{
							value = _val;
							dispatchEvent(new Event('complete'));
						});
					}else{
						value = res;
						dispatchEvent(new Event('complete'));
					}
				}
			}
		}
		
		public static function all(promises:Array):Promise{
			if(promises && promises.length > 0){
				return new Promise(function(_resolve:Function):void{
					var result:ArrayList = new ArrayList();
					_.reduce(promises.slice(1,promises.length) ,function(currentPromise:Promise,next:Promise,index:Number,source:Array):Promise{
						return currentPromise.then(function(val:*):*{
							result.addItemAt(val,index);
							return next;
						});
					},promises[0]).then(function(val:*):void{
						result.addItem(val);
						_resolve(result.source);
					});
				});	
			}
			return Promise.resolve(true);
		}
		
	}
}