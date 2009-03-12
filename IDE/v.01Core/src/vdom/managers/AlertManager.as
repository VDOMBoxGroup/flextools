package vdom.managers {
	
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.controls.Alert;
import mx.core.Application;
import mx.managers.PopUpManager;

import vdom.MyLoader;
	
public class AlertManager implements IEventDispatcher
{	
	private static var instance:AlertManager;
	
	private var alertWindow:MyLoader = new MyLoader();
	
	private var dispatcher:EventDispatcher = new EventDispatcher();
	
	/**
	 * 
	 * @return instance of AlertManager class (Singleton)
	 * 
	 */	
	public static function getInstance():AlertManager
	{
		if (!instance)
		{
			instance = new AlertManager();
		}
		
		return instance;
	}
	
	/**
	 * 
	 * Constructor
	 * 
	 */	
	public function AlertManager()
	{
		if (instance)
			throw new Error("Instance already exists."); 
	}
	
	public function showMessage(value:String):void
	{
		alertWindow.showText = value;
		
		if(value)
		{
			if(!alertWindow.parent)
				PopUpManager.addPopUp(alertWindow, DisplayObject(Application.application), true);
			else
				PopUpManager.bringToFront(alertWindow);
			
			PopUpManager.centerPopUp(alertWindow);
		}
		else if(alertWindow.parent)
		{
			PopUpManager.removePopUp(alertWindow);
		}
	}
	
	public function showAlert(value:String):void
	{
		Alert.show(value, "Alert");
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
		useWeakReference:Boolean = false):void
	{
		dispatcher.addEventListener(type, listener, useCapture, priority);
    }
    
    /**
     *  @private
     */
    public function dispatchEvent(event:Event):Boolean
    {
        return dispatcher.dispatchEvent(event);
    }
    
	/**
     *  @private
     */
    public function hasEventListener(type:String):Boolean
    {
        return dispatcher.hasEventListener(type);
    }
    
	/**
     *  @private
     */
    public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
    {
        dispatcher.removeEventListener(type, listener, useCapture);
    }
    
    /**
     *  @private
     */            
    public function willTrigger(type:String):Boolean
    {
        return dispatcher.willTrigger(type);
    }
}
}