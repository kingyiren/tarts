package com.expertria.tart.view
{
	import com.expertria.tart.TartTransfer;
	
	import spark.components.BorderContainer;
	
	public class TartTransferStatusViewClass extends BorderContainer
	{
		protected var _currentTartTransfer :TartTransfer;
		public function TartTransferStatusViewClass()
		{
			super();
		}
		
		[Bindable]
		public function set currentTartTransfer(tartTransfer:TartTransfer):void
		{
			this._currentTartTransfer = tartTransfer;
		}
		public function get currentTartTransfer():TartTransfer
		{
			return this._currentTartTransfer;
		}
	 
	}
}