package com.expertria.tart.view.renderer
{
	import com.expertria.tart.Tart;
	
	import spark.components.supportClasses.ItemRenderer;
	
	public class TartRendererClass extends ItemRenderer
	{
		
		public function TartRendererClass()
		{
			 
			super();
		 
			FileMenuDelegate.construct(this);
			
		}
		
		[Bindable("dataChange")]
		protected function getState():String
		{
			var t:Tart = data.getTart() as Tart;
			
			return t.getType() == Tart.HAS_FILE ? "outgoing" : "incoming";
		}
		
		
	}
}