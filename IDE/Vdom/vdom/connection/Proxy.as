package vdom.connection {

import vdom.connection.soap.Soap;
import flash.utils.Timer;
import flash.events.TimerEvent;
import vdom.connection.soap.SoapEvent;
import flash.events.EventDispatcher;
import vdom.events.ProxyEvent;

public class Proxy {
	
	private static var instance:Proxy;
	
	private var soap:Soap;
	private var massObj:Array = new Array();
	private var dataToSend:Boolean = false ;
	private var timeToSend:Boolean = true;
	private var evtDisp:EventDispatcher = new EventDispatcher();
	
	public function Proxy() 
	{
        if( instance ) throw new Error( "Singleton and can only be accessed through Proxy.anyFunction()" );
        
         soap = Soap.getInstance();
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
		soap.addEventListener(SoapEvent.SET_ATTRIBUTE_S_OK, returnData)
		soap.addEventListener(SoapEvent.SET_ATTRIBUTE_S_ERROR, returnData)
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
		if(timeToSend){
		//	trace('Data sended');
			timeToSend = false;
			for (var appid:String in massObj)
			{
				for(var objid:String in massObj[appid])
				{
					soap.setAttributes(appid,objid,massObj[appid][objid].toXMLString());
					delete massObj[appid][objid];
				}
			}
			var myTimer:Timer = new Timer(3000, 1);
	        myTimer.addEventListener("timer", timeManedger);
	        myTimer.start();
  		} 
	}
	
	private function returnData(evt:SoapEvent):void
	{
	//	trace('*************** return **************');
	//	trace(evt.result);
		evtDisp.dispatchEvent(new ProxyEvent(ProxyEvent.PROXY_COMPLETE, evt.result) );
		
	}
}}