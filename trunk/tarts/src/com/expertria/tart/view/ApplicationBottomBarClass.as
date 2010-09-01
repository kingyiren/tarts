package com.expertria.tart.view
{
	import com.expertria.tart.StratusDelegate;
	
	import spark.components.BorderContainer;

	public class ApplicationBottomBarClass extends BorderContainer
	{
		 
		private var _stratusDelegate:StratusDelegate;
		public function ApplicationBottomBarClass()
		{
			
		}
		
		[Bindable]
		public function set stratusDelegate(stratusDelegate:StratusDelegate):void
		{
			this._stratusDelegate = stratusDelegate;
		}
		public function get stratusDelegate():StratusDelegate
		{
			return this._stratusDelegate;
		}
	}
}