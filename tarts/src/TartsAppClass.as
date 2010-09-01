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
	import com.expertria.tart.facade.AppFacade;
	import com.expertria.tart.proxy.AppProxy;
	import com.expertria.tart.util.UpdaterUtil;
	import com.expertria.tart.util.Utils;
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
	
	import mx.utils.object_proxy;
	
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.WindowedApplication;
	
	public class TartsAppClass extends WindowedApplication
	{
		
		
		[Bindable]
		protected var stratusDelegate:StratusDelegate;
		
		protected var _appProxy:AppProxy;
		 
		public function TartsAppClass()
		{
			super();
			
			var facade:IFacade = AppFacade.getInstance();
			
			facade.registerMediator(new AppMediator(this));
			
			_appProxy = facade.retrieveProxy(AppProxy.NAME) as AppProxy;
		}
		
		public function  get appProxy():AppProxy
		{
			return this._appProxy;
		}
		
		
		protected function onApplicationComplete(e:Event):void
		{
			UpdaterUtil.checkUpdate(onUpdateOK);	
		}
		
		private function onUpdateOK():void
		{
			FileMenuDelegate.construct(this);	
			stratusDelegate = new StratusDelegate();
			stratusDelegate.beginConnect();
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
			var t:Tart = TartFactory.getInstance().createTartFromFile(f);
		
			var transfer:TartTransfer = new TartTransfer(t, this.stratusDelegate);
			transfer.beginTransfer();
			
			appProxy.addTransfer(transfer);
			
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
				 var transfer:TartTransfer = new TartTransfer(tart,  stratusDelegate);
				 transfer.beginTransfer();
				 
				 appProxy.addTransfer(transfer);
				 
			 });
			  var ff:FileFilter = new FileFilter("Tart Files" , ".tart");
			 f.browseForOpen("Select a tart file",[ff]);
			  
			 
		}
	}
}