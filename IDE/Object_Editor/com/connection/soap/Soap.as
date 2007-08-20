package com.connection.soap
{
	import mx.rpc.soap.WebService;
	import com.connection.protect.MD5;
	import com.connection.soap.*;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.events.FaultEvent;
	import mx.controls.Alert;
	import mx.rpc.soap.LoadEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import com.connection.soap.SoapEvent;
	import com.connection.utils.FileUpload;
	import mx.controls.Image;
	import mx.charts.AreaChart;
	import mx.controls.Button;
		
	public class Soap 
	{
		
		private static 	var ws			:WebService	= new WebService;
		private static 	var instance	:Soap;
		private 		var lg			:SLogin = new SLogin(ws);
		private 		var ed			:EventDispatcher = new EventDispatcher;
		
		
		public function Soap() {
            if( instance ) throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
        } 		
		 
		 // initialization		
		 public static function getInstance():Soap {
             
             return instance || (instance = new Soap()); ;
        }		
		
		public function init(wsdl:String = 'http://192.168.0.23:82/vdom.wsdl'):void{
			//initialization SOAP
			ws.wsdl = wsdl;
			ws.useProxy = false;
			ws.loadWSDL();		
			ws.addEventListener(FaultEvent.FAULT, errorListener);
		}

		
		// 1 - open session open_session
		public   function login(login:String='NaN', password:String='NaN'):void {
			
			lg.execute(login,password);
			lg.addEventListener(SoapEvent.LOGIN_OK, dispatchEvent);
			lg.addEventListener(SoapEvent.LOGIN_ERROR, dispatchEvent);
			
			//dispatchEvent(			
		}
	
		public   function loginResult():XML {
			return lg.getResult();
		}
		
		private var sco: SCreateObject =new SCreateObject;
		public function createObject():void{
			sco.execute(ws,'NaN','NaN','NaN');
			sco.addEventListener(SoapEvent.CREATE_OBJECT_OK, dispatchEvent);
			sco.addEventListener(SoapEvent.CREATE_OBJECT_ERROR, dispatchEvent);
		}
		
		// 20 
		//private var fu:FileUpload = new FileUpload();
		private var masEcho:Array = new Array();
		private var masListenet:Array = new Array();
		private var btn:Button;
		public function sendEcho(identificator:String, btn:Button,	 listenerOk:Function, istenerError:Function):void{
			this.btn = btn;
				masEcho[identificator] = new FileUpload();
				masListenet[identificator] =  new Function();
				trace("MAde: masListenet[identificator] =  new Function(); ")
			masEcho[identificator].startUpload(ws, this.btn);
			
	//		masListenet[identificator] = listener;
			masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_OK, listenerOk);
			masEcho[identificator].addEventListener(SoapEvent.GET_ECHO_ERROR, istenerError);
		}
		
		public function getEchoResult(identificator:String):Image{
			var img:Image =  new Image();
			img = masEcho[identificator].getResul();
			delete masEcho[identificator];
//			trace('SOAP.AS : Return image');
			return img;
		}
		
		
		//Error
		private  function errorListener(event:ResultEvent):void{
	//		Alert.show("Soap error:\n"+ event.toString());
			dispatchEvent(event);
		}
		
//		private var ed:EventDispatcher = new EventDispatcher;
		public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void{
			  ed.addEventListener(type, listener, useCapture, priority);
    	}
           
    	public function dispatchEvent(evt:Event):Boolean{
      	return	 ed.dispatchEvent(evt);
    	}		
	}
}