package com.expertria.tart
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	public class Tart extends EventDispatcher
	{
		 
			
		private var name:String;
		private var ref:String;
		private var type:String;
		private var id:String;
		private var size:uint;
		private var partSize:uint;
		private var mimeType:String;
		
		private var totalParts :int;
		private var lastPartSize: uint;
		
		public static const 
			HAS_FILE:String = "HAS_FILE", //
			NEED_FILE:String = "NEED_FILE" , //
			NONE:String = "NONE" ;
		
		public function Tart(name:String, id:String, size:uint,   mimeType:String ,ref:String = null ,
							 partSize:uint = 512000,  type :String =  HAS_FILE  )
		{
			this.name = name;
			this.id= id;
			this.size = size;
			this.mimeType = mimeType;
			this.partSize = partSize;
			this.type = type;
			this.ref = ref;
			
			totalParts  =  Math.ceil(size / partSize);
			this.lastPartSize = size - ( totalParts - 1 ) * partSize
		}
		
		public function needFile():void
		{
			this.type = NEED_FILE;
			this.ref = File.applicationStorageDirectory.resolvePath(getId() + "/").nativePath;
		}
		public function getLastPart():int
		{
			return totalParts - 1;
		}
		
		public function getName():String
		{
			return this.name;
		}
		
		
		public function getTotalParts():int
		{
			return this.totalParts;
			
		}
		public function getId():String
		{
			return this.id;
		}
		
		public function getSize():uint
		{
			return this.size;
		}
		public function getPartSize():uint
		{
			return this.partSize;
		}
		
		[Bindable(event="onTypeChangeEvent")]
		public function getType():String
		{
			return this.type;
		}
		public function getRef():String
		{
			return this.ref;
		}
		
		public function getLastPartSize():uint
		{
			return this.lastPartSize;
		}
		
		public function toXML():XML
		{
			var xml:XML = new XML("<file></file>");
			xml.name = this.name;
			xml.ref = this.ref;
			xml.type = this.type;
			xml.id = this.id;
			xml.size=  this.size;
			xml["part-size"] = this.partSize;
			xml["mime-type"] = this.mimeType;
		
			 
			return xml;
		}
		
		
		public function setRef(ref:String):void
		{
			this.ref = ref;
		}
		public function setType(type:String):void
		{
			this.type = type;
			this.dispatchEvent(new Event("onTypeChangeEvent"));
		}
		
		
	  
		
	}
}