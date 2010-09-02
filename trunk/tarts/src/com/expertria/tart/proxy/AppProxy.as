package com.expertria.tart.proxy
{
	import com.expertria.tart.StratusDelegate;
	import com.expertria.tart.Tart;
	import com.expertria.tart.TartFactory;
	import com.expertria.tart.TartTransfer;
	import com.expertria.tart.error.CrossOverTartError;
	import com.expertria.tart.error.DuplicatedTartError;
	import com.expertria.tart.event.TartCompleteEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	[Error(type="com.expertria.tart.error.DuplicatedTartError")]
	
	public class AppProxy extends Proxy   
	{
		public static const NAME:String = "AppProxy";
		
		[Bindable]
		public var currentTransfers:ArrayCollection = 
			new ArrayCollection();
		
		private var _stratusDelegate:StratusDelegate;
		
		
		public function AppProxy( data:Object=null)
		{
			super(NAME, data);	
			
			_stratusDelegate = new StratusDelegate();
			_stratusDelegate.beginConnect();
			 
			retrieveTartList()
		}
		
		[Bindable(eventName="onInit")]
		public function get stratusDelegate():StratusDelegate
		{
			return this._stratusDelegate;
		}
		
		public function addTransfer(transfer:TartTransfer):void
		{
			this.currentTransfers.addItem(transfer);
			
			//write the transfer to the list
			writeTart(transfer.getTart());
			
			transfer.addEventListener(TartCompleteEvent.TART_COMPLETE , onTartCompleteHandler);
			
			
		}
		
		public function deleteTransfer(transfer:TartTransfer):void
		{
			var tartIndex:int = 
				this.currentTransfers.getItemIndex(transfer );
			this.currentTransfers.removeItemAt(tartIndex);
			
			
			deleteTart(transfer.getTart());
			
			transfer.kill();
		}
		
		private function onTartCompleteHandler(e:TartCompleteEvent):void
		{
			//write the tart so that it is marked as complete
			writeTart(e.tart);
		}
		
		private function writeTart(tart:Tart):void
		{
			var _file:File = File.applicationStorageDirectory.resolvePath("current_tarts/" + tart.getId() + ".tart");
			
			var _tartWriter:FileStream  = new FileStream();
			
			_tartWriter.open(_file, FileMode.WRITE);
			
			_tartWriter.writeUTFBytes(tart.toXML().toString())
		}
		
		private function deleteTart(tart:Tart):void
		{
			var _file:File = File.applicationStorageDirectory.resolvePath("current_tarts/" + tart.getId() + ".tart");
			
			_file.deleteFile();
		}
		
		private function retrieveTartList():void
		{
			var _file:File = File.applicationStorageDirectory.resolvePath("current_tarts/");
			if(_file.exists)
			{
				var files:Array = _file.getDirectoryListing();
				for each (var tartFile:File in files)
				{
				  if(tartFile.extension == "tart")
				  {
					  var tempReader:FileStream = new FileStream();
					  tempReader.open(tartFile, FileMode.READ);
					  var content:String =  tempReader.readUTFBytes(tempReader.bytesAvailable);
					  var tart:Tart = TartFactory.getInstance().createTartFromString(content);
					   
					  var tt:TartTransfer = new TartTransfer(tart,this.stratusDelegate)
					  this.addTransfer(tt);
					  tt.beginTransfer();
					  
					  tempReader.close();
					  tartFile = null;
				  }
				}
				 
			}
		}
		
		 
		
		public function addTart(tart:Tart):void
		{
			/**
			 * Ensure no repeated files
			 * */
			for each(var transfer:TartTransfer in this.currentTransfers)
			{
				if(transfer.getTart().getId() == tart.getId())
					
				{
					if(transfer.getTart().getType() == Tart.HAS_FILE 
						&& tart.getType() == Tart.HAS_FILE)
					{
						throw new DuplicatedTartError(tart);
					}
					else if(transfer.getTart().getType() == Tart.NEED_FILE 
						&& tart.getType() == Tart.NEED_FILE)
					{
						throw new DuplicatedTartError(tart);
					}
					else 
					{
						throw new CrossOverTartError(tart);
					}
					
					return;
				}
			}
			
			var _transfer:TartTransfer = new TartTransfer(tart, this.stratusDelegate);
			_transfer.beginTransfer();
			
			addTransfer(_transfer);
		}
		public function addFile(file:File):void 
		{
			var t:Tart = TartFactory.getInstance().createTartFromFile(file);
			
			addTart(t);
		}
	}
}