package com.expertria.tart
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	 
	public class TartTransfer extends EventDispatcher
	{
		//The tart this transfer object is tracking
		private var tart:Tart;
		
		//The main stratus delegate
		private var stratusDelegate:StratusDelegate;
		
		//netGroup for the file transfer - 1 file = 1 NetGroup
		private var _netGroup:NetGroup;
		
		//this is the main File Reader if the user has the complete file
		private var mainFS:FileStream ;	 
		
		//The number of received file part
		private var _receivedFilePartCount:int = 0;
		
		private var _enableActivityTracking:Boolean = false;
		private var _activity:Number = 0;
		
		
		public function TartTransfer(tart:Tart, stratusDelegate:StratusDelegate)
		{
			this.tart = tart;
			this.stratusDelegate = stratusDelegate;		
		 	this.enableActivityTracking = true;	
		}
		
		/**
		 * Begin a transfer
		 * This method will look at the Tart's Type and begin an outgoing or incoming transfer automatically
		 * */
		public function beginTransfer():void
		{
			
			var _groupSpecifier:GroupSpecifier = new GroupSpecifier("tart_" + tart.getId());
			
			_groupSpecifier.multicastEnabled = true;
			_groupSpecifier.objectReplicationEnabled = true;
			_groupSpecifier.postingEnabled = true; 
			_groupSpecifier.routingEnabled = true; 			
			_groupSpecifier.serverChannelEnabled = true; 
			
			 
			var groupSpec :String = 
				 _groupSpecifier.groupspecWithoutAuthorizations()
			
			
			if(!this.stratusDelegate.getNetConnection().connected )
			{
				throw new Error("NetConnection is Not Connected");
			}
			
			this.stratusDelegate.getNetConnection().addEventListener(NetStatusEvent.NET_STATUS, checkNetGroupConnection);
			 
			_netGroup = new NetGroup( this.stratusDelegate.getNetConnection() , groupSpec );
			
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, onNetGroupEvent);
		}
		
	
			
		protected function checkNetGroupConnection(e:NetStatusEvent):void{
			
			var   info_code :String = e.info.code; 
			
			//Ensure that it is the group we are interested in
			if(e.info.group == this._netGroup)
			{
				switch(info_code)
				{
					case "NetGroup.Connect.Success":
					
						if(tart.getType() == Tart.HAS_FILE)
						{
							ensureFileAndShare();
						}
						else if(tart.getType() == Tart.NEED_FILE)
						{
							//broadcast that we need the file
							_netGroup.addWantObjects(0, tart.getLastPart());
							
							//TODO:
							/**
							 * FROM: @shinchi
							 * We need to ensure that if a user close and open the client
							 * We only request those files that we need and not everything again
							 * **/
						}
			
			
					break;
					
					case "NetGroup.Connect.Failure":
					 	//TODO: Handle Failure
					break;
				}
			}
		}
		
		/**
		 * Ensure the file exist and share
		 * */
		private function ensureFileAndShare():void
		{
			var file:File = new File(tart.getRef());
			if(file.exists)
			{
				mainFS = new FileStream();
				mainFS.open(file, FileMode.READ);
				
				_netGroup.addHaveObjects(0, tart.getLastPart());
			}
			else
			{
				//TODO: throws an error - the path of the file might has changed
				
			}
		}
		
		
		
		protected function onNetGroupEvent(e:NetStatusEvent):void{
			
			switch(e.info.code)
			{
				case "NetGroup.Neighbor.Connect":
					 
					//info.code , info.level, info.neighbor, info.peerID
					
					break;
				
				case "NetGroup.Posting.Notify":
					
					break;
				
				case "NetGroup.Replication.Request":
					
					//get the part of the file we need
					var indexRequested :Number = e.info.index;
					
					//if the main FileStreamreader is running
					if(mainFS !=null)
					{
						//get the bytes we need to read from
						var readFrom :uint = indexRequested * tart.getPartSize() ;
						 
						//get the size we need to read
						var size_slice:uint =   (indexRequested == tart.getLastPart()) ? 
							tart.getLastPartSize() : tart.getPartSize();
						
						
						/**
						 * Read the chunk of byteArray from the File
						 * */
						var bytes:ByteArray = new ByteArray();
						mainFS.position = readFrom; 
						mainFS.readBytes(bytes, 0, size_slice);
						
						/**
						 * Increase the activity
						 * */
						if(enableActivityTracking)
						{
							activity +=  (1 / tart.getTotalParts() 	* 100);
						}
						
						/**
						 * Write the bytes to the NetGroup
						 * */
						_netGroup.writeRequestedObject(e. info.requestID, bytes);
						
						bytes.clear();
					}
					else
					{
						/***
						 * If the main file reader is not reading
						 * It means that the download is still in progress, but this client
						 * has the file part needed by others
						 * */
						var f1:File = File.applicationStorageDirectory.resolvePath(tart.getId() + "/file" +  indexRequested +  ".osf");
						
						if(f1.exists)
						{
							//TODO: check for integrity of the file 
							
							//Create a temp FileStream to read the file
							var tempFS :FileStream = new FileStream();
							tempFS.open(f1, FileMode.READ);
							
							//Create a temp ByteArray
							var tempBytes:ByteArray = new ByteArray();
							tempFS.readBytes(tempBytes, 0, tempFS.bytesAvailable);
							
							
							//Add some activity
							if(enableActivityTracking)
							{
								activity +=  (1 / tart.getTotalParts() 	* 100);
							}
							
							//Write the requested object to the NetGroup
							_netGroup.writeRequestedObject(e. info.requestID, tempBytes);
							
							tempBytes.clear();
							 
							
						}
						else
						{
							
							 
							//TODO: we need to check if we need to deny or it can be handled automatically by RTMFP
							// _netGroup.denyRequestedObject(info.requestID);
							 
						}
						 
					}
					
					 
					break;
				
				case "NetGroup.Replication.Fetch.SendNotify":
					
					break;
				
				case "NetGroup.Replication.Fetch.Result":
					
					
					var fileData:* = e.info.object;
					var index:Number = e.info.index;
					
					//add activity
					if(enableActivityTracking)
					{
						activity +=  (1 / tart.getTotalParts() 	* 100);
					}
					
					/***
					 * We do not keep the byteArray in the memory in case of large part
					 * We write the file onto a .osf part file
					 * */
					var fs:FileStream = new FileStream();
					var f:File = File.applicationStorageDirectory .resolvePath(tart.getId() +  "/file" + index + ".osf");				
					fs.open(f, FileMode.WRITE);
					fs.writeBytes(fileData);
					fs.close();
					f = null;
					//finished writing
					
					
					//tell the transfer object we got one more file part
					receivedFilePartCount ++ ;
				 
					//broadcast that we now have this particular part
					_netGroup.addHaveObjects(index, index);
					_netGroup.removeWantObjects(index, index);
					
					
					//if we have all the parts
					if(receivedFilePartCount == tart.getTotalParts())
					{
						
						//write the final file!
						var _final:File= File.documentsDirectory .resolvePath("tarts_downloads/" + tart.getName() );
						var _fsWriter:FileStream = new FileStream();
						_fsWriter.open(_final, FileMode.WRITE);
						
						for(var i:int = 0 ; i < tart.getTotalParts() ; i++)
						{
							
							var _f:File = File.applicationStorageDirectory.resolvePath(tart.getId() +  "/file" + i + ".osf");
							var _fsReader:FileStream = new FileStream();
							_fsReader.open(_f, FileMode.READ);	
							
							/**
							 * Read from file part and put it into a ByteArray
							 * */
							var toWrite:ByteArray = new ByteArray();
							_fsReader.readBytes( toWrite, 0, _fsReader.bytesAvailable);
							_fsReader.close();	
							
							/**
							 * Write the byteArray into the main file writer
							 * */
							_fsWriter.writeBytes(toWrite, 0, toWrite.bytesAvailable);
							_f = null;
							
							toWrite.clear();
							
						}
						
						//close the file writer
						_fsWriter.close();
						
						//delete the directory
						File.applicationStorageDirectory.resolvePath(tart.getId()).deleteDirectory(true);
	
						//Set the ref of the tart to the real file, and set the type to HAS_FILE
						tart.setRef(_final.nativePath);
						tart.setType(Tart.HAS_FILE);
						
						//Share the file :)
						ensureFileAndShare();
						 
						
					}
					break;
				
				case "NetGroup.Replication.Fetch.Fail":
					break;
				
				
			}
		}
		
		
		
		public function get netGroup():NetGroup
		{
			return this._netGroup;
		}
		
		public function get enableActivityTracking():Boolean
		{
			return this._enableActivityTracking;
		}
		public function set enableActivityTracking(enable:Boolean):void
		{
			this._enableActivityTracking = enable;
			if(enable)
			{
				startTimer();
			}
			else
			{
				endTimer();
			}
		}
		
		
		
		/**
		 * Activities
		 * **/
		[Bindable(event="activityChange")]
		public function get activity():Number
		{
			return Math.ceil(this._activity);
		}
		
		public function set activity(newActivity:Number):void
		{
			 
			this._activity = newActivity;
			this._activity = Math.max(_activity, 0);
			this._activity %= 100;
			dispatchEvent(new Event("activityChange")); 
			
		}
		
		/***
		 * Received File Part
		 * */
		[Bindable(event="receivedFilePartChange")]
		public function get receivedFilePartCount():int
		{
			return this._receivedFilePartCount
		}
		
		public function set receivedFilePartCount(count:int):void
		{
			this._receivedFilePartCount = count;
			dispatchEvent(new Event("receivedFilePartChange"));
		}
		
		public function  getTart():Tart
		{
			return this.tart;
			
		}
		
		private var _timer:Timer;
		private function startTimer():void
		{
			if(_timer == null) 
			{
				_timer =new Timer(1000);
				_timer.addEventListener(TimerEvent.TIMER, function():void
				{
					activity --;	
				}, 
					false, 0, true);
			}
			_timer.start();
			
		}
		private function endTimer():void
		{
			if(_timer != null) _timer.stop();
		}
		
	}
	
}