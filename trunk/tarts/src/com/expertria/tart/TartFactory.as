package com.expertria.tart
{
	import com.adobe.crypto.MD5;
	
	import flash.filesystem.File;
	 

	public class TartFactory
	{
		public function TartFactory()
		{
		}
		
		private static var singleInstance:TartFactory;
		public static function getInstance():TartFactory
		{
			if(singleInstance == null) singleInstance = new TartFactory();
			return singleInstance;
		}
		
		public function createTartFromFile(f:File):Tart
		{	 		 
			  
			return new Tart(f.name, getFileId(f), f.size, f.extension, f.nativePath);
		}
		
		protected function getFileId(f:File):String
		{ 
			 
			return   MD5.hash(  f.name +  f.size);
		}
		
		public function createTartFromString(s:String):Tart
		{
			var xml:XML  = new XML(s);
			
		 
			
			return createTartFromXML(xml);
			 
		}
		
		public function createTartFromXML(xml:XML):Tart
		{
			return  new Tart(xml.name, xml.id, xml.size, xml["mime-type"], xml.ref, xml["part-size"], xml.type);
		}
	}
}