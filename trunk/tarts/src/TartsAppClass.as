/**
 * Copyright (C) 2010 Hu Shunjie shinchi@gmail.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>

 
**/
package
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusFileUpdateEvent;
	import air.update.events.StatusUpdateEvent;
	import air.update.events.UpdateEvent;
	
	import com.expertria.tart.StratusDelegate;
	import com.expertria.tart.Tart;
	import com.expertria.tart.TartFactory;
	import com.expertria.tart.TartTransfer;
	import com.expertria.tart.error.CrossOverTartError;
	import com.expertria.tart.error.DuplicatedTartError;
	import com.expertria.tart.event.FileDragIntoEvent;
	import com.expertria.tart.event.Notifications;
	import com.expertria.tart.facade.AppFacade;
	import com.expertria.tart.proxy.AppProxy;
	import com.expertria.tart.util.UpdaterUtil;
	 
	import com.expertria.tart.view.AppMediator;
	
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.system.fscommand;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.Window;
	import mx.utils.object_proxy;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.WindowedApplication;
	
	public class TartsAppClass extends WindowedApplication
	{
		
		
		
		protected var _appProxy:AppProxy;
		private var facade:IFacade;
		public function TartsAppClass()
		{
			super();
			
			facade  = AppFacade.getInstance();
			
			facade.registerMediator(new AppMediator(this));
			
			_appProxy = facade.retrieveProxy(AppProxy.NAME) as AppProxy;
			
			this.dispatchEvent(new Event("onInit"));
		}
		
		[Bindable(event="onInit")]
		public function  get appProxy():AppProxy
		{
			return this._appProxy;
		}
		
		
		protected function onApplicationComplete(e:Event):void
		{
			UpdaterUtil.checkUpdate(onUpdateOK);	
			
			onUpdateOK()
		}
		
		private function onUpdateOK():void
		{
			FileMenuDelegate.construct(this);	
			
		}
		
	 
		protected function onSelectFile(e:Event):void
		{
			 var f:File  = new File();
			 f.addEventListener(Event.SELECT, onFileSelect);
			 f.browseForOpen("select file to share");
		}
		
	 
		protected function onFileSelect(e:Event):void
		{
			var f:File = e.target as File;
			
			attemptAddFile(f)
			
		}
		
		protected function onFileDragIntoEvent(e:FileDragIntoEvent):void
		{
			attemptAddFile(e.file);
		}
		 
		private function attemptAddFile(file:*):void
		{
			try
			{
				if(file is File)
					appProxy.addFile(file as File);
				else if(file is Tart)
					appProxy.addTart(file as Tart);
			}
			catch (error:DuplicatedTartError)
			{
				if(error.tart.getType() == Tart.HAS_FILE)
					Alert.show("You cannot try to share 2 identical files");
				else if(error.tart.getType() == Tart.NEED_FILE)
					Alert.show("You cannot try to download 2 identical files");
			}
			catch(error:CrossOverTartError)
			{
				Alert.show("You cannot be sharing and downloading identical file at the same time");
			}
			finally
			{
				//nothing for now
			}
			
		}
		
		
		protected function onRequestFile(event:Event):void
		{
			 
			 var f:File = new File();
			 f.addEventListener(Event.SELECT, function(e:Event):void
			 {
				
				 var fs:FileStream = new FileStream();
				 fs.open(f, FileMode.READ);
				 var tartContent:String = fs.readUTFBytes(fs.bytesAvailable);
				 var tart:Tart = TartFactory.getInstance().createTartFromString(tartContent);
				 tart.needFile();
				 
				 //write the file to the app folder
				 
				 attemptAddFile(tart);
				 
				 fs.close();
				 
				 
				 
			 });
			  var ff:FileFilter = new FileFilter("Tart Files" , ".tart");
			 f.browseForOpen("Select a tart file",[ff]);
			  
			 
		}
	}
}