package com.expertria.tart.view
{
	import com.expertria.tart.Tart;
	import com.expertria.tart.event.Notifications;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class AppMediator extends Mediator
	{
		public static const  name:String = "AppMediator";
		public function AppMediator(tartsApp:TartsAppClass)
		{
			super(name, tartsApp);
		}
		
	 
		public override function handleNotification(notification:INotification):void
		{
			switch(notification.getName())
			{
				case Notifications.SAVE_TART:
					promptForSaveTart(notification.getBody() as Tart);
					break;
			}
		}
		public override function listNotificationInterests():Array
		{
			return  [Notifications.SAVE_TART];
		}
		
		
		public function promptForSaveTart(tart:Tart):void
		{
			var f:File = File.desktopDirectory.resolvePath(tart.getName().split(".")[0] + ".tart");
			
			f.addEventListener(Event.SELECT, function(e:Event):void
			{
				
				var fs :FileStream = new FileStream();
				fs.open(f, FileMode.WRITE);
				fs.writeUTFBytes(tart.toXML().toString());
				fs.close();
			}, false, 0, true);
			f.browseForSave("Save Tart File");
		}
		
		
	}
}