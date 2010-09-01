package com.expertria.tart.proxy
{
	import com.expertria.tart.TartTransfer;
	
	import mx.collections.ArrayCollection;
	
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class AppProxy extends Proxy
	{
		public static const NAME:String = "AppProxy";
		
		[Bindable]
		public var currentTransfers:ArrayCollection = 
			new ArrayCollection();
		
		public function AppProxy( data:Object=null)
		{
			super(NAME, data);	 
		}
		
		public function addTransfer(transfer:TartTransfer):void
		{
			this.currentTransfers.addItem(transfer);
		}
	}
}