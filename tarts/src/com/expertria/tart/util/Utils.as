package com.expertria.tart.util
{
	import flash.desktop.NativeApplication;

	public class  Utils
	{
		 
		public function Utils()
		{
			
		}
		
		/**
		 * FROM: http://www.davidtucker.net/2007/12/14/air-tip-3-what-version-is-my-application/
		 * */
		public static function getApplicationVersion():String {
			   
			    // Get the Application Descriptor File
			    var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			 
			    // Define the Namespace (there is only one by default in the application descriptor file)
			    var air:Namespace = appXML.namespaceDeclarations()[0];
			   
			    // Use E4X To Extract the Needed Information		     
			    return  appXML.air::version;		   	   
		}
	}
}
 
