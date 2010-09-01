package com.expertria.tart.event
{
	import flash.events.Event;
	
	public class OutgoingFilePartEvent extends Event
	{
		private var partFile:int;
		public function OutgoingFilePartEvent(index:int )
		{
			super("OutgoingFilePartEvent",false, false);
			partFile = index;
		}
		
		public function get fileIndex():int
		{
			return this.partFile;
		}
	}
}