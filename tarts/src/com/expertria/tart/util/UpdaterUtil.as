package com.expertria.tart.util
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusFileUpdateEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;

	public class UpdaterUtil
	{
		private static var appUpdater:ApplicationUpdaterUI;
		private static var onSuccess:Function;
		public static function checkUpdate(onSuccess:Function):void
		{
			UpdaterUtil.onSuccess = onSuccess
			appUpdater  = new ApplicationUpdaterUI(); 
			appUpdater.configurationFile = new File("app:/assets/update-config.xml"); 
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, onUpdate);
		 
			appUpdater.addEventListener(StatusUpdateEvent.UPDATE_STATUS, onUpdateStatus);
			appUpdater.addEventListener(StatusFileUpdateEvent.FILE_UPDATE_STATUS, onFileUpdateStatus);
			appUpdater.addEventListener(UpdateEvent.DOWNLOAD_COMPLETE, onDownloadComplete);
			appUpdater.addEventListener(ErrorEvent.ERROR, onError);
			appUpdater.initialize();
		}
		
		
		private static  function onUpdate(e:Event):void
		{
			appUpdater.checkNow();
		}
		
		private static  function onError(e:Event):void
		{
			//do nothing
		}
		
		private static  function onFileUpdateStatus(e:Event):void
		{
			//do nothing
		}
		private static  function onUpdateStatus(e:StatusUpdateEvent):void			
		{
			 
		}
		
		private  static  function onDownloadComplete(e:Event):void	
		{
			 //do nothing
		}
		
		
	}
	
	
	 
}