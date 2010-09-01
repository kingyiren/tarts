package com.expertria.tart.view.renderer
{
	import com.expertria.tart.Tart;
	
	import flash.events.Event;
	
	import spark.components.supportClasses.ItemRenderer;
	
	public class TartRendererClass extends ItemRenderer
	{
		
		[Embed(source="assets/arrow_out.png")]
		[Bindable]
		public var arrow_out:Class;
		
		[Bindable]public var isOutgoing:Boolean = true;
		
		[Embed(source="assets/arrow_in.png")]
		[Bindable]
		public var arrow_in:Class;
		
		public function TartRendererClass()
		{
			 
			super();
		 
			
			 
		}
		
		
		 
		protected function onDataChange(e:Event):void
		{
			var t:Tart = data.getTart() as Tart;
			
			isOutgoing =  ( t.getType() == Tart.HAS_FILE );
			
			 
			if(t != null)
				FileMenuDelegate.construct(this);
		}
		
		
	}
}