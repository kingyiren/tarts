package com.expertria.tart.view
{
	import com.expertria.tart.event.FileDragIntoEvent;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.NativeDragActions;
	import flash.events.NativeDragEvent;
	import flash.filesystem.File;
	
	import mx.managers.DragManager;
	
	import spark.components.BorderContainer;
	
	[Event(name="fileDragIntoEvent", type="com.expertria.tart.event.FileDragIntoEvent")]
	
	public class TartDragAreaClass extends BorderContainer
	{
		public function TartDragAreaClass()
		{
			super();
		}
		
		protected function onNativeDragEnter(event:NativeDragEvent):void
		{
			 
			var clipboard:Clipboard = 	event.clipboard;
			
			if(clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
			{
				//event.allowedActions = NativeDragActions.LINK;
				DragManager.acceptDragDrop(this);
			}
			//this.addEventListener(na
			//	DragManager.acc
			 
			 
		}
		protected function onNativeDropEvent(event:NativeDragEvent):void
		{
			 var clipboard:Clipboard = event.clipboard;
			 var object:* = 
			 clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT);
			 for(var i:* in object)
			 {
				 if(object[i] is File)
				 {
					 var file:File = object[i];
					 dispatchEvent(new FileDragIntoEvent(file));
				 }
			 }
				
		}
		protected function onNativeDropComplete(event:NativeDragEvent):void
		{
			
		}
		 
	}
}