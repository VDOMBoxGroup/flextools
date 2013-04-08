package vdom.connection {

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.rpc.events.FaultEvent;

import vdom.events.ProxyEvent;
import vdom.events.SOAPEvent;

public class Proxy {
	
	private static var instance:Proxy;
	
	private var soap:SOAP = SOAP.getInstance();
	private var dispatcher:EventDispatcher = new EventDispatcher();
	private var massObj:Array = new Array();
	private var dataToSend:Boolean = false ;
	private var timeToSend:Boolean = true;
	private var evtDisp:EventDispatcher = new EventDispatcher();
	
	public function Proxy() 
	{
		if( instance ) throw new Error( "Singleton and can only be accessed through Proxy.anyFunction()" );
	} 
	 
	 // initialization		
	 public static function getInstance():Proxy 
	 {
		 return instance||new Proxy() ;
	 }		
	 
	 public function flush():void
	 {
	 //	trace("I'm a flush(:)");
	 	timeToSend = true;
	 	sender();	
	 }	
	 
	 public function  setAttributes(appid:String, objid:String, attr:XML):void
	 {
		// in "massObj[appid][objid]" add changes
		if(massObj[appid])// c "appid" уже работали раньше?
		{
			// c "objid" уже работали раньше?
			if(massObj[appid][objid])
			{
				// обьединяем старые и новые данные
				var xml:XMLList = massObj[appid][objid].children() + attr.children();
				var out:XML = <Attributes/>;
				for each(var item:XML in xml) 
				{
					// убираем повторы
					var test:XMLList = out.Attribute.(@Name == item.@Name);
					if (test.@Name == item.@Name) 
					{
						   test[0] = item;
					} 
					else 
					{ 
						out.item += item; 
					}
				} 
		 			massObj[appid][objid] = out;
	  		}else
	  		{
	  			//создаем новый "objid" и добавляем данные
	  			massObj[appid][objid] = attr;
	  		}
  		}
  		else
  		{	//создаем новый "appid" и добавляем данные
  			massObj[appid] = new Array(); 
  			massObj[appid][objid] = attr;
  		}
  		
	//	trace('Result:----------- '+ appid + ": \n" + objid + ": \n" +massObj[appid][objid]+ ": \n");
		dataToSend = true;
		sender();
		soap.set_attributes.addEventListener(SOAPEvent.RESULT, returnData);
		soap.set_attributes.addEventListener(FaultEvent.FAULT, returnDataError);
	}
	
	private function timeManedger(evt:TimerEvent):void
	{
		timeToSend = true;
	//	trace('timeManedger work \n');
		if(dataToSend)
		{
			dataToSend = false;
			sender();
		}	
	}
	
	private function sender():void
	{
		//
		if(timeToSend){
//			trace('-Send data-');
		//	trace('Data sended');
			timeToSend = false;
			for (var appid:String in massObj)
			{
				for(var objid:String in massObj[appid])
				{
					var key:String = soap.set_attributes( appid, objid, XML( massObj[appid][objid] ) );
					dispatchEvent(new ProxyEvent(ProxyEvent.PROXY_SEND, null, objid, key));
					delete massObj[appid][objid];
				}
			}
			var myTimer:Timer = new Timer(1000, 1);
			myTimer.addEventListener("timer", timeManedger);
			myTimer.start();
  		} 
	}
	
	private function returnData(evt:SOAPEvent):void
	{
	//	trace('*************** return **************');
	//	trace(evt.result);
		dispatchEvent(new ProxyEvent(ProxyEvent.PROXY_COMPLETE, evt.result) );
		
	}
	
	private function returnDataError(event:FaultEvent):void
	{
		dispatchEvent(FaultEvent.createEvent(event.fault));
	}
	
	// Реализация диспатчера
	
	/**
	 *  @private
	 */
	public function addEventListener(
		type:String, 
		listener:Function, 
		useCapture:Boolean = false, 
		priority:int = 0, 
		useWeakReference:Boolean = false):void {
			dispatcher.addEventListener(type, listener, useCapture, priority);
	}
	
	/**
	 *  @private
	 */
	public function dispatchEvent(evt:Event):Boolean{
		return dispatcher.dispatchEvent(evt);
	}
	
	/**
	 *  @private
	 */
	public function hasEventListener(type:String):Boolean{
		return dispatcher.hasEventListener(type);
	}
	
	/**
	 *  @private
	 */
	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
	
	/**
	 *  @private
	 */			
	public function willTrigger(type:String):Boolean {
		return dispatcher.willTrigger(type);
	}
}}