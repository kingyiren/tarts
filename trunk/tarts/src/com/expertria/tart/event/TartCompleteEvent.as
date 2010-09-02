package com.expertria.tart.event
{
	import com.expertria.tart.Tart;
	
	import flash.events.Event;
	
	public final class TartCompleteEvent extends Event
	{
		 
		public static const TART_COMPLETE:String = "tartComplete";
		private var _tart:Tart;
		public function TartCompleteEvent( tart:Tart)
		{
			super(TART_COMPLETE);
			this._tart = tart
		}
		
		public function get tart():Tart
		{
			return this._tart;
		}
	}
}