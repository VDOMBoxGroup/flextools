/*
	Class EventsProxy is a wrapper over the Events
 */
package net.vdombox.object_editor.model.proxy.componentsProxy
{
	import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.proxy.Proxy;
   
    public class EventsProxy extends Proxy implements IProxy
    {
		public static const NAME:String = "EventsProxy";

		public function EventsProxy ( data:Object = null ) 
        {
            super ( NAME, data );
        }
	}
}