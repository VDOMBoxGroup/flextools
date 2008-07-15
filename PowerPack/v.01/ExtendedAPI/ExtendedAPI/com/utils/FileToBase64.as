package ExtendedAPI.com.utils
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	
	public class FileToBase64 extends EventDispatcher
	{
		private var file:File;
		private var fileStream:FileStream;
        
        [Bindable("filenameChanged")]
	    public function set filename(value:String):void
	    {
	    	file.url = FileUtils.pathToUrl(value);
			loadAndConvert();
	    }	
	    public function get filename():String
	    {
	        return file.nativePath;
	    }	    
	    
    	private var strData:String;
	    public function get data():String
	    {
	        return strData;
	    }		     
	       	    
       	public function FileToBase64(filename:String):void
       	{
       		file = new File();
       		file.url = FileUtils.pathToUrl(filename);
    	    
    	    fileStream = new FileStream();
       	}
       	
       	public function loadAndConvert():void
       	{
       		strData = null;
       		
       		if(!file.exists)
       		{
       			throw new IOError("File does not exist");
       		}
       		
       		try
			{
    	 		fileStream.addEventListener(Event.COMPLETE, completeLoadHandler);
	    		fileStream.openAsync(file, FileMode.READ);
			}
			catch (error:ArgumentError)
			{
			    throw new Error("An ArgumentError has occurred.");
			}
			catch (error:SecurityError)
			{
			    throw new Error("A SecurityError has occurred.");
			}			
       	}
       	
       	public function convert():void
       	{
       		strData = null;
       		
       		if(!file.exists)
       		{
       			throw new IOError("File does not exist");
       		}
       		
       		try
			{
				var encoder:Base64Encoder = new Base64Encoder();
				var bytes:ByteArray = new ByteArray();
				
    	 		fileStream.addEventListener(Event.COMPLETE, completeLoadHandler);
	    		fileStream.open(file, FileMode.READ);
				fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
				fileStream.close();			
			
			    encoder.encodeBytes(bytes);
		    	strData = encoder.flush();
			}
			catch (error:ArgumentError)
			{
			    throw new Error("An ArgumentError has occurred.");
			}
			catch (error:SecurityError)
			{
			    throw new Error("A SecurityError has occurred.");
			}       		
       	}
       	
       	private function completeLoadHandler(event:Event):void
		{
			var encoder:Base64Encoder = new Base64Encoder();
			var fileStream:FileStream = event.target as FileStream;
			var bytes:ByteArray = new ByteArray();
        		
			fileStream.removeEventListener(Event.COMPLETE, completeLoadHandler);

			fileStream.readBytes(bytes, 0, fileStream.bytesAvailable);
			fileStream.close();			
			
		    encoder.encodeBytes(bytes);
		    strData = encoder.flush();
		    
		    dispatchEvent(new Event("dataConverted"));
		}
	}
}