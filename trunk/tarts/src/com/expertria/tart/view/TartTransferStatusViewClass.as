package com.expertria.tart.view
{
	import com.expertria.tart.TartTransfer;
	import com.expertria.tart.util.UserServices;
	 
	
	import flash.events.Event;
	
	import flashx.textLayout.conversion.TextConverter;
	
	import mx.events.FlexEvent;
	
	import spark.components.BorderContainer;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.utils.TextFlowUtil;
	
	public class TartTransferStatusViewClass extends BorderContainer
	{
		protected var _currentTartTransfer :TartTransfer;
		
		public var fileGroupTxt:TextArea;
		public var sendMessageTxt:TextInput;
		
		
		public function TartTransferStatusViewClass()
		{
			super();
		}
		
		[Bindable]
		public function set currentTartTransfer(tartTransfer:TartTransfer):void
		{
			this._currentTartTransfer = tartTransfer;
			
			 
			
		}
		public function get currentTartTransfer():TartTransfer
		{
			return this._currentTartTransfer;
		}
		
		 
		private static const  helpMsg  : String = "<p>/u username \"change username\"</p>"
		
		protected function onSendMessageClickHandler(e:Event):void
		{
			
			var s:String = 	sendMessageTxt.text;
			
			sendMessageTxt.text = "";
			
			if(s.indexOf("/help")== 0)
			{
				_currentTartTransfer.appendMessageFull(helpMsg);
			}
			else if(s.indexOf("/u") == 0)
			{
				var newName :String = s.substr(3);
				UserServices.getInstance() .changeName(newName);
			}
			else
			{
				_currentTartTransfer.postToGroup(UserServices.getInstance() .currentUser, s) ;
			}
			
			 
		 
		}
		
		 
	 
	}
}