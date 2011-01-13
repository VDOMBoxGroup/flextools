/*
	Class EventsProxy is a wrapper over the arrayCollection events
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import avmplus.USE_ITRAITS;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.EventParameterVO;
	import net.vdombox.object_editor.model.vo.EventVO;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class EventsProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "EventsProxy";

		public function EventsProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
		
		public function createXML( eventsVO: ArrayCollection ):XML
		{	
			var e2vdomXML:XML = new XML("<E2vdom/>");			
			var eventsXML:XML = new XML("<Events/>");
			e2vdomXML.appendChild(eventsXML);
			var userInterfEvXML:XML = new XML("<Userinterfaceevents/>");
			eventsXML.appendChild(userInterfEvXML);
			
			for each(var eventObj:Object in eventsVO )
			{	
				var eventVO:EventVO = eventObj.data;
				var eventXML:XML 	  = new XML("<Event/>");
				eventXML.@Name		  = eventVO.name;
				var parametersXML:XML = new XML("<Parameters/>");
				
				for each(var evParameterObj:Object in eventVO.parameters )
				{	
					var evParameterVO:EventParameterVO = evParameterObj.data;
					var parameterXML:XML	= new XML("<Parameter/>");
					parameterXML.@Name		= evParameterVO.name;
					parameterXML.@Order 	= evParameterVO.order;
					parameterXML.@VbType 	= evParameterVO.vbType;
					parameterXML.@Help 		= evParameterVO.help;
					parametersXML.appendChild( parameterXML );
				}
				eventXML.appendChild( parametersXML );
				userInterfEvXML.appendChild( eventXML );
			}
			return e2vdomXML;
		}	
		
		public function createFromXML(objTypeXML:XML):ArrayCollection
		{
			var eventsCollection:ArrayCollection = new ArrayCollection();
			
//todo 	var eventsXML:XML = objTypeXML.descendants("Events")
//			var e2vdomXML:XML = objTypeXML.descendants("E2vdom")
//			var eventsXML:XML = e2vdomXML.descendants("Events")
//			var usIntEvXML:XML = objTypeXML.descendants("Userinterfaceevents")
			for each ( var eventXML : XML in objTypeXML.descendants("Event") )
			{
				var eventVO:EventVO = new EventVO();
				eventVO.name = eventXML.@Name;
				
				for each ( var parameterXML : XML in eventXML.descendants("Parameter") )
				{
					var eventParameter:EventParameterVO = new EventParameterVO;
					
					eventParameter.name		= parameterXML.@Name;
					eventParameter.order	= parameterXML.@Order;
					eventParameter.vbType	= parameterXML.@VbType;
					eventParameter.help		= parameterXML.@Help;
										
					eventVO.parameters.addItem({label:eventParameter.name, data:eventParameter});	
				}	
				eventsCollection.addItem({label:eventVO.name, data:eventVO});
			}			
			return eventsCollection;
		}
		
		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}
	}	
}