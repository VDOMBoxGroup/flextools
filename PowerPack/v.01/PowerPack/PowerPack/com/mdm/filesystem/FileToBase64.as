package PowerPack.com.mdm.filesystem
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.utils.Base64Encoder;
	
	public class FileToBase64 extends EventDispatcher
	{
		private var request:URLRequest;
    	private var loader:URLLoader;
    	private var bytedata:ByteArray;
        
        [Bindable("filenameChanged")]
	    public function set filename(value:String):void
	    {
			request.url = value;
			loadAndConvert();
	    }	
	    public function get filename():String
	    {
	        return request.url;
	    }	    
	    
    	private var _data:String;
	    public function get data():String
	    {
	        return _data;
	    }		     
	       	    
       	public function FileToBase64(filename:String):void
       	{
			request = new URLRequest();
	    	request.method = URLRequestMethod.POST;
			request.url = filename;
    	    
    	    loader = new URLLoader();
    	    loader.dataFormat = URLLoaderDataFormat.BINARY;
        	loader.addEventListener(Event.COMPLETE, completeLoaderHandler);   
       	}
       	
       	public function loadAndConvert():void
       	{
       		_data = null;
       		
       		if(bytedata)
       			bytedata.length = 0;
       		
       		if(!FileUtils.isFileExists(request.url))
			{
			     throw new Error("File \"" + request.url + "\" does not exists."); 
			}       		
       		
       		try
			{
			    loader.load(request);
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
       	
       	private function completeLoaderHandler(event:Event):void
		{
			var encoder:Base64Encoder = new Base64Encoder();
		    bytedata = event.target.data;
		    
		    encoder.encodeBytes(bytedata);
		    _data = encoder.flush();
		    
		    dispatchEvent(new Event("dataConverted"));
		}
	}
}