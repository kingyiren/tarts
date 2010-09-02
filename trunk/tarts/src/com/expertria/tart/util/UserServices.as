package com.expertria.tart.util
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	//TODO: change to proxy
	public   class  UserServices extends EventDispatcher
	{
		 
		private static var singleInstance:UserServices;
		public static  function getInstance():UserServices
		{
				if(singleInstance == null)
					singleInstance = new UserServices();
				return singleInstance;
		}
		 
		private   var userDefinedName:String = null;
		
		/**
		 * Get Current OS User name - Works in windows and mac
		 * FROM: http://stackoverflow.com/questions/1376/get-the-current-logged-in-os-user-in-adobe-air/28034#28034
		 * */
		public  function get currentOSUser():String
		{
			var userDir:String = File.userDirectory.nativePath;
			var userName:String = userDir.substr(userDir.lastIndexOf(File.separator) + 1);
			return userName;
		}
		
		[Bindable(event="userNameChange")]
		public   function get currentUser():String
		{
			return  userDefinedName == null ?   currentOSUser : userDefinedName;
			
		}
		
		
		public   function changeName(newName:String):void
		{
			userDefinedName = newName;
			dispatchEvent(new Event("userNameChange"));
		}
	}
}
 
