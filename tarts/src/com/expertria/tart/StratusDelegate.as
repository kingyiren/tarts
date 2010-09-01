package com.expertria.tart
{
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;

	public class StratusDelegate
	{
		[Bindable]
		public var connected :Boolean = false;
		
		/**
		 * sign up for your key here:
		 * http://labs.adobe.com/technologies/stratus/
		 */ 
		private const developer_key :String = "YOUR KEY HERE" ;/* REPLACE THIS WITH YOUR DEVELOPER KEY*/
			
		private const rendezvous_server:String =   
			"rtmfp://stratus.rtmfp.net/";
		
		private   var netConnection:NetConnection  = new NetConnection(); 
		
		public function StratusDelegate()
		{
			
		}
		
		public function getNetConnection():NetConnection
		{
			return this.netConnection;	
		}
		
		public function beginConnect():void
		{
			 
			
			// Listen for status info 
			this.netConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus ); 
			this.netConnection.addEventListener(IOErrorEvent.IO_ERROR , onError);
			// Connect to stratus using our unique URI 
			this.netConnection.connect( this.rendezvous_server + this.developer_key  ); //which is: 
		}
		
		protected final function onNetStatus(e:NetStatusEvent):void{
			
			var   info_code :String = e.info.code; 
			switch(info_code)
			{
				case "NetConnection.Connect.Success":
					this.connected = true;
					trace("CONNECTED");
					break;
			
			}
			
		}
		
		protected final function onError(e:IOErrorEvent):void{
			
			 trace("Error in Connection");
			
		}
	}
}