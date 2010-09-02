package com.expertria.tart.event
{
 
	public class Notifications
	{
		public function Notifications()
		{
			
			
		}
		
		/**
		 * ACCEPTS com.expertria.tart.Tart
		 * */
		public static const SAVE_TART:String = "SAVE_TART";
		
		
		/**
		 * Delete a Transfer
		 * ACCEPTS com.expertria.tart.Tart
		 * */
		public static const DELETE_TRANSFER:String = "DELETE_TRANSFER";
		
		/**
		 * Description: 
		 * ACCEPTS flash.filesystem.File;
		 * */
		public static const SELECT_FILE:String = "SELECT_FILE";
		 
	}
}