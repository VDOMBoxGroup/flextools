package net.vdombox.object_editor.model
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public final class ErrorLogger
	{	
		private static var _instance:ErrorLogger;
		private static var _errorArray:ArrayCollection = new ArrayCollection();	
		
		public static function get instance():ErrorLogger
		{
			if(_instance == null)
				_instance = new ErrorLogger();
			return _instance;
		}
		
		public function ErrorLogger()
		{
		}	
		
		public function logError(strError:String, strSource:String):void 
		{
			_errorArray.addItem({"error": strError, "source": strSource});
		}
		
		public static function get errorArray():ArrayCollection
		{			
			return _errorArray;
		}
	}	
}