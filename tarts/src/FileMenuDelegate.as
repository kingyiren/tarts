package
{
	import com.expertria.tart.Tart;
	import com.expertria.tart.TartTransfer;
	import com.expertria.tart.event.Notifications;
	import com.expertria.tart.facade.AppFacade;
	import com.expertria.tart.view.renderer.TartRendererClass;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import org.puremvc.as3.interfaces.IFacade;
	
	import spark.components.WindowedApplication;

	public class FileMenuDelegate
	{
		 
		
		private static  function getFacade():IFacade
		{
		  return AppFacade.getInstance();
		}
		
		private static function constructTartMenu(tartRenderer:TartRendererClass):void
		{
			var menu:NativeMenu = new NativeMenu();
			
			var transfer:TartTransfer = tartRenderer.data as TartTransfer;
			var tart:Tart = transfer.getTart();
			
			if(tart.getType() == Tart.HAS_FILE)
			{
				var getTartFile:NativeMenuItem =  new NativeMenuItem("Generate Tart File");
				menu.addItem(getTartFile);
				getTartFile.addEventListener(Event.SELECT, function():void
				{
				
					getFacade().sendNotification(Notifications.SAVE_TART, tart);
				
				});
			
				menu.addItem(new NativeMenuItem("_", true));
			}
			
			var showInFolder:NativeMenuItem = new NativeMenuItem("Show in Folder");
			showInFolder.addEventListener(Event.SELECT, function():void
			{
				 
				
				var ref:String = tart.getRef();
				var file:File = new File(ref);
				if(!file.exists) file.createDirectory();
				file.parent.openWithDefaultApplication();
				
			} );
			
			menu.addItem(showInFolder);
			
			
			var stopSharing:NativeMenuItem =  new NativeMenuItem("Remove File");
			stopSharing.addEventListener(Event.SELECT, function():void
			{
				getFacade().sendNotification(Notifications.DELETE_TRANSFER, transfer);
				
			} );
			 
			menu.addItem(stopSharing);
			
			tartRenderer.contextMenu = menu;
		}
		
		public static function constructApp(app:WindowedApplication):void
		{
			/*
			var fileMenu1:NativeMenuItem = new NativeMenuItem("tarts");
			fileMenu1.submenu = createMainMenu();
			
			var fileMenu:NativeMenuItem = new NativeMenuItem("File");
			fileMenu.submenu = createFileMenu();
			
			
			app.nativeApplication.menu.items = new Array(fileMenu1,  fileMenu);*/
		}
		
		public static function construct(o:*):void
		{
			if(o is WindowedApplication) constructApp(o);
			else if(o is TartRendererClass ) constructTartMenu(o);
		}
		/*
		public static function createMainMenu():NativeMenu {
			var fileMenu:NativeMenu = new NativeMenu();
			//fileMenu.addEventListener(Event.SELECT, selectCommandMenu);
			
			var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("About" ));
			//	newCommand.addEventListener(Event.SELECT, selectCommand);
			fileMenu.addItem(new NativeMenuItem("", true));
			
			var openRecentMenu:NativeMenuItem = 
				fileMenu.addItem(new NativeMenuItem("Quit!")); 
			//	openRecentMenu.submenu = new NativeMenu();
			//	openRecentMenu.submenu.addEventListener(Event.DISPLAYING,
			//		updateRecentDocumentMenu);
			//	openRecentMenu.submenu.addEventListener(Event.SELECT, selectCommandMenu);
			
			return fileMenu;
		}
		
		public static function createFileMenu():NativeMenu {
			var fileMenu:NativeMenu = new NativeMenu();
			//fileMenu.addEventListener(Event.SELECT, selectCommandMenu);
			
			var newCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("New"));
			
			//newCommand.addEventListener(Event.SELECT, onSelectFile);
			var saveCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Save"));
			//	saveCommand.addEventListener(Event.SELECT, selectCommand);
			var openRecentMenu:NativeMenuItem = 
				fileMenu.addItem(new NativeMenuItem("Open Recent")); 
			openRecentMenu.submenu = new NativeMenu();
			//	openRecentMenu.submenu.addEventListener(Event.DISPLAYING,
			//		updateRecentDocumentMenu);
			//	openRecentMenu.submenu.addEventListener(Event.SELECT, selectCommandMenu);
			
			return fileMenu;
		}*/
		
	}
}