package com.expertria.tart.event
{
	import flash.events.Event;
	
	public class IncomingFilePartEvent extends Event
	{
		private var partFile:int;
		public function IncomingFilePartEvent(index:int)
		{
			super("IncomingFilePartEvent",false, false);
			partFile = index;
		}
		
		public function get fileIndex():int
		{
			return this.partFile;
		}
	}
}