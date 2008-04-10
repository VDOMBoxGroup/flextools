package vdom.containers {
	
import mx.core.IContainer;

public interface IItem {

function get objectId():String

function get editableAttributes():Array 	
function set editableAttributes(attributesArray:Array):void

function get waitMode():Boolean 	
function set waitMode(mode:Boolean):void

function get isStatic():Boolean 	
function set isStatic(mode:Boolean):void

function drawHighlight(color:String):void 
	
}
}