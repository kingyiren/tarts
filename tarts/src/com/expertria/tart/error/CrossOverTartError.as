package com.expertria.tart.error
{
	import com.expertria.tart.Tart;

	public class CrossOverTartError extends Error
	{
		public function CrossOverTartError(tart:Tart)
		{
			super("Cannot Share and Need a Tart at the same time", 0);
			this._tart = tart;
		}
		private var _tart:Tart;
		
		public function get tart():Tart
		{
			return this._tart;
		}
	}
}