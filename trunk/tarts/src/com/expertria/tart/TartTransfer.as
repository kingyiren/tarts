package com.expertria.tart
{
	import com.expertria.tart.event.IncomingFilePartEvent;
	import com.expertria.tart.event.OutgoingFilePartEvent;
	import com.expertria.tart.event.TartCompleteEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	import flash.net.NetGroupInfo;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	[Event(name="IncomingFilePartEvent", type="com.expertria.tart.event.IncomingFilePartEvent")]
	[Event(name="OutgoingFilePartEvent", type="com.expertria.tart.event.OutgoingFilePartEvent")]
	[Event(name="tartComplete", type="com.expertria.tart.event.TartCompleteEvent")]
	 
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
	 
		
		private var _partList:ArrayCollection ;
		
		
		private var _messages:String =
			//initial message
			"<b>You can send message to all the users sharing this file.</b><p>For the list of command, type /help</p>"; 
			//0100101000000000001111001111101001111000 
			 
		
		
		public function TartTransfer(tart:Tart, stratusDelegate:StratusDelegate)
		{
			this.tart = tart;
			this.stratusDelegate = stratusDelegate;		
		 	 
			this._partList = new ArrayCollection( new Array(this.tart.getTotalParts()));
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
			 
				stratusDelegate.addEventListener("onConnect", function(e:Event):void				
				{
					onConnect(groupSpec);
				} );
				
			}
			else
			{
				onConnect(groupSpec);	
			}
			
			
		}
		
		private function onConnect(groupSpec:String):void	
		{
			this.stratusDelegate.getNetConnection().addEventListener(NetStatusEvent.NET_STATUS, checkNetGroupConnection);
			
			_netGroup = new NetGroup( this.stratusDelegate.getNetConnection() , groupSpec );
			
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, onNetGroupEvent);
		}
	
			
		protected function checkNetGroupConnection(e:NetStatusEvent):void{
			
			var   info_code :String = e.info.code; 
			trace("Net Connection Group " +info_code + " for " + tart.getName());
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
							
							//TODO:
							/**
							 * FROM: @shinchi
							 * We need to ensure that if a user close and open the client
							 * We only request those files that we need and not everything again
							 * **/
							var filePartDirectory:File = 
								File.applicationStorageDirectory.resolvePath(tart.getId());
							if(filePartDirectory.exists)
							{
							var files:Array =  filePartDirectory.getDirectoryListing();
							for each(var _file:File in files)
							{
								if( _file.size == tart.getPartSize() && _file.extension == "osf")
								{
									var file_index :Number = Number( _file.name.replace("file", "").replace(".osf", ""));
									if(! isNaN(file_index))
									{
										//file exist									 
										dispatchPartIncoming(file_index);
									}
									 
								}
							}
							}
							
							
							
							//broadcast that we need the file
							wantObject(0, new Array());
							
							
						
						}
			
			
					break;
					
					case "NetGroup.Connect.Failure":
					 	//TODO: Handle Failure
					break;
				}
			}
		}
		
		private function wantObject( start:int , reach:Array ):void
		{
			if(start >= this.partList.length) 
			{
				if(reach.length > 0)
					_netGroup.addHaveObjects(reach[0], reach[reach.length - 1])					 
				return;
			}
			
			var end :int = start;
			for(var i:int = start ; i < this.partList.length ; i++)
			{
				if(partList.getItemAt(i) == "done")
				{
					
					reach.push(i);
					end = i - 1;
					wantObject(i + 1, reach);
					break;
				}
				else
				{
					if(reach.length > 0)
						_netGroup.addHaveObjects(reach[0], reach[reach.length - 1]);
					reach = new Array();
					
					end = i
				}
			}
			if(end >= start)
				_netGroup.addWantObjects(start, end);
			 
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
			trace(e.info.code + " for " + tart.getName())
			switch(e.info.code)
			{
				 
				case "NetGroup.Neighbor.Connect":
					 
					
					//info.code , info.level, info.neighbor, info.peerID
				
					
					break;
				
				case "NetGroup.Posting.Notify":
					
					var  postedObject:Object = e.info.message;
					
					if(postedObject.type == "chat")
					{
						appendMessage(postedObject.user, postedObject.text);
					}
					
					break;
				
				case "NetGroup.Replication.Request":
					
					
					
					//get the part of the file we need
					var indexRequested :Number = e.info.index;
					
					//if the main FileStreamreader is running
					if(mainFS !=null)
					{
						dispatchPartOutgoing(indexRequested);
						
						
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
							this._partList.setItemAt("transfering", indexRequested);
							this.dispatchEvent(new OutgoingFilePartEvent(indexRequested));
							
							//TODO: check for integrity of the file 
							
							//Create a temp FileStream to read the file
							var tempFS :FileStream = new FileStream();
							tempFS.open(f1, FileMode.READ);
							
							//Create a temp ByteArray
							var tempBytes:ByteArray = new ByteArray();
							tempFS.readBytes(tempBytes, 0, tempFS.bytesAvailable);
							
							
							 
							
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
					
					
					
				 
					//broadcast that we now have this particular part
					_netGroup.addHaveObjects(index, index);
					_netGroup.removeWantObjects(index, index);
					
					dispatchPartIncoming(index);
					
					
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
						
						//dispatch an Event 
						this.dispatchEvent(new TartCompleteEvent(this.tart));
						 
						
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
		
		 
		
		
		
		 
		 
		
		[Bindable(event="IncomingFilePartEvent")]
		[Bindable(event="OutgoingFilePartEvent")]
		public function get partList():ArrayCollection
			
		{
			return this._partList;
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
		
	 
		
		private function dispatchPartOutgoing(index:int):void		
		{
			this._partList.setItemAt("transfering", index);	
			this.dispatchEvent(new OutgoingFilePartEvent(index));
		}
		
		private function dispatchPartIncoming(index:int):void
		{
			_partList.setItemAt("done", index);
			this.dispatchEvent(new IncomingFilePartEvent(index));
			
			//tell the transfer object we got one more file part
			receivedFilePartCount ++ ;
		}
		
		[Bindable(event="onMessageChangeEvent")]
		public function get messages():String
		{
			return this._messages;
		}
		
		public function postToGroup(userName:String, message:String):void
		{
			
			
			netGroup.post({user:userName, text:message, type:"chat"});
			 
			appendMessage(userName, message);
			
			
			
		}
		
		public function appendMessageFull(message:String):void
		{
			this._messages += message;
			
			dispatchEvent(new Event("onMessageChangeEvent"));
		}
		private function appendMessage(userName:String, message:String):void
		{
			this.appendMessageFull("<br/><b>"+userName+"</b>: " + message);
			 
		}
		
		/**
		 * Kill any transfer that might be open
		 * Delete all loose files
		 * Leave the group
		 * */
		public function kill():void
		{
			//broadcast gentlely that we don't have any more thing to share :)
			 
			_netGroup.removeHaveObjects(0, tart.getLastPart())
				
			 
			_netGroup.removeWantObjects(0, tart.getLastPart());
			
			//leave the netgroup
			_netGroup.close();
			
			//delete loose file
			var dir:File = File.applicationStorageDirectory.resolvePath(tart.getId())
			if(dir.exists)
				dir.deleteDirectory(true);
			
			//kill any transfer that might be open
			if(mainFS != null)
				mainFS.close();
			
			
		}
		
	}
	
}