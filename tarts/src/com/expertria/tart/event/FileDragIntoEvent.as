package com.expertria.tart.event
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class FileDragIntoEvent extends Event
	{
		
		public static const FILE_DRAG_INTO_EVENT:String = 
			"fileDragIntoEvent";
		
		private var _file:File;
		public function FileDragIntoEvent(file:File)
		{
			super(FILE_DRAG_INTO_EVENT, false, false);
			this._file = file;
		}
		
		public function get file():File
		{
			return this._file;
		}
	}
}