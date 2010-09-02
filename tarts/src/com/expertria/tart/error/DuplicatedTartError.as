package com.expertria.tart.error
{
	import com.expertria.tart.Tart;

	public class DuplicatedTartError extends Error
	{
		public function DuplicatedTartError(tart:Tart)
		{
			super("Duplicated Tart Detected", 0);
			this._tart = tart;
		}
		private var _tart:Tart;
		
		public function get tart():Tart
		{
			return this._tart;
		}
	}
}