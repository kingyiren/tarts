package com.expertria.tart.facade
{
	import com.expertria.tart.proxy.AppProxy;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
	public class AppFacade extends Facade
	{
		/***
		 *
		 * */
		public function AppFacade()
		{
			super();
			init();
			
			if(singleInstance != null) throw new Error("Only one AppFacade can be initiaed");
		}
		
		private static var singleInstance:AppFacade;
		public static function getInstance():AppFacade
		{
			if(singleInstance == null) singleInstance = new AppFacade();
			return singleInstance;
		}
		
		private function init():void
		{
			this.registerProxy(new AppProxy());
		}
	}
}