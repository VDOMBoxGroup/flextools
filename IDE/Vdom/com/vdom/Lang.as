package com.vdom
{
	import mx.rpc.soap.WebService;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import com.gsolo.encryption.MD5;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	
	//[Event(name="langComplete", type="flash.events.Event")]
	//[Event(name="langError", type="flash.events.Event")]
	
	
	public class Lang 
		implements IEventDispatcher
	{
		private var dispatcher:EventDispatcher;
		private var langURL:String;
		private var langURLRequest:URLRequest;
		private var langLoader:URLLoader;
		[Bindable]
		public var lang:XML;
		private var _password:String;
		private var _count:Number;
		public var SID:String;
				
		public function Lang() {
			dispatcher = new EventDispatcher(this);
			//addEventListener("langComplete", langLoaded);
			//addEventListener("langError", langLoaded);	
		}

		public function loadLanguage(url:String):void {
			langURL = 'langs/'+url+'/language.xml';
			langURLRequest = new URLRequest(langURL);
			langLoader = new URLLoader(langURLRequest);
			langLoader.addEventListener("complete", langLoaded);
		}
		
		public function langLoaded(event:Event):void{
			lang = XML(langLoader.data);
		}
		
		public function faultHandler(event:FaultEvent):void{
			trace (event);	
		}
                    
	    public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
	        dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	           
	    public function dispatchEvent(evt:Event):Boolean{
	        return dispatcher.dispatchEvent(evt);
	    }
	    
	    public function hasEventListener(type:String):Boolean{
	        return dispatcher.hasEventListener(type);
	    }
	    
	    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
	        dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public function willTrigger(type:String):Boolean {
	        return dispatcher.willTrigger(type);
	    }
	}

}